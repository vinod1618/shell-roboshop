#!/bin/bash

USERID=$(id -u)
LOGS_FOLDER="/var/log/shell-roboshop"
LOGS_FILE="$LOGS_FOLDER/$0.log"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
SCRIPT_DIREC=$PWD
MONGO_DB_HOST=mongodb.vinoddevops.online

if [ $USERID -ne 0 ]; then
    echo -e "$R Please run this script with root user access $N" | tee -a $LOGS_FILE
    exit 1
fi

mkdir -p $LOGS_FOLDER

VALIDATE(){
    if [ $1 -ne 0 ]; then
        echo -e "$2 ... $R FAILURE $N" | tee -a $LOGS_FILE
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N" | tee -a $LOGS_FILE
    fi
}
dnf module disable nodejs -y &>>$LOGS_FILE
VALIDATE $? "Disabling noeje default"

dnf module enable nodejs:20 -y  &>>$LOGS_FILE
VALIDATE $? "Enabling node js 20"

dnf install nodejs -y  &>>$LOGS_FILE
VALIDATE $? "Installing nodejs 20"

id roboshop &>>$LOGS_FILE
 if [ $? -ne 0 ]; then
  useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop  &>>$LOGS_FILE
  VALIDATE $? "Creating system user"
 else
  echo "roboshop user already exists $Y skipping $Y"
 fi

mkdir -p /app  &>>$LOGS_FILE
VALIDATE $? "Creating app directory"

curl -o /tmp/cart.zip https://roboshop-artifacts.s3.amazonaws.com/cart-v3.zip  &>>$LOGS_FILE
VALIDATE $? "Downloading the catalouge code"

cd /app 
VALIDATE $? "entering into app directory"

rm -rf /app/*
VALIDATE $? "Removing the existing code"

unzip /tmp/cart.zip
VALIDATE VALIDATE $? "unzip the code"


cd /app 
VALIDATE $? "entering into app directory"

npm install 
VALIDATE $? "installing dependency libraries"

cp $SCRIPT_DIREC/catalouge.service /etc/systemd/system/cart.service
VALIDATE $? "created system control service"

systemctl daemon-reload
VALIDATE $? "demon reload"

systemctl enable cart 
VALIDATE $? "enable cart"

systemctl start cart
VALIDATE $? "start cart is"