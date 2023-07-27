#!/bin/bash
  
echo "run c5 psandbox"
SYSBEN_DIR="/home/yigonghu/software/sysbench/dist/share/sysbench/"
MYSQL_DIR="/home/yigonghu/software/mysql/dist/"
function a {
  sysbench --mysql-socket=$PSANDBOX_MYSQL_DIR/mysqld.sock --mysql-db=test --tables=1 --table-size=1 --threads=1 --time=108 $SYSBEN_DIR/oltp_update_index.lua run &
  sleep 1
  ./back_side.sh
}

mysqld --defaults-file=../my.cnf &
sleep 5
sysbench --mysql-socket=$PSANDBOX_MYSQL_DIR/mysqld.sock --mysql-db=test --tables=1 --table-size=1 --threads=1 --time=65 $SYSBEN_DIR/oltp_update_index.lua --report-interval=3 cleanup >> /dev/null
sysbench --mysql-socket=$PSANDBOX_MYSQL_DIR/mysqld.sock --mysql-db=test --tables=1 --table-size=1 --threads=1 --time=65 $SYSBEN_DIR/oltp_update_index.lua --report-interval=3 prepare >> /dev/null
a >> ../result/c5/psandbox.log
cd /home/yigonghu/software/mysql/dist
./bin/mysqladmin -S mysqld.sock -u root shutdown

