#!/bin/bash

CURRENT=$(cd $(dirname $0);pwd)
cd $CURRENT

# ----------------------------------------------------------------------
S3_BUCKET_NAME=sample-db-binlog-925948485307
DB_HOST=test-database.cuwptkxjl3ng.ap-northeast-1.rds.amazonaws.com
DB_PASSWORD=hogehoge55
DB_USER=admin
DB_NAME=testdb

MAX_DOWNLOAD_BINLOG_COUNT=5
TEMP_DIR=./tmp_binlog/${DB_NAME}/
S3_DIR=s3://${S3_BUCKET_NAME}/${DB_NAME}/
# ----------------------------------------------------------------------


# 処理用ディレクトリ作成
mkdir -p ${TEMP_DIR}

# binlog取得
mysql -u ${DB_USER} --host=${DB_HOST} -p${DB_PASSWORD} -e 'show master logs' | grep mysql-bin | awk '{print $1}' > tmp_${DB_NAME}.txt
# 降順にする
binlog_files=`tac tmp_${DB_NAME}.txt`
rm -f tmp_${DB_NAME}.txt

# RDSからbinlogファイルのダウンロード 最新n件のみダウンロード
count=0
for binlog_file in $binlog_files
do
  eval 'mysqlbinlog --read-from-remote-server --host=${DB_HOST} --raw -u ${DB_USER} -p${DB_PASSWORD} --result-file=${TEMP_DIR}/ ${binlog_file}'
  echo ${binlog_file}
  count=`expr $count + 1`
  # 5ファイル取得で止める
  if [ $count -eq $MAX_DOWNLOAD_BINLOG_COUNT ]; then
    break
  fi
done

# S3にアップロード
aws s3api put-object --bucket ${S3_BUCKET_NAME} --key ${DB_NAME}/
echo ${TEMP_DIR}
echo ${S3_DIR}
aws s3 sync ${TEMP_DIR}/ ${S3_DIR}

#
rm -rf ${TEMP_DIR}/*

