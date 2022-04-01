#!/bin/sh

CURRENT=$(cd $(dirname $0);pwd)
cd $CURRENT



echo "DB接続の設定ファイル作成ウィザード Start"

echo "まずDBをダンプバックアップバッチを作ります。"

echo 'プロジェクト名(サービス名)を教えてください。S3バケットの名前に使います。${PJ_NAME}-backup-${ENV}'
read PJ_NAME

echo "環境を教えて下さい"
echo "develop/staging/production"
read ENV

if [ ${ENV} = "develop" ]
then
  : # 何もしない
elif [ ${ENV} = "staging" ]
then
  : # 何もしない
elif [ ${ENV} = "production" ]
then
  : # 何もしない
else
  echo "Error:想定しない値。develop or staging or production を選択してください"
  exit 1
fi

echo "DBの接続先はreader(slave)ですか、それともwriter(master)かを教えて下さい"
echo "reader/writer"
read READER_OR_WRITER

if [ ${READER_OR_WRITER} = "reader" ]
then
  : # 何もしない
elif [ ${READER_OR_WRITER} = "writer" ]
then
  : # 何もしない
else
  echo "Error:想定しない値。reader or writerを選択してください"
  exit 1 
fi

echo "DBの名前を入力してください。例) sampledb"
read DB_NAME

echo "DBのuser名を入力してください。例) admin"
read DB_USER

echo "DBの${READER_OR_WRITER}_endpoint(host)を入力してください。例) sample-db.cluster-xxxxxxx.ap-northeast-1.rds.amazonaws.com "
read DB_HOST

echo "DBのpasswordを入力してください。例) p@sSw0rd"
read DB_PASSWORD

echo "こちらで正しいですか？設定ファイルが既に存在する場合は上書きされます。"
echo "PJ_NAME:${PJ_NAME}"
echo "ENV:${ENV}"
echo "READER_OR_WRITER:${READER_OR_WRITER}"
echo "DB_NAME:${DB_NAME}"
echo "DB_USER:${DB_USER}"
echo "DB_HOST:${DB_HOST}"
echo "DB_PASSWORD:${DB_PASSWORD}"
echo "----------------------------"
echo "yes/no"
read IS_OK

if [ ! ${IS_OK} = "yes" ] ; then
  echo "ウィザードを中止します。"
  exit 1
fi

PROFILE_FILE_READER="./profiles/${DB_NAME}_${READER_OR_WRITER}.conf"
BATCH_DUMPDB_FILE="./batches/${DB_NAME}/dumpdb.sh"
# ファイルが存在するか
if [ -e $PROFILE_FILE_READER ]; then
  cp /dev/null $PROFILE_FILE_READER
fi
if [ -e $BATCH_DUMPDB_FILE ]; then
  cp /dev/null $BATCH_DUMPDB_FILE
fi
echo $PROFILE_FILE_READER
touch $PROFILE_FILE_READER
echo "[client]" >> $PROFILE_FILE_READER
echo "user=${DB_USER}" >> $PROFILE_FILE_READER
echo "password=${DB_PASSWORD}" >> $PROFILE_FILE_READER
echo "host=${DB_HOST}" >> $PROFILE_FILE_READER
echo "MySQL接続ファイルを作成しました! ${PROFILE_FILE_READER}"
echo "----------------------------"
echo ""
mkdir -p ./batches/${DB_NAME}/
cp ./templates/dumpdb.sh ${BATCH_DUMPDB_FILE}
sed -i -e "s/@@@PJ_NAME@@@/${PJ_NAME}/g" $BATCH_DUMPDB_FILE
sed -i -e "s/@@@ENV@@@/${ENV}/g" $BATCH_DUMPDB_FILE
sed -i -e "s/@@@DB_NAME@@@/${DB_NAME}/g" $BATCH_DUMPDB_FILE
sed -i -e "s/@@@READER_OR_WRITER@@@/${READER_OR_WRITER}/g" $BATCH_DUMPDB_FILE
echo "DBダンプバッチを作成しました! ${BATCH_DUMPDB_FILE}"
echo ""
echo ""
echo "WriterインスタンスからbinlogをS3にバックアップするバッチを作成しますか？"
echo "yes/no"
read IS_OK

if [ ! ${IS_OK} = "yes" ] ; then
  echo "ウィザードを中止します。"
  exit 1
fi

echo "DBのwriter_endpoint(host)を入力してください。例) sample-db.cluster-xxxxxxx.ap-northeast-1.rds.amazonaws.com "
read DB_HOST
PROFILE_FILE_WRITER="./profiles/${DB_NAME}_writer.conf"
BATCH_BACKUP_BINLOG="./batches/${DB_NAME}/backupBinlogToS3.sh"

# ファイルが存在するか
if [ -e $PROFILE_FILE_WRITER ]; then
  cp /dev/null $PROFILE_FILE_WRITER
fi
if [ -e $BATCH_BACKUP_BINLOG ]; then
  cp /dev/null $BATCH_BACKUP_BINLOG
fi
echo $PROFILE_FILE_WRITER
touch $PROFILE_FILE_WRITER
echo "[client]" >> $PROFILE_FILE_WRITER
echo "user=${DB_USER}" >> $PROFILE_FILE_WRITER
echo "password=${DB_PASSWORD}" >> $PROFILE_FILE_WRITER
echo "host=${DB_HOST}" >> $PROFILE_FILE_WRITER
echo "MySQL接続ファイルを作成しました! ${PROFILE_FILE_WRITER}"
echo "----------------------------"
echo ""
cp ./templates/backupBinlogToS3.sh ${BATCH_BACKUP_BINLOG}
sed -i -e "s/@@@PJ_NAME@@@/${PJ_NAME}/g" $BATCH_BACKUP_BINLOG
sed -i -e "s/@@@ENV@@@/${ENV}/g" $BATCH_BACKUP_BINLOG
sed -i -e "s/@@@DB_NAME@@@/${DB_NAME}/g" $BATCH_BACKUP_BINLOG
echo "binlogバックアップバッチを作成しました! ${BATCH_BACKUP_BINLOG}"
echo ""
echo ""


echo "バックアップ先のS3からbinlogをダウンロードするバッチを作成しますか？"
echo "yes/no"
read IS_OK

if [ ! ${IS_OK} = "yes" ] ; then
  echo "ウィザードを中止します。"
  exit 1
fi

BATCH_DOWNLOAD_BINLOG="./batches/${DB_NAME}/downloadBinlogFromS3.sh"
if [ -e $BATCH_DOWNLOAD_BINLOG ]; then
  cp /dev/null $BATCH_DOWNLOAD_BINLOG
fi
cp ./templates/downloadBinlogFromS3.sh $BATCH_DOWNLOAD_BINLOG
sed -i -e "s/@@@PJ_NAME@@@/${PJ_NAME}/g" $BATCH_DOWNLOAD_BINLOG
sed -i -e "s/@@@ENV@@@/${ENV}/g" $BATCH_DOWNLOAD_BINLOG
sed -i -e "s/@@@DB_NAME@@@/${DB_NAME}/g" $BATCH_DOWNLOAD_BINLOG

echo "DB接続の設定ファイル作成ウィザード End"
