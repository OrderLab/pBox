#!/bin/bash

LOG_DIR="$(pwd)/../../../result/cases/"

function normal {
  sysbench --mysql-socket=$PSANDBOX_MYSQL_DIR/mysqld.sock --mysql-db=test --tables=1 --table-size=100000 --threads=1 --time=210 --percentile=99 --report-interval=10 $SYSBEN_DIR/oltp_update_index.lua  run &
  sleep 11
  echo "normal"
  sleep 90
  echo "normal end"
  ./back.sh >> /dev/null &
  sleep 13
  echo "interference"
  sleep 90
  echo "interference end"
  sleep 5
}

function cgroup {
  sysbench --mysql-socket=$PSANDBOX_MYSQL_DIR/mysqld.sock --mysql-db=test --tables=1 --table-size=100000 --threads=1 --time=104 --percentile=95 $SYSBEN_DIR/oltp_update_index.lua --report-interval=10 run &
  sleep 8
  N=$(ps -e -T | grep mysqld | awk '{print $2}' | sort -h | wc -l)
  N=$((N-4))
  TLIST=$(ps -e -T | grep mysqld | awk '{print $2}' | sort -h | tail -n +${N})
  for T in $TLIST; do echo "$T" | sudo tee /sys/fs/cgroup/cpu/cpuread/tasks; done >> /dev/null
  ./back.sh >> /dev/null &
  sleep 2
  N=$(ps -e -T | grep mysqld | awk '{print $2}' | sort -h | wc -l)
  TLIST=$(ps -e -T | grep mysqld | awk '{print $2}' | sort -h | tail -n +${N})
  for T in $TLIST; do echo "$T" | sudo tee /sys/fs/cgroup/cpu/cpuwrite/tasks; done >> /dev/null
  sleep 1
  echo "interference"
  sleep 90
  echo "interference end"
  sleep 5
}

function psandbox {
  sysbench --mysql-socket=$PSANDBOX_MYSQL_DIR/mysqld.sock --mysql-db=test --tables=1 --table-size=100000 --threads=1 --time=113 --percentile=95 --report-interval=10 $SYSBEN_DIR/oltp_update_index.lua run &
  sleep 8
  ./back.sh >> /dev/null &
  sleep 3
  echo "interference"
  sleep 90
  echo "interference end"
  sleep 5
}

function parties {
  sysbench --mysql-socket=$PSANDBOX_MYSQL_DIR/mysqld.sock --mysql-db=test --tables=1 --table-size=100000 --threads=1 --time=120 --percentile=95 --report-interval=1 $SYSBEN_DIR/oltp_update_index.lua run >> $LOG_DIR/c4/front_1/parties.log &
  sleep 1
  TLIST=$(ps -e -T | grep mysqld | awk '{print $2}' | sort -h | tail -1)
  for T in $TLIST; do (echo "$T") | sudo tee /sys/fs/cgroup/cpuset/hu_front_1/tasks; done
  sleep 1
  ./back_parties.sh > $LOG_DIR/c4/back_1/parties.log &
  sleep 1
  TLIST=$(ps -e -T | grep mysqld | awk '{print $2}' | sort -h | tail -1)
  for T in $TLIST; do (echo "$T") | sudo tee /sys/fs/cgroup/cpuset/hu_back_1/tasks; done
  sleep 3
  echo "interference" &>> $LOG_DIR/c4/front_1/parties.log
  core=$(nproc --all)
  sudo ../../comparsion/parties_for_native.py $LOG_DIR/c4/ $core &
  sleep 90
  echo "interference end" &>> $LOG_DIR/c4/front_1/parties.log
  sleep 20
  sudo pkill -f parties_for_native.py
  pkill back_parties
}

function parties_normal {
  sysbench --mysql-socket=$PSANDBOX_MYSQL_DIR/mysqld.sock --mysql-db=test --tables=1 --table-size=100000 --threads=1 --time=210 --percentile=99 --report-interval=10 $SYSBEN_DIR/oltp_update_index.lua  run &
  sleep 11
  echo "normal"
  sleep 90
  echo "normal end"
  ./back_parties.sh >> /dev/null &
  sleep 13
  echo "interference"
  sleep 90
  echo "interference end"
  sleep 5
  pkill back_parties
}

function side {
  sysbench --mysql-socket=$PSANDBOX_MYSQL_DIR/mysqld.sock --mysql-db=test --tables=1 --table-size=100000 --threads=1 --time=90 $SYSBEN_DIR/oltp_update_index.lua run &
  sleep 1
  time ./back_side.sh
}

