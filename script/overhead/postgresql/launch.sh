#!/bin/bash

LOG_DIR="$(pwd)/../../../result/overhead/"

function write_run() {
    $POSTGRES_SYSBENCH_DIR/bin/sysbench  --pgsql-db=postgres --pgsql-user=$(whoami) --tables=$1 --table-size=1000 $POSTGRES_SYSBENCH_DIR/share/sysbench/oltp_insert.lua cleanup >> /dev/null
    $POSTGRES_SYSBENCH_DIR/bin/sysbench  --pgsql-db=postgres --pgsql-user=$(whoami) --tables=$1 --table-size=1000 $POSTGRES_SYSBENCH_DIR/share/sysbench/oltp_insert.lua prepare >> /dev/null
    $POSTGRES_SYSBENCH_DIR//bin/sysbench  --pgsql-db=postgres --pgsql-user=$(whoami) --tables=$1 --table-size=1000 --threads=$2 --percentile=99 --time=$3 $POSTGRES_SYSBENCH_DIR/share/sysbench/oltp_insert.lua --report-interval=10 run

 }
 
function read_run() {
    $POSTGRES_SYSBENCH_DIR/bin/sysbench  --pgsql-db=postgres --pgsql-user=$(whoami)  --tables=$1 --table-size=1000 $POSTGRES_SYSBENCH_DIR/share/sysbench/oltp_update_index.lua cleanup >> /dev/null
    $POSTGRES_SYSBENCH_DIR/bin/sysbench  --pgsql-db=postgres --pgsql-user=$(whoami)  --tables=$1 --table-size=1000 $POSTGRES_SYSBENCH_DIR/share/sysbench/oltp_update_index.lua prepare >> /dev/null
    $POSTGRES_SYSBENCH_DIR/bin/sysbench  --pgsql-db=postgres --pgsql-user=$(whoami)  --tables=$1 --table-size=1000 --threads=$2 --percentile=99 --time=$3 $POSTGRES_SYSBENCH_DIR/share/sysbench/select_random_points.lua --report-interval=10 run
}


if [[ $1 == 0 ]]; then
    echo "run normal"
    cp ../../libpsandbox.so $PSANDBOXDIR/build/libs/libpsandbox.so
elif [[ $1 == 1 ]]; then
   echo "run psandbox"
   cp ../../libpsandbox_psandbox.so $PSANDBOXDIR/build/libs/libpsandbox.so
fi

mkdir -p $LOG_DIR/postgresql
postgres -D $PSANDBOX_POSTGRES_DIR/data/ --config-file=$PSANDBOX_POSTGRES_DIR/data/postgresql.conf &
sleep 5

if [[ $2 == 0 ]]; then
    if [[ $1 == 0 ]]; then
        write_run $3 $4 $5 > $LOG_DIR/postgresql/write_$4.log
    elif [[ $1 == 1 ]]; then
	write_run $3 $4 $5 > $LOG_DIR/postgresql/psandbox_write_$4.log
    fi
elif [[ $2 == 1 ]]; then
    if [[ $1 == 0 ]]; then
        read_run $3 $4 $5 > $LOG_DIR/postgresql/read_$4.log
    elif [[ $1 == 1 ]]; then
	read_run $3 $4 $5 > $LOG_DIR/postgresql/psandbox_read_$4.log
    fi
fi
pkill -9 postgres
sleep 10
