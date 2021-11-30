#!/bin/bash

CURRENT=$(cd $(dirname $0);pwd)
cd $CURRENT

RECOVERY_SQL_FILES="./recoverySql/*.sql"


for filepath in ${RECOVERY_SQL_FILES}; do
  sed -i -e '/DEFINER/d' $filepath
  sed -i -e '/session.pseudo_thread_id/d' $filepath
  sed -i -e '/PSEUDO/d' $filepath
  sed -i -e '/GTID/d' $filepath

  echo $filepath renovate Done!
done