function interference {
  sysbench --mysql-socket=$PSANDBOX_MYSQL_DIR/mysqld.sock --mysql-db=test --tables=1 --table-size=100000 --threads=1 --time=120 --percentile=95 --report-interval=10 $SYSBEN_DIR/oltp_update_index.lua  run &
  sleep 3
  ./back.sh >> /dev/null &
  sleep 13
  echo "interference"
  sleep 90
  echo "interference end"
  sleep 5
}

function no_interference {
  sysbench --mysql-socket=$PSANDBOX_MYSQL_DIR/mysqld.sock --mysql-db=test --tables=1 --table-size=100000 --threads=1 --time=120 --percentile=95 --report-interval=10 $SYSBEN_DIR/oltp_update_index.lua  run &
  sleep 11
  echo "normal"
  sleep 90
  echo "normal end"
}


if [[ $1 == 1 ]]; then
  echo "run c4"
  cp ../../libpsandbox.so $PSANDBOXDIR/build/libs/libpsandbox.so
elif [[ $1 == 2 ]]; then
  echo "run c4 cgroup"
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
  echo "run c4 psandbox"
  cp ../../libpsandbox_psandbox.so $PSANDBOXDIR/build/libs/libpsandbox.so
elif [[ $1 == 4 ]]; then
  echo "run c4 side psandbox"
  cp ../../libpsandbox_psandbox.so $PSANDBOXDIR/build/libs/libpsandbox.so
elif [[ $1 == 5 ]]; then
  echo "run c4 tail"
  cp ../../libpsandbox.so $PSANDBOXDIR/build/libs/libpsandbox.so
elif [[ $1 == 6 ]]; then
  echo "run c4 parties"
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
  cp ../../libpsandbox.so $PSANDBOXDIR/build/libs/libpsandbox.so
elif [[ $1 == 7 ]]; then
  echo "run c4 parties baseline"
  cp ../../libpsandbox.so $PSANDBOXDIR/build/libs/libpsandbox.so
elif [[ $1 == 8 ]]; then
  echo "run c4 retro"
  cp ../../libretro.so $PSANDBOXDIR/build/libs/libpsandbox.so
elif [[ $1 == 9 ]]; then
  echo "run c4 psp"
  cp ../../libpsandbox.so $PSANDBOXDIR/build/libs/libpsandbox.so
fi


if [[ $1 != 9 ]]; then
mkdir -p $LOG_DIR/c4
mysqld --defaults-file=../mysql.cnf &
sleep 5
if [[ $0 == 2 ]]; then
  TLIST=$(ps -e -T | grep mysqld | awk '{print $2}' | sort -h)
  for T in $TLIST; do (echo "$T") | sudo tee /sys/fs/cgroup/cpu/cpuback/tasks; done >> /dev/null
fi
sysbench --mysql-socket=$PSANDBOX_MYSQL_DIR/mysqld.sock --mysql-db=test --tables=1 --table-size=100000 --threads=1 --time=99 $SYSBEN_DIR/oltp_update_index.lua --report-interval=5 cleanup >> /dev/null
sysbench --mysql-socket=$PSANDBOX_MYSQL_DIR/mysqld.sock --mysql-db=test --tables=1 --table-size=100000 --threads=1 --time=99 $SYSBEN_DIR/oltp_update_index.lua --report-interval=5 prepare >> /dev/null
fi

if [[ $1 == 1 ]]; then
    normal > $LOG_DIR/c4/no_psandbox.log
    #normal
elif [[ $1 == 2 ]]; then
    cgroup > $LOG_DIR/c4/cgroup.log
    #cgroup
elif [[ $1 == 3 ]]; then
    psandbox > $LOG_DIR/c4/psandbox.log
    #psandbox
elif [[ $1 == 4 ]]; then
    side > $LOG_DIR/c4/side_psandbox.log
    #side
elif [[ $1 == 5 ]]; then
   no_interference
   mysqladmin -S $PSANDBOX_MYSQL_DIR/mysqld.sock -u root shutdown
   mysqld --defaults-file=../mysql.cnf &
   sleep 5
   interference
elif [[ $1 == 6 ]]; then
    mkdir -p $LOG_DIR/c4/front_1
    mkdir -p $LOG_DIR/c4/back_1
    parties
elif [[ $1 == 7 ]]; then
    parties_normal > $LOG_DIR/c4/parties_baseline.log
elif [[ $1 == 8 ]]; then
    psandbox > $LOG_DIR/c4/retro.log
elif [[ $1 == 9 ]]; then
    ${PSP_DIR}/sosp_aec/psandbox_script/mysql_server4.sh
fi

mysqladmin -S $PSANDBOX_MYSQL_DIR/mysqld.sock -u root shutdown
sleep 10
