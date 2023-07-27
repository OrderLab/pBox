#!/bin/bash
  
LOG_DIR="$(pwd)/../../../result/sensitivity/"

function psandbox {
  $POSTGRES_SYSBENCH_DIR/bin/sysbench  --pgsql-db=postgres --pgsql-user=$(whoami) --tables=1 --table-size=1000 --threads=1 --time=100 --percentile=50 --report-interval=10 $POSTGRES_SYSBENCH_DIR/share/sysbench/oltp_update_index.lua run &
  sleep 2
  ./back.sh >> /dev/null  &
  echo "interference"
  sleep 90
  echo "interference end"
  sleep 10
}
mkdir -p $LOG_DIR/c8
cp ../../libpsandbox_psandbox.so $PSANDBOXDIR/build/libs/libpsandbox.so
for i in {1..5}
do
   if [[ $i != 2 ]]; then
     echo postgres-$(($i*25))
     cp ../bin/postgres-$(($i*25)) $PSANDBOX_POSTGRES_DIR/bin/postgres
     postgres -D $PSANDBOX_POSTGRES_DIR/data/ --config-file=$PSANDBOX_POSTGRES_DIR/data/postgresql.conf &
     sleep 5
     $POSTGRES_SYSBENCH_DIR/bin/sysbench  --pgsql-db=postgres --pgsql-user=$(whoami) --tables=1 --table-size=1000 $POSTGRES_SYSBENCH_DIR/share/sysbench/oltp_update_index.lua  cleanup >> /dev/null
     $POSTGRES_SYSBENCH_DIR/bin/sysbench  --pgsql-db=postgres --pgsql-user=$(whoami) --tables=1 --table-size=1000 $POSTGRES_SYSBENCH_DIR/share/sysbench/oltp_update_index.lua prepare >> /dev/null
     psandbox > $LOG_DIR/c8/rule_$(($i*25)).log
     pkill postgres
     sleep 5
  fi
done



