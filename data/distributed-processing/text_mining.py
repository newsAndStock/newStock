import re
import boto3
import json
import pandas as pd
from konlpy.tag import Okt
from collections import Counter
import uuid
from datetime import datetime, timedelta
from sqlalchemy import create_engine
import time
import logging

# 로깅 설정
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s', filename='app.log', filemode='a')

# RDS 연결 설정
RDS_ENDPOINT = RDS_ENDPOINT
DB_USER = 'admin'
DB_PASSWORD = DB_PASSWORD
DB_NAME = DB_NAME

engine = create_engine(f"mariadb+pymysql://{DB_USER}:{DB_PASSWORD}@{RDS_ENDPOINT}/{DB_NAME}?charset=utf8mb4")

# 이모티콘 및 특수문자 제거 함수
def remove_emoji_and_special_characters(text):
    if not text:
        return ""
    
    # 이모지 패턴 정의
    emoji_pattern = re.compile("["
                               u"\U0001F600-\U0001F64F"  # emoticons
                               u"\U0001F300-\U0001F5FF"  # symbols & pictographs
                               u"\U0001F680-\U0001F6FF"  # transport & map symbols
                               u"\U0001F1E0-\U0001F1FF"  # flags (iOS)
                               "]+", flags=re.UNICODE)

    special_char_pattern = re.compile(r"[^a-zA-Z0-9가-힣\s]")

    text = emoji_pattern.sub(r'', text)
    text = special_char_pattern.sub(r'', text)
    
    return text

# S3에서 데이터 불러오기
def load_s3_data():
    s3 = boto3.client('s3')
    bucket_name = 'newstock-news'
    prefix = 'finance-data'
    
    # S3에서 최신 파일 목록 불러오기
    response = s3.list_objects_v2(Bucket=bucket_name, Prefix=prefix)
    if 'Contents' in response:
        sorted_files = sorted(response['Contents'], key=lambda x: x['LastModified'], reverse=True)
        latest_file = sorted_files[0]
        file_key = latest_file['Key']
        
        # 최신 파일 읽기
        response = s3.get_object(Bucket=bucket_name, Key=file_key)
        content = response['Body'].read().decode('utf-8')
        json_data = json.loads(content)
        logging.info(f"S3에서 데이터를 성공적으로 불러왔습니다: {file_key}")
        return json_data
    else:
        logging.warning("지정한 버킷/접두사에 파일이 없습니다.")
        return None

# 뉴스 테이블에 UUID 생성하여 인덱스로 사용
def process_data_with_uuid(json_data):
    df = pd.DataFrame(json_data, columns=['category', 'title', 'date', 'content', 'press', 'image_url'])

    # 뉴스 데이터를 UTF-8로 인코딩하고 특수문자 및 이모티콘 제거
    df['category'] = df['category'].apply(lambda x: remove_emoji_and_special_characters(x))
    df['title'] = df['title'].apply(lambda x: remove_emoji_and_special_characters(x))
    df['content'] = df['content'].apply(lambda x: remove_emoji_and_special_characters(x))
    df['press'] = df['press'].apply(lambda x: remove_emoji_and_special_characters(x))

    # UUID 생성해서 일반 컬럼으로 추가 (인덱스가 아닌 컬럼)
    df['news_id'] = [str(uuid.uuid4()).replace('-', '.') for _ in range(len(df))]
    
    # 인덱스를 리셋하고 기존 인덱스를 제거
    df = df.reset_index(drop=True)
    
    return df

# 뉴스별 금융 단어 개수 세기
def count_news_keyword(df):
    okt = Okt()
    finance_terms = pd.read_csv('filtered_finance_data.csv')['용어'].tolist()
    news_keyword_list = []
    
    for idx, row in df.iterrows():
        nouns = okt.nouns(row['content'])
        filtered_nouns = [word for word in nouns if word in finance_terms]  # 금융 관련 단어 필터링
        word_count = Counter(filtered_nouns)
        
        for word, count in word_count.items():
            news_keyword_list.append({'news_id': row['news_id'], 'word': word, 'count': count})

    if news_keyword_list:
        news_keyword_df = pd.DataFrame(news_keyword_list, columns=['news_id', 'word', 'count'])
        news_keyword_df = news_keyword_df.reset_index(drop=True)
    else:
        news_keyword_df = pd.DataFrame(columns=['news_id', 'word', 'count'])
        logging.warning("키워드 데이터가 없습니다.")
    
    return news_keyword_df

# 뉴스별 단어 카운트를 바탕으로 전체 단어 개수 세기
def count_total_keyword_from_news(news_keyword_df):
    total_word_count = news_keyword_df.groupby('word')['count'].sum().reset_index()
    
    total_word_count.columns = ['word', 'count']
    
    # 현재 날짜 추가 UTC 시간이라 한국 시간으로 바꿔야함
    current_date = datetime.utcnow()
    korea_time = current_date + timedelta(hours=9)
    korea_time_str = korea_time.strftime('%y%m%d')
    
    total_word_count['date'] = korea_time_str
    total_word_count = total_word_count.reset_index(drop=True) 
    
    return total_word_count

# DB 저장
def save_to_rds(df, table_name):
    try:
        df.to_sql(table_name, engine, if_exists='append', index=False)
        logging.info(f"{table_name} 테이블에 데이터가 성공적으로 저장되었습니다.")
    except Exception as e:
        logging.error(f"{table_name} 테이블에 데이터 저장 중 오류 발생: {e}")
        logging.debug(f"오류 발생 데이터: {df.to_dict(orient='records')}")

# 메인 함수
def main():
    # S3에서 데이터 불러오기
    json_data = load_s3_data()
    if json_data:
        # 뉴스 테이블 (UUID 포함) 생성
        df_with_uuid = process_data_with_uuid(json_data)

        # 뉴스별 금융 단어 개수 세기
        news_keyword_df = count_news_keyword(df_with_uuid)

        # 뉴스별 금융 단어 개수를 이용하여 전체 단어 개수 세기
        total_keyword_df = count_total_keyword_from_news(news_keyword_df)

        # 데이터프레임을 각각 RDS의 테이블에 저장
        save_to_rds(df_with_uuid, 'news')  # news 테이블에 저장
        time.sleep(1)
        save_to_rds(news_keyword_df, 'keyword')  # keyword 테이블에 저장
        time.sleep(1)
        save_to_rds(total_keyword_df, 'total_keyword')  # total_keyword 테이블에 저장

if __name__ == "__main__":
    main()
