#!/bin/bash

for i in {1..20000}
do
   now=$(date +"%s%N")
   mysql -S $PSANDBOX_MYSQL_DIR/mysqld.sock -e "use test;select count(*) from sbtest$1 where id < 1000 for update;" >> /dev/null
   now1=$(date +"%s%N")
   echo "Time: $(( now1 - now))"
done
