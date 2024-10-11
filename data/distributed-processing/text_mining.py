import logging
from pyspark.sql.types import StringType
import re
from sqlalchemy import create_engine
import boto3
import json
from datetime import datetime, timedelta
from konlpy.tag import Okt
from collections import Counter
import uuid
import pandas as pd
import os
from pyspark.sql.types import StructField
from pyspark.sql.types import StructType, IntegerType, StringType, ArrayType
from pyspark import SparkContext
from pyspark.sql import Row
import pymysql
from pyspark.sql import SparkSession
from pyspark.sql import functions as F
from sqlalchemy import text

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

pd.DataFrame.iteritems = pd.DataFrame.items

# RDS연결 설정
RDS_ENDPOINT = RDS_ENDPOINT
DB_USER = DB_USER
DB_PASSWORD = DB_PASSWORD
DB_NAME = DB_NAME

# SQLAlchemy 엔진 생성 (MariaDB에 맞게 설정)
engine = create_engine(
    f"mariadb+pymysql://{DB_USER}:{DB_PASSWORD}@{RDS_ENDPOINT}/{DB_NAME}?charset=utf8mb4"
)

# spark session 생성
spark = (
    SparkSession.builder.master(MASTER_IP)
    .appName("dis-test")
    .config("spark.executor.memory", "4g")
    .config("spark.executor.cores", "4")
    .config("spark.shuffle.service.enabled", "false")
    .config("spark.dynamicAllocation.enabled", "false")
    .config("spark.jars", "/mariadb-java-client-2.7.2.jar")
    .getOrCreate()
)


# 이모티콘 및 특수문자 제거 함수 (Spark UDF로 변환)
def remove_emoji_and_special_characters_udf(text):
    if not text:
        return ""

    emoji_pattern = re.compile(
        "["
        "\U0001F600-\U0001F64F"  # 이모지
        "\U0001F300-\U0001F5FF"  # 픽토그램
        "\U0001F680-\U0001F6FF"  # 맵 심볼
        "\U0001F1E0-\U0001F1FF"  # ios flag
        "]+",
        flags=re.UNICODE,
    )

    special_char_pattern = re.compile(r"[^a-zA-Z0-9가-힣\s]")

    text = emoji_pattern.sub(r"", text)
    text = special_char_pattern.sub(r"", text)

    return text

# Spark UDF로 등록
remove_emoji_and_special_characters = F.udf(
    remove_emoji_and_special_characters_udf, StringType()
)


def load_s3_data():
    try:
        s3 = boto3.client("s3")
        bucket_name = "newstock-news"
        prefix = "finance-data"

        # S3에서 최신 파일 목록 불러오기
        response = s3.list_objects_v2(Bucket=bucket_name, Prefix=prefix)
        if "Contents" in response:
            sorted_files = sorted(
                response["Contents"], key=lambda x: x["LastModified"], reverse=True
            )
            latest_file = sorted_files[0]
            file_key = latest_file["Key"]

            response = s3.get_object(Bucket=bucket_name, Key=file_key)
            content = response["Body"].read().decode("utf-8")
            json_data = json.loads(content)

            pandas_df = pd.DataFrame(json_data)

            schema = StructType(
                [
                    StructField("category", StringType(), True),
                    StructField("title", StringType(), True),
                    StructField("date", StringType(), True),
                    StructField("content", StringType(), True),
                    StructField("press", StringType(), True),
                    StructField("image_url", StringType(), True),
                ]
            )
            spark_df = spark.createDataFrame(pandas_df, schema=schema)
            return spark_df
        else:
            logger.error("S3에서 데이터를 찾을 수 없습니다.")
            return None
    except Exception as e:
        logger.error(f"S3 데이터 로드 중 오류 발생: {e}")
        return None


# 뉴스 데이터 전처리 및 UUID 생성
def process_data_with_uuid(df):
    # 이모티콘 및 특수문자 제거
    df = df.withColumn(
        "category", remove_emoji_and_special_characters(F.col("category"))
    )
    df = df.withColumn("title", remove_emoji_and_special_characters(F.col("title")))
    df = df.withColumn("content", remove_emoji_and_special_characters(F.col("content")))
    df = df.withColumn("press", remove_emoji_and_special_characters(F.col("press")))
    df = df.withColumn("news_id", F.expr("uuid()"))
    return df


def count_news_keyword(df, finance_terms):
    def extract_finance_terms_udf(content):
        okt = Okt()
        nouns = okt.nouns(content)
        filtered_nouns = [
            word for word in nouns if word in finance_terms
        ]  # 금융 용어 필터링
        word_count = dict(Counter(filtered_nouns))
        return [(word, count) for word, count in word_count.items()]

    extract_finance_terms = F.udf(
        extract_finance_terms_udf,
        ArrayType(
            StructType(
                [
                    StructField("word", StringType(), True),
                    StructField("count", IntegerType(), True),
                ]
            )
        ),
    )

    df_with_keywords = df.withColumn(
        "keywords", extract_finance_terms(F.col("content"))
    )

    # explode를 통해 각 단어를 분리하여 news_id, word, count 형태로 변환
    exploded_df = df_with_keywords.withColumn(
        "keyword", F.explode(F.col("keywords"))
    ).select(F.col("news_id"), F.col("keyword.word"), F.col("keyword.count"))

    logger.info("뉴스에서 키워드를 성공적으로 추출했습니다.")
    return exploded_df


# 전체 금융 단어 개수 세기
def count_total_keyword_from_news(df):
    total_word_count = df.groupBy("word").agg(F.sum("count").alias("count"))

    # 현재 날짜 추가
    current_date = datetime.utcnow()
    korea_time = current_date + timedelta(hours=9)
    korea_time_str = korea_time.strftime("%y%m%d")

    total_word_count = total_word_count.withColumn("date", F.lit(korea_time_str))
    logger.info("금융 단어 총 개수를 성공적으로 계산했습니다.")
    return total_word_count


def save_to_rds(df, table_name):
    try:
        data = df.toPandas()

        data.to_sql(table_name, engine, if_exists="append", index=False)
        logger.info(f"데이터가 '{table_name}' 테이블에 성공적으로 저장되었습니다.")

        # 데이터 삽입 후 확인
        if table_name == "news":
            with engine.connect() as connection:
                query = text("SELECT COUNT(*) FROM news")
                result = connection.execute(query).fetchone()
                logger.info(
                    f"'news' 테이블에는 현재 {result[0]}개의 레코드가 있습니다."
                )

    except Exception as e:
        logger.error(f"{table_name} 테이블에 데이터 저장 중 오류 발생: {e}")


def main():
    df = load_s3_data()
    if df:
        # UUID 포함된 데이터프레임 생성
        df_with_uuid = process_data_with_uuid(df)
        # 금융 용어 리스트 로드
        finance_terms = pd.read_csv("filtered_finance_data.csv")["용어"].tolist()
        # 뉴스별 금융 단어 개수 세기
        news_keyword_df = count_news_keyword(df_with_uuid, finance_terms)
        # 전체 금융 단어 개수 세기
        total_keyword_df = count_total_keyword_from_news(news_keyword_df)

        save_to_rds(df_with_uuid, "news")
        save_to_rds(news_keyword_df, "keyword")
        save_to_rds(total_keyword_df, "total_keyword")


if __name__ == "__main__":
    main()
