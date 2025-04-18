#!/bin/bash

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

SOURCE_DIR=$1
DEST_DIR=$2
DAYS=${3:-14} # if user is not providing number of days, we are taking 14 days as default

LOGS_FOLDER="/home/ec2-user/shellscript-logs"    # create dir in linux server --$ mkdir shell-script-logs--
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

USAGE(){
    echo -e "$R USAGE:: $N sh backups.sh <SOURCE_DIR> <DEST_DIR> <DAYS(optional)>"
    exit 1
}

mkdir -p /home/ec2-user/shellscript-logs

if [ $# -lt 2 ]
then
    USAGE
fi

if [ ! -d SOURCE_DIR ]
then
    echo -e "$SOURCE_DIR Does not exist...please check"
    exit 1
fi

fi [ ! -d DEST_DIR ]
then
    echo -e "$DEST_DIR Does not exist...please chek"
    exit 1
fi

echo " Script started executing at: $TIMESTAMP" &>>$LOG_FILE_NAME

FILES=$(find $SOURCE_DIR -name "*.log" -mtime +$DAYS)


if [ -n "$FILES" ]
then
    echo "Files are: $FILES"
else
    echo "no files found older than $DAYS"
fi



