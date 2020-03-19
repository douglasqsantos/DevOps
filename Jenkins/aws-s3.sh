#!/bin/bash

## Version: 0.1

DB_HOST=$1
DB_PASSWORD=$2
DB_NAME=$3
DB_USER=$4
AWS_SECRET=$5
BUCKET_NAME=$6
DATE=$(date +%F-%H-%M-%S)
BACKUP="db-${DATE}.sql"

## AWS S3
export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY

mysqldump -u ${DB_USER} -p${DB_PASSWORD} ${DB_NAME} -h ${DB_HOST} > /tmp/${BACKUP} && \
  echo "Uploading your db backup" && \
  aws s3 cp /tmp/${BACKUP} s3://${BUCKET_NAME}/${BACKUP}
