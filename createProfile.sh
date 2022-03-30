#!/bin/sh

echo "DBの名前を入力してください。例) sampledb"
read DB_NAME

echo "DBのuser名を入力してください。例) admin"
read DB_USER

echo "DBのhostを入力してください。例) sample-db.cluster-xxxxxxx.ap-northeast-1.rds.amazonaws.com "
read DB_HOST

echo "DBのpasswordを入力してください。例) p@sSw0rd"
read DB_PASSWORD

echo "こちらで正しいですか？"
echo "DB_NAME:${DB_NAME}"
echo "DB_USER:${DB_USER}"
echo "DB_HOST:${DB_HOST}"
echo "DB_PASSWORD:${DB_PASSWORD}"
echo "yes/no"
read IS_OK

if [ ${IS_OK} = "yes" ] ; then
  touch ./profiles/${DB_NAME}.conf
  echo "[client]" >> ./profiles/${DB_NAME}.conf
  echo "user=${DB_USER}" >> ./profiles/${DB_NAME}.conf
  echo "password=${DB_PASSWORD}" >> ./profiles/${DB_NAME}.conf
  echo "host=${DB_HOST}" >> ./profiles/${DB_NAME}.conf
  echo "ファイルを作成しました! ./profiles/${DB_NAME}.conf"
fi
