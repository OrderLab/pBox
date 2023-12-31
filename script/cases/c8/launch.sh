#!/bin/bash

LOG_DIR="$(pwd)/../../../result/cases/"

function normal {
  $POSTGRES_SYSBENCH_DIR/bin/sysbench  --pgsql-db=postgres --pgsql-user=$(whoami) --tables=1 --table-size=1000 --threads=1 --time=206  --percentile=95 $POSTGRES_SYSBENCH_DIR/share/sysbench/oltp_update_index.lua --report-interval=10 run &
  sleep 11
  echo "normal"
  sleep 90
  echo "normal end"
  ./back.sh >> /dev/null  &
  sleep 11
  echo "interference"
  sleep 90
  echo "interference end"
  sleep 10
}

function cgroup {
  $POSTGRES_SYSBENCH_DIR/bin/sysbench  --pgsql-db=postgres --pgsql-user=$(whoami) --tables=1 --table-size=1000 --threads=1 --time=107  --percentile=95 $POSTGRES_SYSBENCH_DIR/share/sysbench/oltp_update_index.lua --report-interval=10 run &
  sleep 2
  N=$(ps -e -T | grep postgre | awk '{print $2}' | sort -h | wc -l)
  TLIST=$(ps -e -T | grep postgre | awk '{print $2}' | sort -h | tail -n +${N})
  for T in $TLIST; do echo "$T" | sudo tee /sys/fs/cgroup/cpu/cpuwrite/tasks; done >> /dev/null
  ./back.sh >> /dev/null  &
  sleep 8
  N=$(ps -e -T | grep postgre | awk '{print $2}' | sort -h | wc -l)
  TLIST=$(ps -e -T | grep postgre | awk '{print $2}' | sort -h | tail -n +${N})
  for T in $TLIST; do echo "$T" | sudo tee /sys/fs/cgroup/cpu/cpuread/tasks; done >> /dev/null
  sleep 1
  echo "interference"
  sleep 90
  echo "interference end"
  sleep 5
}

function psandbox {
  $POSTGRES_SYSBENCH_DIR/bin/sysbench  --pgsql-db=postgres --pgsql-user=$(whoami) --tables=1 --table-size=1000 --threads=1 --time=100 --percentile=95 --report-interval=10 $POSTGRES_SYSBENCH_DIR/share/sysbench/oltp_update_index.lua run &
  sleep 2
  ./back.sh >> /dev/null  &
  echo "interference"
  sleep 90
  echo "interference end"
  sleep 10
}

function parties {
  $POSTGRES_SYSBENCH_DIR/bin/sysbench  --pgsql-db=postgres --pgsql-user=$(whoami) --tables=1 --table-size=1000 --threads=1 --time=115  --percentile=95 --report-interval=1 $POSTGRES_SYSBENCH_DIR/share/sysbench/oltp_update_index.lua run >> $LOG_DIR/c8/front_1/parties.log &
  sleep 1
  TLIST=$(ps -e -T | grep postgre | awk '{print $2}' | sort -h | tail -1)
  for T in $TLIST; do (echo "$T") | sudo tee /sys/fs/cgroup/cpuset/hu_front_1/tasks; done
  sleep 1
  $POSTGRES_SYSBENCH_DIR/bin/sysbench  --pgsql-db=postgres --pgsql-user=$(whoami) --tables=64 --table-size=1000 --threads=32 --time=300  --percentile=95 --report-interval=1 $POSTGRES_SYSBENCH_DIR/share/sysbench/select_random_points.lua run > $LOG_DIR/c8/front_2/parties.log &
  sleep 1
  N=$(ps -e -T | grep postgre | awk '{print $2}' | sort -h | wc -l)
  N=$((N-31))
  TLIST=$(ps -e -T | grep postgre | awk '{print $2}' | sort -h | tail -n +${N})  
  for T in $TLIST; do (echo "$T") | sudo tee /sys/fs/cgroup/cpuset/hu_front_2/tasks; done
  sleep 1
  ./back_parties.sh > $LOG_DIR/c8/back_1/parties.log &
  sleep 5
  TLIST=$(ps -e -T | grep postgre | awk '{print $2}' | sort -h | tail -1)
  for T in $TLIST; do (echo "$T") | sudo tee /sys/fs/cgroup/cpuset/hu_back_1/tasks; done
  sleep 10
  echo "interference" >> $LOG_DIR/c8/front_1/parties.log
  core=$(nproc --all)
  sudo ../../comparsion/parties_for_native.py $LOG_DIR/c8/ $core &
  sleep 90
  echo "interference end" >> $LOG_DIR/c8/front_1/parties.log
  sleep 10
  sudo pkill -f parties_for_native.py
}

