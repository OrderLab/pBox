#!/bin/bash

for i in {1..90}
do
   now=$(date +"%s%N")
   mysql -S $PSANDBOX_MYSQL_DIR/mysqld.sock -e "use test;select count(*) from sbtest1 LOCK IN SHARE MODE;" >> /dev/null
   now1=$(date +"%s%N")
   echo "Time: $(( now1 - now))"
done

