#!/bin/bash
  
#need to open the mutex 
LOG_DIR="$(pwd)/../../../result/cases/"

function normal {
  sysbench --mysql-socket=$PSANDBOX_MYSQL_DIR/mysqld.sock --mysql-db=test --tables=1 --table-size=1 --threads=1 --time=207 --percentile=50 --report-interval=10 $SYSBEN_DIR/oltp_update_index.lua  run &
  sleep 11
  echo "normal"
  sleep 90
  echo "normal end"
  ./back.sh >> /dev/null &
  sleep 12
  echo "interference"
  sleep 90
  echo "interference end"
  sleep 5
}

function cgroup { 
  sysbench --mysql-socket=$PSANDBOX_MYSQL_DIR/mysqld.sock --mysql-db=test --tables=1 --table-size=1 --threads=1 --time=118  --percentile=50 $SYSBEN_DIR/oltp_update_index.lua --report-interval=10 run &
  sleep 2
  N=$(ps -e -T | grep mysqld | awk '{print $2}' | sort -h | wc -l)
  TLIST=$(ps -e -T | grep mysqld | awk '{print $2}' | sort -h | tail -n +${N})
  for T in $TLIST; do echo "$T" | sudo tee /sys/fs/cgroup/cpu/cpuread/tasks; done
  ./back.sh >> /dev/null &
  sleep 12
  N=$(ps -e -T | grep mysqld | awk '{print $2}' | sort -h | wc -l)
  TLIST=$(ps -e -T | grep mysqld | awk '{print $2}' | sort -h | tail -n +${N})
  for T in $TLIST; do echo "$T" | sudo tee /sys/fs/cgroup/cpu/cpuwrite/tasks; done
  sleep 7
  echo "interference"
  sleep 90
  echo "interference end"
  sleep 5
}

function parties {
  sysbench --mysql-socket=$PSANDBOX_MYSQL_DIR/mysqld.sock --mysql-db=test --tables=1 --table-size=1 --threads=1 --time=120 --percentile=50 --report-interval=1 $SYSBEN_DIR/oltp_update_index.lua run >> $LOG_DIR/c5/front_1/parties.log &
  sleep 1
  TLIST=$(ps -e -T | grep mysqld | awk '{print $2}' | sort -h | tail -1)
  for T in $TLIST; do (echo "$T") | sudo tee /sys/fs/cgroup/cpuset/hu_front_1/tasks; done
  sleep 1
  ./back_parties.sh > $LOG_DIR/c5/back_1/parties.log &
  sleep 1
  TLIST=$(ps -e -T | grep mysqld | awk '{print $2}' | sort -h | tail -1)
  for T in $TLIST; do (echo "$T") | sudo tee /sys/fs/cgroup/cpuset/hu_back_1/tasks; done
  sleep 20
  echo "interference" >> $LOG_DIR/c5/front_1/parties.log
  sudo ../../comparsion/parties_for_native.py $LOG_DIR/c5/ &
  sleep 90
  echo "interference end" >> $LOG_DIR/c5/front_1/parties.log
  sleep 10
  sudo pkill -f parties_for_native.py
  pkill back_parties
}

function parties_normal {
  sysbench --mysql-socket=$PSANDBOX_MYSQL_DIR/mysqld.sock --mysql-db=test --tables=1 --table-size=1 --threads=1 --time=207 --percentile=50 --report-interval=10 $SYSBEN_DIR/oltp_update_index.lua  run &
  sleep 11
  echo "normal"
  sleep 90
  echo "normal end"
  ./back_parties.sh >> /dev/null &
  sleep 12
  echo "interference"
  sleep 90
  echo "interference end"
  sleep 5
  pkill back_parties
}

function psandbox {
  sysbench --mysql-socket=$PSANDBOX_MYSQL_DIR/mysqld.sock --mysql-db=test --tables=1 --table-size=1 --threads=1 --time=118 --percentile=50 --report-interval=10 $SYSBEN_DIR/oltp_update_index.lua run &
  sleep 1
  ./back.sh >> /dev/null &
  sleep 20
  echo "interference"
  sleep 90
  echo "interference end"
  sleep 5
}

function side {
  sysbench --mysql-socket=$PSANDBOX_MYSQL_DIR/mysqld.sock --mysql-db=test --tables=1 --table-size=1 --threads=1 --time=130 $SYSBEN_DIR/oltp_update_index.lua run &
  sleep 1
  time ./back_side.sh
}

function no_interference {
  sysbench --mysql-socket=$PSANDBOX_MYSQL_DIR/mysqld.sock --mysql-db=test --tables=1 --table-size=1 --threads=1 --time=105 --percentile=99 --report-interval=10 $SYSBEN_DIR/oltp_update_index.lua  run &
  sleep 11
  echo "normal"
  sleep 90
  echo "normal end"
  sleep 5
}