function parties_normal {
  $POSTGRES_SYSBENCH_DIR/bin/sysbench  --pgsql-db=postgres --pgsql-user=$(whoami) --tables=1 --table-size=1000 --threads=1 --time=206  --percentile=95 $POSTGRES_SYSBENCH_DIR/share/sysbench/oltp_update_index.lua --report-interval=10 run &
 $POSTGRES_SYSBENCH_DIR/bin/sysbench  --pgsql-db=postgres --pgsql-user=$(whoami) --tables=64 --table-size=1000 --threads=32 --time=206  --percentile=95 --report-interval=1 $POSTGRES_SYSBENCH_DIR/share/sysbench/select_random_points.lua run > /dev/null &
  sleep 11
  echo "normal"
  sleep 90
  echo "normal end"
  ./back_parties.sh >> /dev/null  &
  sleep 11
  echo "interference"
  sleep 90
  echo "interference end"
  sleep 10
}

function side {
  $POSTGRES_SYSBENCH_DIR/bin/sysbench  --pgsql-db=postgres --pgsql-user=$(whoami) --tables=1 --table-size=1000 --threads=1 --time=90  --percentile=99 $POSTGRES_SYSBENCH_DIR/share/sysbench/oltp_update_index.lua run &
  sleep 2
  time ./back_side.sh | psql postgres 
}

function no_interference {
  $POSTGRES_SYSBENCH_DIR/bin/sysbench  --pgsql-db=postgres --pgsql-user=$(whoami) --tables=1 --table-size=1000 --threads=1 --time=105  --percentile=99 $POSTGRES_SYSBENCH_DIR/share/sysbench/oltp_update_index.lua --report-interval=10 run &
  sleep 11
  echo "normal"
  sleep 90
  echo "normal end"
  sleep 10
}

function interference {
  $POSTGRES_SYSBENCH_DIR/bin/sysbench  --pgsql-db=postgres --pgsql-user=$(whoami) --tables=1 --table-size=1000 --threads=1 --time=90  --percentile=99 $POSTGRES_SYSBENCH_DIR/share/sysbench/oltp_update_index.lua --report-interval=10 run &
  sleep 4
  ./back.sh >> /dev/null 
  sleep 10
}

function tail_psandbox {
  $POSTGRES_SYSBENCH_DIR/bin/sysbench  --pgsql-db=postgres --pgsql-user=$(whoami) --tables=1 --table-size=1000 --threads=1 --time=100 --percentile=99 --report-interval=10 $POSTGRES_SYSBENCH_DIR/share/sysbench/oltp_update_index.lua run &
  sleep 2
  ./back.sh >> /dev/null
}

if [[ $1 == 1 ]]; then
  echo "run c8"
  cp ../../libpsandbox.so $PSANDBOXDIR/build/libs/libpsandbox.so
elif [[ $1 == 2 ]]; then
  echo "run c8 cgroup"
  sudo cgdelete -g cpu:/cpuwrite
  sudo cgcreate -g cpu:/cpuwrite
  sudo cgset -r cpu.shares=2048 cpuwrite
  sudo cgdelete -g cpu:/cpuread
  sudo cgcreate -g cpu:/cpuread
  sudo cgset -r cpu.shares=2048 cpuread
  sudo cgdelete -g cpu:/cpuback
  sudo cgcreate -g cpu:/cpuback
  sudo cgset -r cpu.shares=2048 cpuback
  cp ../../libpsandbox.so $PSANDBOXDIR/build/libs/libpsandbox.so
elif [[ $1 == 3 ]]; then
  echo "run c8 psandbox"
  cp ../../libpsandbox_psandbox.so $PSANDBOXDIR/build/libs/libpsandbox.so
elif [[ $1 == 4 ]]; then
  echo "run c8 side psandbox"
  cp ../../libpsandbox_psandbox.so $PSANDBOXDIR/build/libs/libpsandbox.so
