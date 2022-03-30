#!/bin/bash

# 未定義変数、エラーで処理を止める
set -eux

CURRENT=$(cd $(dirname $0);pwd)
cd $CURRENT

#########
ENV=develop
APP_NAME=sampleapp
DB_NAME=sampledb
DB_PROFILE_PATH=./profiles/${DB_NAME}.conf
S3_BUCKET_PATH=s3://${APP_NAME}-backup-${ENV}/database/${DB_NAME}/dump
#########

# 日付セット
DAY=`date "+%Y%m%d_%Hh"`
# ダンプファイル名
DUMP_FILE_NAME=${DB_NAME}-${DAY}.dump

mkdir -p ~/.batch/backup/database/
# dump 取得
mysqldump --defaults-extra-file=${DB_PROFILE_PATH} --routines=0 --triggers=0 --events=0  --set-gtid-purged=OFF --single-transaction -B ${DB_NAME} > ~/.batch/backup/database/${DUMP_FILE_NAME}

# 圧縮
gzip -f ~/.batch/backup/database/${DUMP_FILE_NAME}

# 4日以上前のバックアップは消す
find ~/.batch/backup/database/ -mtime +4 -exec rm -f {} \;

# S3と同期
aws s3 sync ~/.batch/backup/database/ ${S3_BUCKET_PATH}/ --delete