function interference {
  sysbench --mysql-socket=$PSANDBOX_MYSQL_DIR/mysqld.sock --mysql-db=test --tables=1 --table-size=1 --threads=1 --time=120 --percentile=99 --report-interval=10 $SYSBEN_DIR/oltp_update_index.lua  run &
  sleep 3
  ./back.sh >> /dev/null &
  sleep 12
  echo "interference"
  sleep 90
  echo "interference end"
  sleep 7
}

if [[ $1 == 1 ]]; then
  echo "run c5"
  cp ../../libpsandbox.so $PSANDBOXDIR/build/libs/libpsandbox.so
elif [[ $1 == 2 ]]; then
  echo "run c5 cgroup"
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
  echo "run c5 psandbox"
  cp ../../libpsandbox_psandbox.so $PSANDBOXDIR/build/libs/libpsandbox.so
elif [[ $1 == 4 ]]; then
  echo "run c5 side psandbox"
  cp ../../libpsandbox_psandbox.so $PSANDBOXDIR/build/libs/libpsandbox.so
elif [[ $1 == 5 ]]; then
  echo "run c5 tail"
  cp ../../libpsandbox.so $PSANDBOXDIR/build/libs/libpsandbox.so
elif [[ $1 == 6 ]]; then
  echo "run c5 parties"
  sudo cgdelete -g cpuset:/hu_front_1
  sudo cgcreate -g cpuset:/hu_front_1
  echo "0" | sudo tee /sys/fs/cgroup/cpuset/hu_front_1/cpuset.mems
  echo "0-19" | sudo tee /sys/fs/cgroup/cpuset/hu_front_1/cpuset.cpus
  sudo cgdelete -g cpuset:/hu_back_1
  sudo cgcreate -g cpuset:/hu_back_1
  echo "0" | sudo tee /sys/fs/cgroup/cpuset/hu_back_1/cpuset.mems
  echo "0-19" | sudo tee /sys/fs/cgroup/cpuset/hu_back_1/cpuset.cpus
  cp ../../libpsandbox.so $PSANDBOXDIR/build/libs/libpsandbox.so
elif [[ $1 == 7 ]]; then
  echo "run c5 parties baseline"
  cp ../../libpsandbox.so $PSANDBOXDIR/build/libs/libpsandbox.so
elif [[ $1 == 8 ]]; then
  echo "run c5 retro"
  cp ../../libretro.so $PSANDBOXDIR/build/libs/libpsandbox.so
elif [[ $1 == 9 ]]; then
  echo "run c5 psp"
  cp ../../libpsandbox.so $PSANDBOXDIR/build/libs/libpsandbox.so
fi


mkdir -p $LOG_DIR/c5
mysqld --defaults-file=../mysql.cnf &
sleep 5
if [[ $0 == 2 ]]; then
  TLIST=$(ps -e -T | grep mysqld | awk '{print $2}' | sort -h)
  for T in $TLIST; do (echo "$T") | sudo tee /sys/fs/cgroup/cpu/cpuback/tasks; done >> /dev/null
fi
sysbench --mysql-socket=$PSANDBOX_MYSQL_DIR/mysqld.sock --mysql-db=test --tables=1 --table-size=1 --threads=1 --time=65 $SYSBEN_DIR/oltp_update_index.lua --report-interval=3 cleanup >> /dev/null
sysbench --mysql-socket=$PSANDBOX_MYSQL_DIR/mysqld.sock --mysql-db=test --tables=1 --table-size=1 --threads=1 --time=65 $SYSBEN_DIR/oltp_update_index.lua --report-interval=3 prepare >> /dev/null
if [[ $1 == 1 ]]; then
    normal >> $LOG_DIR/c5/no_psandbox.log
    #normal
elif [[ $1 == 2 ]]; then
    cgroup >> $LOG_DIR/c5/cgroup.log
    #cgroup
elif [[ $1 == 3 ]]; then
    psandbox >> $LOG_DIR/c5/psandbox.log
    #psandbox
elif [[ $1 == 4 ]]; then
    #side >> $LOG_DIR/c5/side_psandbox.log
    side
elif [[ $1 == 5 ]]; then
   no_interference
   mysqladmin -S $PSANDBOX_MYSQL_DIR/mysqld.sock -u root shutdown
   mysqld --defaults-file=../mysql.cnf &
   sleep 5
   interference
elif [[ $1 == 6 ]]; then
    mkdir -p $LOG_DIR/c5/front_1
    mkdir -p $LOG_DIR/c5/back_1
    parties
elif [[ $1 == 7 ]]; then
    parties_normal >> $LOG_DIR/c5/parties_baseline.log
elif [[ $1 == 8 ]]; then
    psandbox > $LOG_DIR/c5/retro.log
elif [[ $1 == 9 ]]; then
    parties_normal >> $LOG_DIR/c5/parties_baseline.log
fi

mysqladmin -S $PSANDBOX_MYSQL_DIR/mysqld.sock -u root shutdown
sleep 10
