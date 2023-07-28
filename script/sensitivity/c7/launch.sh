#!/bin/bash
  
LOG_DIR="$(pwd)/../../../result/sensitivity/"

function psandbox {
  $POSTGRES_SYSBENCH_DIR/bin/sysbench  --pgsql-db=postgres --pgsql-user=$(whoami) --tables=1 --table-size=1000 --threads=1 --time=107  --percentile=50 $POSTGRES_SYSBENCH_DIR/share/sysbench/oltp_update_index.lua --report-interval=10 run &
  sleep 11
  cat ./back.sql | $PSANDBOX_POSTGRES_DIR/bin/psql postgres > /dev/null &
  echo "interference"
  sleep 90
  echo "interference end"
  sleep 20
}

mkdir -p $LOG_DIR/c7
cp ../../libpsandbox_psandbox.so $PSANDBOXDIR/build/libs/libpsandbox.so
for i in {1..5}
do
     echo postgres-$(($i*25))
     cp ../../bin/postgres-$(($i*25)) $PSANDBOX_POSTGRES_DIR/bin/postgres
     postgres -D $PSANDBOX_POSTGRES_DIR/data/ --config-file=$PSANDBOX_POSTGRES_DIR/data/postgresql.conf &
     sleep 2
     $POSTGRES_SYSBENCH_DIR/bin/sysbench  --pgsql-db=postgres --pgsql-user=$(whoami) --tables=1 --table-size=1000 --threads=1 --time=60 $POSTGRES_SYSBENCH_DIR/share/sysbench/oltp_update_index.lua cleanup >> /dev/null
     $POSTGRES_SYSBENCH_DIR/bin/sysbench  --pgsql-db=postgres --pgsql-user=$(whoami) --tables=1 --table-size=1000 --threads=1 --time=60 $POSTGRES_SYSBENCH_DIR/share/sysbench/oltp_update_index.lua prepare >> /dev/null
     psandbox > $LOG_DIR/c7/rule_$(($i*25)).log
     pkill postgres
     sleep 5
done

