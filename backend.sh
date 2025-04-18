#!/bin/bash



USERID=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
LOGS_FOLDER="/var/log/expense-logs"    # create dir in linux server --$ mkdir shell-script-logs--

# only log file name logs
LOG_FILE=$(echo $0 | cut -d "," -f1)
TIMESTAMP=$(date +%Y-%m-%d-%H-%M-%S)
LOG_FILE_NAME="$LOG_FOLDER/$LOG_FILE-$TIMESTAMP.log"

VALIDATE(){
    dnf install mysql -y
    if [ $1 -ne 0 ]
    then 
        echo -e "$2 ... $R FAILURE $N"
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N"
    fi

}

CHECK_ROOT(){
    if [ $USERID -ne 0 ]
    then
        echo "ERROR:: you must have sudo access to execute this script" 
        exit 1 
    fi

}

echo " Script started executing at: $TIMESTAMP" &>>$LOG_FILE_NAME
    
CHECK_ROOT

dnf module disable nodejs -y &>>$LOG_FILE_NAME
VALIDATE $? "Disabling  nodejs module"

dnf module enable nodejs:20 -y &>>$LOG_FILE_NAME
VALIDATE $? "Enabling nodejs 20" 

dnf install nodejs -y &>>$LOG_FILE_NAME
VALIDATE $? "Installing nodjs"

if [ $? -ne 0 ]
then
    useradd expense &>>$LOG_FILE_NAME
    VALIDATE $? "Adding expense user"
else
    echo -e "expense user already exists .. $Y SKIPPING $N"
fi

mkdir -p /app &>>$LOG_FILE_NAME
VALIDATE $? "Creating app directory"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$LOG_FILE_NAME
VALIDATE $? "Downloading backend"

cd /app
rm -rf /app/* 

unzip /tmp/backend.zip &>>$LOG_FILE_NAME
VALIDATE $? "unzipping backend"

cd /app

npm install &>>$LOG_FILE_NAME
VALIDATE $? "installing npm dependency"

cp /home/ec2-user/expense-project-shell/backend.service vim /etc/systemd/system/backend.service

# PREPARE MYSQL SCHEEMAS

dnf install mysql -y &>>$LOG_FILE_NAME
VALIDATE $? "Installing MySQL Client"

mysql -h mysql.bsdaws82s.site -uroot -pExpenseApp@1 < /app/schema/backend.sql &>>$LOG_FILE_NAME
VALIDATE $? "Setting up the transactions scheema and tables"

systemctl daemon-reload &>>$LOG_FILE_NAME
VALIDATE $? "Daemon Reload"

systemctl enable backend &>>$LOG_FILE_NAME
VALIDATE $? "Enabling Backend"

systemctl start backend &>>$LOG_FILE_NAME
VALIDATE $? "Starting Backend"

systemctl restart backend &>>$LOG_FILE_NAME
VALIDATE $? "Restarting Backend"

