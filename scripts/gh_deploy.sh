# bash shell 사용 정의
#!/bin/bash
# appspec.yml에서 destination에 정의
PROJECT_NAME="github_action"
# gradle 로 스프링 프로젝트로 build를 하면 Jar 생성이 되는데 그 위치
JAR_PATH="/home/ubuntu/github_action/build/libs/*.jar"
DEPLOY_PATH=/home/ubuntu/$PROJECT_NAME/
# 배포하면서 로그로 저장
DEPLOY_LOG_PATH="/home/ubuntu/$PROJECT_NAME/deploy.log"
# 배포하면서 error가 발생하면 왜인지 이유파악 가능
DEPLOY_ERR_LOG_PATH="/home/ubuntu/$PROJECT_NAME/deploy_err.log"
# 어플리케이션 로그 저장
APPLICATION_LOG_PATH="/home/ubuntu/$PROJECT_NAME/application.log"
BUILD_JAR=$(ls $JAR_PATH)
JAR_NAME=$(basename $BUILD_JAR)

echo "===== 배포 시작 : $(date +%c) =====" >> $DEPLOY_LOG_PATH

echo "> build 파일명: $JAR_NAME" >> $DEPLOY_LOG_PATH
echo "> build 파일 복사" >> $DEPLOY_LOG_PATH
cp $BUILD_JAR $DEPLOY_PATH

# 동일한 Port로 똑같이 배포하면 안되기 때문에 확인
echo "> 현재 동작중인 어플리케이션 pid 체크" >> $DEPLOY_LOG_PATH
CURRENT_PID=$(pgrep -f $JAR_NAME)

if [ -z $CURRENT_PID ]
then
  echo "> 현재 동작중인 어플리케이션 존재 X" >> $DEPLOY_LOG_PATH
else
  echo "> 현재 동작중인 어플리케이션 존재 O" >> $DEPLOY_LOG_PATH
  echo "> 현재 동작중인 어플리케이션 강제 종료 진행" >> $DEPLOY_LOG_PATH
  echo "> kill -9 $CURRENT_PID" >> $DEPLOY_LOG_PATH
  kill -9 $CURRENT_PID
fi

DEPLOY_JAR=$DEPLOY_PATH$JAR_NAME
echo "> DEPLOY_JAR 배포" >> $DEPLOY_LOG_PATH
# nohup과 &로 인해서 백그라운드에서 실행시킬 수 있음
nohup java -jar $DEPLOY_JAR >> $APPLICATION_LOG_PATH 2> $DEPLOY_ERR_LOG_PATH &

sleep 3

# 배포시간 체킹
echo "> 배포 종료 : $(date +%c)" >> $DEPLOY_LOG_PATH