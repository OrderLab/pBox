#!/bin/bash

LOG_DIR="$(pwd)/../../../result/sensitivity/"

function psandbox {
  sysbench --mysql-socket=$PSANDBOX_MYSQL_DIR/mysqld.sock --mysql-db=test --tables=64 --table-size=1000 --threads=64 --time=160 --secondary=on  --percentile=99 $SYSBEN_DIR/oltp_insert.lua --report-interval=10 run &
  sleep 60
  echo "interference"
  sleep 90
  echo "interference end"
  sleep 11
}


mkdir -p $LOG_DIR/c2

for i in {1..5}
do
  if [[ $i != 2 ]]; then
    cp ../../libpsandbox.so $PSANDBOXDIR/build/libs/libpsandbox.so
    echo mysqld-$(($i*25))
    cp ../bin/mysqld-$(($i*25)) $PSANDBOX_MYSQL_DIR/bin/mysqld
    mysqld --defaults-file=../mysql.cnf  &
    sleep 5
    sysbench --mysql-socket=$PSANDBOX_MYSQL_DIR/mysqld.sock --mysql-db=test --tables=64 --table-size=1000 --threads=1 --secondary=on $SYSBEN_DIR/oltp_insert.lua cleanup >> /dev/null
    sysbench --mysql-socket=$PSANDBOX_MYSQL_DIR/mysqld.sock --mysql-db=test --tables=64 --table-size=1000 --threads=1 --secondary=on $SYSBEN_DIR/oltp_insert.lua prepare >> /dev/null
    mysqladmin -S $PSANDBOX_MYSQL_DIR/mysqld.sock -u root shutdown
    cp ../../libpsandbox_psandbox.so $PSANDBOXDIR/build/libs/libpsandbox.so
    mysqld --defaults-file=../mysql.cnf  &
    sleep 5
    psandbox > $LOG_DIR/c2/rule_$(($i*25)).log
    mysqladmin -S $PSANDBOX_MYSQL_DIR/mysqld.sock -u root shutdown
    sleep 10
  fi
done






