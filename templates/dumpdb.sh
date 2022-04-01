#!/bin/bash

# 未定義変数、エラーで処理を止める
set -eux

CURRENT=$(cd $(dirname $0);pwd)
cd $CURRENT

########
PJ_NAME=@@@PJ_NAME@@@
ENV=@@@ENV@@@
DB_NAME=@@@DB_NAME@@@
READER_OR_WRITER=@@@READER_OR_WRITER@@@

DB_PROFILE_PATH=../../profiles/${DB_NAME}_${READER_OR_WRITER}.conf
S3_BUCKET_NAME="${PJ_NAME}-backup-${ENV}"
DAY=`date "+%Y%m%d"`
DATE=`date "+%Y%m%d_%Hh"`
S3_BUCKET_PATH=s3://${S3_BUCKET_NAME}/database/${DB_NAME}/dump/${DAY}
#########

# ダンプファイル名
DUMP_FILE_NAME=${DB_NAME}-${DATE}.dump
TEMP_PATH="${HOME}/.batch/backup/database/${DB_NAME}/${DAY}"
mkdir -p ${TEMP_PATH}

# dump 取得
mysqldump --defaults-extra-file=${DB_PROFILE_PATH} \
        --routines=0 \
        --triggers=0 \
        --events=0  \
        --set-gtid-purged=OFF \
        --skip-column-statistics \
        --no-tablespaces \
        --single-transaction \
        -B ${DB_NAME} > ${TEMP_PATH}/${DUMP_FILE_NAME}

# 圧縮
gzip -f ${TEMP_PATH}/${DUMP_FILE_NAME}

# 4日以上前のバックアップは消す
find ${TEMP_PATH}/ -mtime +4 -exec rm -f {} \;

# S3と同期
aws s3 sync ${TEMP_PATH}/ ${S3_BUCKET_PATH}/ --delete
