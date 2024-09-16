import os
import json
import time
import logging
from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import NoSuchElementException, TimeoutException, ElementClickInterceptedException
from datetime import datetime, timedelta

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger()

def handler(event, context):
    chrome_options = Options()
    chrome_options.binary_location = "/opt/chrome/chrome"
    chrome_options.add_argument("--headless")
    chrome_options.add_argument("--no-sandbox")
    chrome_options.add_argument("--single-process")
    chrome_options.add_argument("--disable-dev-shm-usage")
    chrome_options.add_argument("user-agent=Mozilla/5.0 (Windows NT 6.1; WOW64; Trident/7.0; rv:11.0) like Gecko")
    chrome_options.add_argument('window-size=1392x1150')
    chrome_options.add_argument("disable-gpu")
    
    service = Service(executable_path="/opt/chromedriver")
    driver = webdriver.Chrome(service=service, options=chrome_options)

    try:
        # Lambda는 UTC 시간을 사용하므로, 한국 시간으로 변환
        utc_now = datetime.utcnow()
        kst_now = utc_now + timedelta(hours=9)
        today = kst_now.strftime("%Y%m%d")
        
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
                    print("모든 기사 로딩 완료")
                    break

                driver.execute_script("arguments[0].click();", load_more_button)
                time.sleep(2)  # 페이지 로딩 시간을 기다리기 위해 대기

            except Exception as e:
                print("더 이상 '기사 더보기' 버튼을 찾을 수 없습니다.", e)
                break

        # 모든 기사 요소 찾기
        articles = driver.find_elements(By.CSS_SELECTOR, '#newsct > div.section_latest > div > div.section_latest_article._CONTENT_LIST._PERSIST_META > div > ul > li')

        # 최대 div 인덱스 계산 (현재 페이지에 로드된 div 그룹 수)
        max_div_index = len(driver.find_elements(By.XPATH, '//*[@id="newsct"]/div[2]/div/div[1]/div'))

        # 각 div와 li 요소를 탐색하며 기사 상세 보기 클릭
        for idx in range(1, max_div_index + 1):
            for li in range(1, 7):  # li는 1부터 6까지
                try:
                    # 주어진 선택자를 사용하여 특정 기사 요소를 찾기
                    specific_article_xpath = f'//*[@id="newsct"]/div[2]/div/div[1]/div[{idx}]/ul/li[{li}]/div/div/div[2]/a/strong'
                    specific_article = WebDriverWait(driver, 10).until(
                        EC.visibility_of_element_located((By.XPATH, specific_article_xpath))
                    )
                    
                    # 요소가 화면에 보이도록 스크롤
                    driver.execute_script("arguments[0].scrollIntoView(true);", specific_article)
                    time.sleep(1)  # 스크롤 후 잠시 대기
                    
                    # 시간 크롤링
                    post_time = driver.find_element(By.CSS_SELECTOR, f'#newsct > div.section_latest > div > div.section_latest_article._CONTENT_LIST._PERSIST_META > div:nth-child({idx}) > ul > li:nth-child({li}) > div > div > div.sa_text > div.sa_text_info > div.sa_text_info_left > div.sa_text_datetime > b').text

                    # 시간 조건 체크: "1 ~ 59분 전" 또는 "1 ~ 2시간 전" 범위에 있는 경우만 진행
                    if "분전" in post_time:
                        minutes_ago = int(post_time.split("분전")[0])
                        if not (1 <= minutes_ago <= 59):  # "1분 전" ~ "59분 전"
                            break
                    elif "시간전" in post_time:
                        hours_ago = int(post_time.split("시간전")[0])
                        if not (1 <= hours_ago <= 2):  # "1시간 전" ~ "2시간 전"
                            logger.info("시간 조건 밖 크롤링 종료")
                            break
                    else:
                        logger.info("시간 형식이 다름 다음 기사")
                        continue
                    
                    driver.execute_script("arguments[0].click();", specific_article) # 자세히 보기 클릭
                    time.sleep(5)
                    logger.info(f"성공적으로 클릭했습니다: div-{idx}, li-{li}")
                    
                    try:
                        title = driver.find_element(By.CSS_SELECTOR, '#title_area > span').text
                    except NoSuchElementException:
                        title = "null"

                    try:
                        date = driver.find_element(By.CSS_SELECTOR, '#ct > div.media_end_head.go_trans > div.media_end_head_info.nv_notrans > div.media_end_head_info_datestamp > div:nth-child(1) > span').text
                    except NoSuchElementException:
                        date = "null"

                    try:
                        content = driver.find_element(By.CSS_SELECTOR, 'article').text
                    except NoSuchElementException:
                        content = "본문 없음"

                    try:
                        press_full_text = driver.find_element(By.CSS_SELECTOR, '#contents > div.copyright > div > p').text
                        press = press_full_text.split('ⓒ')[-1].split('.')[0].strip()
                    except NoSuchElementException:
                        press = "null"

                    try:
                        image_url = driver.find_element(By.CSS_SELECTOR, '#img1').get_attribute('src')
                    except NoSuchElementException:
                        image_url = "null"

                    logger.info(f"제목: {title}\n날짜: {date}\n본문: {content}\n신문사: {press}\n이미지 URL: {image_url}\n")

                    # 이전 페이지로 돌아가기
                    driver.back()
                    time.sleep(2)

                except (NoSuchElementException, TimeoutException) as e:
                    logger.info(f"상세보기 클릭 에러 발생: div-{idx}, li-{li}, 에러: {e}")
                    continue
                except ElementClickInterceptedException:
                    logger.info("클릭이 인터셉트되었습니다. 다시 시도합니다.")
                    time.sleep(2)

    finally:
        driver.quit()

    return {
        "statusCode": 200,
        "body": "크롤링이 완료되었습니다."
    }
