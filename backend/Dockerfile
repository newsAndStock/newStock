# OpenJDK 17 이미지 사용
FROM openjdk:17-jdk-alpine

# 빌드 시 사용할 ARG 선언 
ARG JAR_FILE=build/libs/newstock-0.0.1-SNAPSHOT.jar

ARG PROFILES
ARG ENV

# 컨테이너 내의 /app 디렉토리를 작업 디렉토리로 설정
WORKDIR /app

# ARG로 받은 JAR 파일을 컨테이너의 app.jar로 복사
COPY ${JAR_FILE} app.jar

# 컨테이너 외부에서 접근할 포트 8080 열기
EXPOSE 8080

# 컨테이너 시작 시 애플리케이션 실행
ENTRYPOINT ["java", "-Dspring.profiles.active=${PROFILES}","-Dserver.env=${ENV}","-Dfile.encoding=UTF-8", "-jar", "app.jar"]
