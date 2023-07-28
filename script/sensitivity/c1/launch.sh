#!/bin/bash

LOG_DIR="$(pwd)/../../../result/sensitivity/"

if [ $# -eq 0 ]
  then
    echo "No arguments supplied"
fi

function psandbox {
  sysbench --mysql-socket=$PSANDBOX_MYSQL_DIR/mysqld.sock --mysql-db=test --tables=1 --table-size=100000 --threads=1 --time=117 --percentile=50  --report-interval=10 $SYSBEN_DIR/oltp_update_index.lua run &
  sleep 8
   ./back.sh >> /dev/null & 
  sleep 3
  echo "interference"
  sleep 90
  echo "interference end"
  sleep 20
}

mkdir -p $LOG_DIR/c1
cp ../../libpsandbox_psandbox.so $PSANDBOXDIR/build/libs/libpsandbox.so
for i in {1..5}
do
     echo mysqld-$(($i*25))
     cp ../../bin/mysqld-$(($i*25)) $PSANDBOX_MYSQL_DIR/bin/mysqld
     mysqld --defaults-file=../mysql.cnf &
     sleep 5
     sysbench --mysql-socket=$PSANDBOX_MYSQL_DIR/mysqld.sock --mysql-db=test --tables=1 --table-size=100000 --threads=1 --time=65 $SYSBEN_DIR/oltp_update_index.lua cleanup >> /dev/null
     sysbench --mysql-socket=$PSANDBOX_MYSQL_DIR/mysqld.sock --mysql-db=test --tables=1 --table-size=100000 --threads=1 --time=65 $SYSBEN_DIR/oltp_update_index.lua prepare >> /dev/null
     psandbox > $LOG_DIR/c1/rule_$(($i*25)).log
     mysqladmin -S $PSANDBOX_MYSQL_DIR/mysqld.sock -u root shutdown
     sleep 10
done


