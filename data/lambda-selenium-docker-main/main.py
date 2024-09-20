import os
import json
import time
import logging
import boto3
import signal
from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import NoSuchElementException, TimeoutException as SeleniumTimeoutException, ElementClickInterceptedException
from datetime import datetime, timedelta

# S3 클라이언트 초기화 및 로거 설정
s3_client = boto3.client('s3')
logger = logging.getLogger()
logger.setLevel("INFO")

# 타임아웃 핸들러 정의 (사용자 정의 예외 대신 일반적인 예외 처리)
def timeout_handler(signum, frame):
    raise Exception("lambda 타임아웃 발생 지금까지 크롤링한 데이터 저장")

def save_to_s3(crawled_data, save_date):
    s3_bucket_name = os.environ['S3_BUCKET_NAME']
    s3_object_prefix = os.environ['S3_OBJECT_PREFIX']
    s3_object_key = f"{s3_object_prefix}{save_date}.json"

    try:
        s3_client.put_object(
            Bucket=s3_bucket_name,
            Key=s3_object_key,
            Body=json.dumps(crawled_data, ensure_ascii=False),
            ContentType='application/json'
        )
        logger.info(f"크롤링한 데이터를 S3 버킷 '{s3_bucket_name}'에 저장했습니다: {s3_object_key}")
    except Exception as e:
        logger.error(f"S3에 데이터 저장 중 오류 발생: {str(e)}")

def handler(event, context):
    chrome_options = Options()
    chrome_options.binary_location = "/opt/chrome/chrome"
    chrome_options.add_argument("--headless")
    chrome_options.add_argument("--no-sandbox")
    chrome_options.add_argument("--single-process")
    chrome_options.add_argument("--disable-dev-shm-usage")
    chrome_options.add_argument("user-agent=Mozilla/5.0")
    service = Service(executable_path="/opt/chromedriver")
    driver = webdriver.Chrome(service=service, options=chrome_options)

    # 크롤링한 데이터를 저장할 리스트
    crawled_data = []

    try:
        signal.signal(signal.SIGALRM, timeout_handler)
        signal.alarm(870)  # 타임아웃 발생시간 1430

        # Lambda는 UTC 시간을 사용하므로, 한국 시간으로 변환
        utc_now = datetime.utcnow()
        kst_now = utc_now + timedelta(hours=9)
        today = kst_now.strftime("%Y%m%d")
        save_date = kst_now.strftime("%Y%m%d%H")

        # 웹 사이트 열기 (네이버 뉴스 금융 카테고리)
        URL = f"https://news.naver.com/breakingnews/section/101/259?date={today}"
        driver.get(URL)

        # "기사 더보기" 버튼이 없어질 때까지 모든 기사 load
        while True:
            try:
                load_more_button = WebDriverWait(driver, 10).until(
                    EC.visibility_of_element_located((By.CLASS_NAME, 'section_more_inner'))
                )

                # 기사 더보기 창이 없어지면 stop
                if "display: none;" in load_more_button.get_attribute('style'):
                    logger.info("모든 기사 로딩 완료")
                    break

                driver.execute_script("arguments[0].click();", load_more_button)
                time.sleep(2)

            except Exception as e:
                logger.info("더 이상 '기사 더보기' 버튼을 찾을 수 없습니다. 에러: %s", str(e))
                break

        # 모든 기사 요소 찾기
        max_div_index = len(driver.find_elements(By.XPATH, '//*[@id="newsct"]/div[2]/div/div[1]/div'))

        for idx in range(1, max_div_index + 1):
            for li in range(1, 7):  # li는 1부터 6까지
                try:
                    specific_article_xpath = f'//*[@id="newsct"]/div[2]/div/div[1]/div[{idx}]/ul/li[{li}]/div/div/div[2]/a/strong'
                    specific_article = WebDriverWait(driver, 10).until(
                        EC.visibility_of_element_located((By.XPATH, specific_article_xpath))
                    )

                    driver.execute_script("arguments[0].scrollIntoView(true);", specific_article)
                    time.sleep(1)

                    post_time = driver.find_element(By.CSS_SELECTOR, f'#newsct > div.section_latest > div > div.section_latest_article._CONTENT_LIST._PERSIST_META > div:nth-child({idx}) > ul > li:nth-child({li}) > div > div > div.sa_text > div.sa_text_info > div.sa_text_info_left > div.sa_text_datetime > b').text
                    if "분전" in post_time:
                        minutes_ago = int(post_time.split("분전")[0])
                        if not (1 <= minutes_ago <= 59):
                            logger.info("분 전 범위가 맞지 않음. 크롤링 종료.")
                            break
                    elif "시간전" in post_time:
                        hours_ago = int(post_time.split("시간전")[0])
                        if not (1 <= hours_ago <= 2):
                            logger.info("시간 전 범위가 맞지 않음. 크롤링 종료.")
                            break
                    else:
                        logger.info("시간 형식이 다름. 크롤링 종료.")
                        break

                    driver.execute_script("arguments[0].click();", specific_article)
                    time.sleep(2)

                    logger.info(f"성공적으로 클릭했습니다: div-{idx}, li-{li}")
                    title = driver.find_element(By.CSS_SELECTOR, '#title_area > span').text if driver.find_element(By.CSS_SELECTOR, '#title_area > span') else "null"
                    date = driver.find_element(By.CSS_SELECTOR, '#ct > div.media_end_head.go_trans > div.media_end_head_info.nv_notrans > div.media_end_head_info_datestamp > div:nth-child(1) > span').text if driver.find_element(By.CSS_SELECTOR, '#ct > div.media_end_head.go_trans > div.media_end_head_info.nv_notrans > div.media_end_head_info_datestamp > div:nth-child(1) > span') else "null"
                    content = driver.find_element(By.CSS_SELECTOR, 'article').text if driver.find_element(By.CSS_SELECTOR, 'article') else "null"
                    press_full_text = driver.find_element(By.CSS_SELECTOR, '#contents > div.copyright > div > p').text if driver.find_element(By.CSS_SELECTOR, '#contents > div.copyright > div > p') else "null"
                    press = press_full_text.split('ⓒ')[-1].split('.')[0].strip() if press_full_text != "null" else "null"
                    image_url = driver.find_element(By.CSS_SELECTOR, '#img1').get_attribute('src') if driver.find_element(By.CSS_SELECTOR, '#img1') else "null"

                    crawled_data.append({
                        "category": "금융",
                        "title": title,
                        "date": date,
                        "content": content,
                        "press": press,
                        "image_url": image_url
                    })

                    driver.back()
                    time.sleep(2)

                except (NoSuchElementException, SeleniumTimeoutException) as e:
                    logger.info(f"에러 발생: div-{idx}, li-{li}, 에러: {e}")
                    continue
                except ElementClickInterceptedException:
                    logger.info("클릭이 인터셉트되었습니다. 다시 시도합니다.")
                    time.sleep(2)

    except Exception as e:
        logger.warning(f"예외 발생: {str(e)}. 데이터를 S3에 저장합니다.")
    finally:
        driver.quit()
        # 크롤링된 데이터를 S3에 저장
        if crawled_data:
            save_to_s3(crawled_data, save_date)
        signal.alarm(0)

    return {
        "statusCode": 200,
        "body": "크롤링이 완료되었거나 타임아웃에 의해 종료되었습니다."
    }