elif [[ $1 == 5 ]]; then
  echo "run c8 tail"
  cp ../libpsandbox.so $PSANDBOXDIR/build/libs/libpsandbox.so
elif [[ $1 == 6 ]]; then
  echo "run c8 parties"
  sudo cgdelete -g cpuset:/hu_front_1
  sudo cgcreate -g cpuset:/hu_front_1
  core=$(nproc --all)
  core=$(( core - 1))
  echo "0" | sudo tee /sys/fs/cgroup/cpuset/hu_front_1/cpuset.mems
  echo "0-$core" | sudo tee /sys/fs/cgroup/cpuset/hu_front_1/cpuset.cpus
  sudo cgdelete -g cpuset:/hu_back_1
  sudo cgcreate -g cpuset:/hu_back_1
  echo "0" | sudo tee /sys/fs/cgroup/cpuset/hu_back_1/cpuset.mems
  echo "0-$core" | sudo tee /sys/fs/cgroup/cpuset/hu_back_1/cpuset.cpus
  sudo cgdelete -g cpuset:/hu_front_2
  sudo cgcreate -g cpuset:/hu_front_2
  echo "0" | sudo tee /sys/fs/cgroup/cpuset/hu_front_2/cpuset.mems
  echo "0-$core" | sudo tee /sys/fs/cgroup/cpuset/hu_front_2/cpuset.cpus
  cp ../../libpsandbox.so $PSANDBOXDIR/build/libs/libpsandbox.so
elif [[ $1 == 7 ]]; then
  echo "run c8 parties baseline"
  cp ../../libpsandbox.so $PSANDBOXDIR/build/libs/libpsandbox.so
elif [[ $1 == 8 ]]; then
  echo "run c8 retro"
  cp ../../libretro.so $PSANDBOXDIR/build/libs/libpsandbox.so
elif [[ $1 == 9 ]]; then
  echo "run c8 psp"
  cp ../../libpsandbox.so $PSANDBOXDIR/build/libs/libpsandbox.so
fi

if [[ $1 != 9 ]]; then
mkdir -p $LOG_DIR/c8
postgres -D $PSANDBOX_POSTGRES_DIR/data/ --config-file=$PSANDBOX_POSTGRES_DIR/data/postgresql.conf &
sleep 1
if [[ $0 == 2 ]]; then
    TLIST=$(ps -e -T | grep postgre | awk '{print $2}' | sort -h)
    for T in $TLIST; do echo "$T" | sudo tee /sys/fs/cgroup/cpu/cpuback/tasks; done >> /dev/null
fi

$POSTGRES_SYSBENCH_DIR/bin/sysbench  --pgsql-db=postgres --pgsql-user=$(whoami) --tables=1 --table-size=1000 $POSTGRES_SYSBENCH_DIR/share/sysbench/oltp_update_index.lua --report-interval=3 cleanup >> /dev/null
$POSTGRES_SYSBENCH_DIR/bin/sysbench  --pgsql-db=postgres --pgsql-user=$(whoami) --tables=1 --table-size=1000 $POSTGRES_SYSBENCH_DIR/share/sysbench/oltp_update_index.lua --report-interval=3 prepare >> /dev/null
fi
if [[ $1 == 1 ]]; then
  normal > $LOG_DIR/c8/no_psandbox.log
  #normal
elif [[ $1 == 2 ]]; then
  cgroup > $LOG_DIR/c8/cgroup.log
  #cgroup
elif [[ $1 == 3 ]]; then
  psandbox > $LOG_DIR/c8/psandbox.log
  #psandbox
elif [[ $1 == 4 ]]; then
  side > $LOG_DIR/c8/side_psandbox.log
  #side
elif [[ $1 == 5 ]]; then
   no_interference
elif [[ $1 == 6 ]]; then
  mkdir -p $LOG_DIR/c8/front_1
  mkdir -p $LOG_DIR/c8/back_1
  mkdir -p $LOG_DIR/c8/front_2
  parties
elif [[ $1 == 7 ]]; then
  parties_normal > $LOG_DIR/c8/parties_baseline.log
elif [[ $1 == 8 ]]; then
  psandbox > $LOG_DIR/c8/retro.log
elif [[ $1 == 9 ]]; then
  ${PSP_DIR}/sosp_aec/psandbox_script/postgre_server8.sh
fi

pkill postgre
sleep 10
