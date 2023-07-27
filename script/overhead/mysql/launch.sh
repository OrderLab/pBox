#!/bin/bash

LOG_DIR="$(pwd)/../../../result/overhead/"

function write_run() {
    sysbench --mysql-socket=$PSANDBOX_MYSQL_DIR/mysqld.sock --mysql-db=test --tables=$1 --table-size=1000 --threads=$2 --percentile=99 --time=$3 $SYSBEN_DIR/oltp_update_index.lua --report-interval=10 run
 }
 
function read_run() {
    sysbench --mysql-socket=$PSANDBOX_MYSQL_DIR/mysqld.sock --mysql-db=test --tables=$1 --table-size=1000 --threads=$2 --percentile=99 --time=$3 $SYSBEN_DIR/oltp_point_select.lua --report-interval=10 run
}


if [[ $1 == 0 ]]; then
    echo "run normal"
    cp ../../libpsandbox.so $PSANDBOXDIR/build/libs/libpsandbox.so
elif [[ $1 == 1 ]]; then
   echo "run psandbox"
   cp ../../libpsandbox.so $PSANDBOXDIR/build/libs/libpsandbox.so
fi

mkdir -p $LOG_DIR/mysql
mysqld --defaults-file=mysql.cnf &
sleep 5

if [[ $2 == 0 ]]; then
    if [[ $1 == 0 ]]; then
        sysbench --mysql-socket=$PSANDBOX_MYSQL_DIR/mysqld.sock --mysql-db=test --tables=64 --table-size=1000 --threads=1 $SYSBEN_DIR/oltp_update_index.lua cleanup >> /dev/null
    	sysbench --mysql-socket=$PSANDBOX_MYSQL_DIR/mysqld.sock --mysql-db=test --tables=64 --table-size=1000 --threads=1 $SYSBEN_DIR/oltp_update_index.lua prepare >> /dev/null
	write_run $3 $4 $5 > $LOG_DIR/mysql/write_$4.log
    elif [[ $1 == 1 ]]; then
 	sysbench --mysql-socket=$PSANDBOX_MYSQL_DIR/mysqld.sock --mysql-db=test --tables=64 --table-size=1000 --threads=1 $SYSBEN_DIR/oltp_update_index.lua cleanup >> /dev/null
    	sysbench --mysql-socket=$PSANDBOX_MYSQL_DIR/mysqld.sock --mysql-db=test --tables=64 --table-size=1000 --threads=1 $SYSBEN_DIR/oltp_update_index.lua prepare >> /dev/null
    	mysqladmin -S $PSANDBOX_MYSQL_DIR/mysqld.sock -u root shutdown
    	cp ../../libpsandbox_psandbox.so $PSANDBOXDIR/build/libs/libpsandbox.so
   	mysqld --defaults-file=mysql.cnf &
   	sleep 5
	write_run $3 $4 $5 > $LOG_DIR/mysql/psandbox_write_$4.log
    fi
elif [[ $2 == 1 ]]; then
    if [[ $1 == 0 ]]; then
       	sysbench --mysql-socket=$PSANDBOX_MYSQL_DIR/mysqld.sock --mysql-db=test --tables=64 --table-size=1000 --threads=1 $SYSBEN_DIR/oltp_update_index.lua cleanup >> /dev/null
    	sysbench --mysql-socket=$PSANDBOX_MYSQL_DIR/mysqld.sock --mysql-db=test --tables=64 --table-size=1000 --threads=1 $SYSBEN_DIR/oltp_update_index.lua prepare >> /dev/null
        read_run $3 $4 $5 > $LOG_DIR/mysql/read_$4.log
    elif [[ $1 == 1 ]]; then
	sysbench --mysql-socket=$PSANDBOX_MYSQL_DIR/mysqld.sock --mysql-db=test --tables=64 --table-size=1000 --threads=1 $SYSBEN_DIR/oltp_point_select.lua cleanup >> /dev/null
    	sysbench --mysql-socket=$PSANDBOX_MYSQL_DIR/mysqld.sock --mysql-db=test --tables=64 --table-size=1000 --threads=1 $SYSBEN_DIR/oltp_point_select.lua prepare >> /dev/null
    	mysqladmin -S $PSANDBOX_MYSQL_DIR/mysqld.sock -u root shutdown
    	cp ../../libpsandbox_psandbox.so $PSANDBOXDIR/build/libs/libpsandbox.so
   	mysqld --defaults-file=mysql.cnf &
   	sleep 5
	read_run $3 $4 $5 > $LOG_DIR/mysql/psandbox_read_$4.log
    fi
fi
mysqladmin -S $PSANDBOX_MYSQL_DIR/mysqld.sock -u root shutdown
sleep 10
