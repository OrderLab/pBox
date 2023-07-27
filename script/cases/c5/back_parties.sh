#!/bin/bash

for i in {1..50}
do
   now=$(date +"%s%N")
   mysql -S $PSANDBOX_MYSQL_DIR/mysqld.sock -e "use test;begin;select c  from sbtest1 limit 1;select sleep(20);commit;" >> /dev/null
   now1=$(date +"%s%N")
   echo "Time: $(( now1 - now))"
done
