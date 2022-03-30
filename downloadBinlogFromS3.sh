#!/bin/bash

# 実行したコマンドを標準エラーに出力
set -eux

CURRENT=$(cd $(dirname $0);pwd)
cd $CURRENT

# ----------------------------------------------
ENV=develop
APP_NAME=sampleapp
S3_BUCKET_NAME=${APP_NAME}-backup-${ENV}
DB_NAME=sampledb
ENV=develop
STORAGE_DIR=./download/${DB_NAME}/binlog/
S3_DIR=s3://${S3_BUCKET_NAME}/database/${DB_NAME}/binlog/
# ----------------------------------------------

# 既存データ削除
rm -rf ${STORAGE_DIR}/*
# ディレクトリ作成
mkdir -p ${STORAGE_DIR}

# S3からbinlogをダウンロード
aws s3 sync ${S3_DIR} ${STORAGE_DIR}


