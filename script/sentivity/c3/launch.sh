#!/bin/bash

LOG_DIR="$(pwd)/../../../result/sensitivity/"

function psandbox {
  sysbench --mysql-socket=$PSANDBOX_MYSQL_DIR/mysqld.sock --mysql-db=test --tables=1 --table-size=1000 --threads=1 --time=117 --percentile=50 --report-interval=10  $SYSBEN_DIR/oltp_point_select.lua run & 
  sleep 1
  for i in {2..6}
  do
    ./back.sh $i | mysql -S $PSANDBOX_MYSQL_DIR/mysqld.sock  > /dev/null &
  done
  sleep 10
  echo "interference"
  sleep 90
  echo "interference end" 
  sleep 10
}

mkdir -p $LOG_DIR/c3
cp ../../libpsandbox_psandbox.so $PSANDBOXDIR/build/libs/libpsandbox.so
for i in {1..5}
do
  if [[ $i != 2 ]]; then
    echo mysqld-$(($i*25))
    cp ../bin/mysqld-$(($i*25)) $PSANDBOX_MYSQL_DIR/bin/mysqld
    mysqld --defaults-file=../mysql.cnf &
    sleep 5
    sysbench --mysql-socket=$PSANDBOX_MYSQL_DIR/mysqld.sock --mysql-db=test --tables=5 --table-size=1000 --threads=1 --time=65 $SYSBEN_DIR/oltp_update_index.lua cleanup >> /dev/null
    sysbench --mysql-socket=$PSANDBOX_MYSQL_DIR/mysqld.sock --mysql-db=test --tables=5 --table-size=1000 --threads=1 --time=65 $SYSBEN_DIR/oltp_update_index.lua prepare >> /dev/null
    psandbox > $LOG_DIR/c3/rule_$(($i*25)).log
    mysqladmin -S $PSANDBOX_MYSQL_DIR/mysqld.sock -u root shutdown
    sleep 10
  fi
done


