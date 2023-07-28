#!/bin/bash
  
LOG_DIR="$(pwd)/../../../result/sensitivity/"

function psandbox {
  $POSTGRES_SYSBENCH_DIR/bin/sysbench  --pgsql-db=postgres --pgsql-user=$(whoami) --tables=1 --table-size=1000 --threads=1 --time=105 $POSTGRES_SYSBENCH_DIR/share/sysbench/oltp_update_index.lua --report-interval=10 --percentile=50 run &
  sleep 11
  ./back.sh >> /dev/null  &
  echo "interference"
  sleep 90
  echo "interference end"
  sleep 10
}

cp gendata.pl $PSANDBOX_POSTGRES_DIR
cd $PSANDBOX_POSTGRES_DIR && ./gendata.pl
mkdir -p $LOG_DIR/c10
cp ../../libpsandbox_psandbox.so $PSANDBOXDIR/build/libs/libpsandbox.so
for i in {1..5}
do
     echo postgres-$(($i*25))
     cp ../../bin/postgres-$(($i*25)) $PSANDBOX_POSTGRES_DIR/bin/postgres
     postgres -D $PSANDBOX_POSTGRES_DIR/data/ --config-file=$PSANDBOX_POSTGRES_DIR/data/postgresql.conf &
     sleep 5
     ./create.sh
     psandbox > $LOG_DIR/c10/rule_$(($i*25)).log
     pkill postgre
     sleep 5
done



