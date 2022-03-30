#!/bin/bash

# 何かのエラーが発生した時点で、処理を中断
# 未定義の変数を使ったらエラー
# 実行したコマンドを標準エラーに出力
set -eux

CURRENT=$(cd $(dirname $0);pwd)
cd $CURRENT

# ----------------------------------------------------------------------
ENV=develop
APP_NAME=sampleapp
DB_NAME=sampledb
MAX_DOWNLOAD_BINLOG_COUNT=10

S3_BUCKET_NAME=${APP_NAME}-backup-${ENV}
DB_PROFILE_PATH=./profiles/${DB_NAME}.conf
TEMP_DIR=./tmp_binlog/${DB_NAME}
S3_DIR=s3://${S3_BUCKET_NAME}/database/${DB_NAME}/binlog
# ----------------------------------------------------------------------


# 処理用ディレクトリ作成
mkdir -p ${TEMP_DIR}

# binlog取得
mysql --defaults-extra-file=${DB_PROFILE_PATH} -e 'show master logs' | grep mysql-bin | awk '{print $1}' > tmp_${DB_NAME}.txt
# 降順にする
binlog_files=`tac tmp_${DB_NAME}.txt`
rm -f tmp_${DB_NAME}.txt

# RDSからbinlogファイルのダウンロード 最新n件のみダウンロード
count=0
for binlog_file in $binlog_files
do
  eval 'mysqlbinlog --defaults-extra-file=${DB_PROFILE_PATH} --read-from-remote-server --raw --result-file=${TEMP_DIR}/ ${binlog_file}'
  echo ${binlog_file}
  count=`expr $count + 1`
  # 5ファイル取得で止める
  if [ $count -eq $MAX_DOWNLOAD_BINLOG_COUNT ]; then
    break
  fi
done

# S3にアップロード
aws s3 sync ${TEMP_DIR}/ ${S3_DIR}/

# 削除
rm -rf ${TEMP_DIR}/*
