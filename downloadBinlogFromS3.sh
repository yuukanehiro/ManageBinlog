#!/bin/bash

CURRENT=$(cd $(dirname $0);pwd)
cd $CURRENT

# ----------------------------------------------
S3_BUCKET_NAME=sample-db-binlog-925948485307
DB_NAME=testdb
STORAGE_DIR=./download/${DB_NAME}/
S3_DIR=s3://${S3_BUCKET_NAME}/${DB_NAME}/
# ----------------------------------------------

# ディレクトリ作成
mkdir -p ${STORAGE_DIR}

# 既存データ削除
rm -rf ${STORAGE_DIR}/*

# S3からbinlogをダウンロード
aws s3 sync ${S3_DIR} ${STORAGE_DIR}

