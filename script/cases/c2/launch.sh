#!/bin/bash

LOG_DIR="$(pwd)/../../../result/cases/"

if [ $# -eq 0 ]
  then
    echo "No arguments supplied"
fi

function normal {
  sysbench --mysql-socket=$PSANDBOX_MYSQL_DIR/mysqld.sock --mysql-db=test --tables=64 --table-size=1000 --threads=1 --time=90   --percentile=50 $SYSBEN_DIR/oltp_insert.lua --report-interval=5 cleanup >> /dev/null
  sysbench --mysql-socket=$PSANDBOX_MYSQL_DIR/mysqld.sock --mysql-db=test --tables=64 --table-size=1000 --threads=1 --time=90   --percentile=50 $SYSBEN_DIR/oltp_insert.lua --report-interval=5 prepare >> /dev/null
  sysbench --mysql-socket=$PSANDBOX_MYSQL_DIR/mysqld.sock --mysql-db=test --tables=64 --table-size=1000 --threads=64 --time=107  --percentile=50 $SYSBEN_DIR/oltp_insert.lua --report-interval=10 run &
  sleep 11
  echo "normal"
  sleep 90
  echo "normal end" 
  sleep 10
  mysqladmin -S $PSANDBOX_MYSQL_DIR/mysqld.sock -u root shutdown
  sleep 10
  mysqld --defaults-file=../mysql.cnf &
  sleep 5
  sysbench --mysql-socket=$PSANDBOX_MYSQL_DIR/mysqld.sock --mysql-db=test --tables=64 --table-size=1000 --threads=1 --time=95 --secondary=on $SYSBEN_DIR/oltp_insert.lua  cleanup >> /dev/null
  sysbench --mysql-socket=$PSANDBOX_MYSQL_DIR/mysqld.sock --mysql-db=test --tables=64 --table-size=1000 --threads=1 --time=90 --secondary=on --percentile=50 $SYSBEN_DIR/oltp_insert.lua prepare >> /dev/null
  sysbench --mysql-socket=$PSANDBOX_MYSQL_DIR/mysqld.sock --mysql-db=test --tables=64 --table-size=1000 --threads=64 --time=107 --secondary=on --percentile=50 $SYSBEN_DIR/oltp_insert.lua --report-interval=10 run &
  sleep 11
  echo "interference" 
  sleep 90
  echo "interference end"
  sleep 10
}

function cgroup {
  sysbench --mysql-socket=$PSANDBOX_MYSQL_DIR/mysqld.sock  --mysql-db=test --tables=64 --table-size=1000 --threads=1 --time=95  --percentile=50 --secondary=on $SYSBEN_DIR/oltp_insert.lua cleanup >> /dev/null
  sysbench --mysql-socket=$PSANDBOX_MYSQL_DIR/mysqld.sock  --mysql-db=test --tables=64 --table-size=1000 --threads=1 --time=90  --percentile=50 --secondary=on $SYSBEN_DIR/oltp_insert.lua prepare >> /dev/null
  sysbench --mysql-socket=$PSANDBOX_MYSQL_DIR/mysqld.sock  --mysql-db=test --tables=64 --table-size=1000 --threads=64 --time=107  --percentile=50 --secondary=on $SYSBEN_DIR/oltp_insert.lua --report-interval=10 run &
  sleep 1
  N=$(ps -e -T | grep mysqld | awk '{print $2}' | sort -h | wc -l)
  N=$((N-63))
  TLIST=$(ps -e -T | grep mysqld | awk '{print $2}' | sort -h | tail -n +${N})
  for T in $TLIST; do echo "$T" | sudo tee /sys/fs/cgroup/cpu/cpuwrite/tasks; done >> /dev/null
  sleep 10
  echo "interference"
  sleep 90
  echo "interference end" 
  sleep 10
}

function psandbox {
  sysbench --mysql-socket=$PSANDBOX_MYSQL_DIR/mysqld.sock --mysql-db=test --tables=64 --table-size=1000 --threads=64 --time=217 --secondary=on  --percentile=50 $SYSBEN_DIR/oltp_insert.lua --report-interval=10 run &
  sleep 60
  echo "interference"
  sleep 90
  echo "interference end"
  sleep 11
}

function parties {
  sysbench --mysql-socket=$PSANDBOX_MYSQL_DIR/mysqld.sock --mysql-db=test --tables=64 --table-size=1000 --threads=32 --time=220 --secondary=on  --percentile=50 $SYSBEN_DIR/oltp_insert.lua --report-interval=1 run >> $LOG_DIR/c2/front_1/parties.log & 
  sleep 1
  N=$(ps -e -T | grep mysqld | awk '{print $2}' | sort -h | wc -l)
  N=$((N-31))
  TLIST=$(ps -e -T | grep mysqld | awk '{print $2}' | sort -h | tail -n +${N})
  for T in $TLIST; do (echo "$T") | sudo tee /sys/fs/cgroup/cpuset/hu_front_1/tasks; done >> /dev/null
  sysbench --mysql-socket=$PSANDBOX_MYSQL_DIR/mysqld.sock --mysql-db=test --tables=64 --table-size=1000 --threads=32 --time=217 --secondary=on  --percentile=50 $SYSBEN_DIR/oltp_insert.lua --report-interval=1 run >> $LOG_DIR/c2/front_2/parties.log & 
  sleep 1
  N=$(ps -e -T | grep mysqld | awk '{print $2}' | sort -h | wc -l)
  N=$((N-31))
  TLIST=$(ps -e -T | grep mysqld | awk '{print $2}' | sort -h | tail -n +${N})
  for T in $TLIST; do (echo "$T") | sudo tee /sys/fs/cgroup/cpuset/hu_front_2/tasks; done >> /dev/null
  sleep 60
  echo "interference" >> $LOG_DIR/c2/front_1/parties.log
  sudo ../../comparsion/parties_for_native.py $LOG_DIR/c2/ &
  sleep 90
  echo "interference end" >> $LOG_DIR/c2/front_1/parties.log
  sleep 20
  sudo pkill -f parties_for_native.py
}

function parties_normal {
  sysbench --mysql-socket=$PSANDBOX_MYSQL_DIR/mysqld.sock --mysql-db=test --tables=64 --table-size=1000 --threads=1 --time=90   --percentile=50 $SYSBEN_DIR/oltp_insert.lua --report-interval=5 cleanup >> /dev/null
  sysbench --mysql-socket=$PSANDBOX_MYSQL_DIR/mysqld.sock --mysql-db=test --tables=64 --table-size=1000 --threads=1 --time=90   --percentile=50 $SYSBEN_DIR/oltp_insert.lua --report-interval=5 prepare >> /dev/null
  sysbench --mysql-socket=$PSANDBOX_MYSQL_DIR/mysqld.sock --mysql-db=test --tables=64 --table-size=1000 --threads=32 --time=107  --percentile=50 $SYSBEN_DIR/oltp_insert.lua --report-interval=10 run &
  sysbench --mysql-socket=$PSANDBOX_MYSQL_DIR/mysqld.sock --mysql-db=test --tables=64 --table-size=1000 --threads=32 --time=107  --percentile=50 $SYSBEN_DIR/oltp_insert.lua  run &
  sleep 11
  echo "normal"
  sleep 90
  echo "normal end" 
  sleep 10
  mysqladmin -S $PSANDBOX_MYSQL_DIR/mysqld.sock -u root shutdown
  sleep 10
  mysqld --defaults-file=../mysql.cnf &
  sleep 5
  sysbench --mysql-socket=$PSANDBOX_MYSQL_DIR/mysqld.sock --mysql-db=test --tables=64 --table-size=1000 --threads=1 --time=95 --secondary=on $SYSBEN_DIR/oltp_insert.lua  cleanup >> /dev/null
  sysbench --mysql-socket=$PSANDBOX_MYSQL_DIR/mysqld.sock --mysql-db=test --tables=64 --table-size=1000 --threads=1 --time=90 --secondary=on --percentile=50 $SYSBEN_DIR/oltp_insert.lua prepare >> /dev/null
  sysbench --mysql-socket=$PSANDBOX_MYSQL_DIR/mysqld.sock --mysql-db=test --tables=64 --table-size=1000 --threads=32 --time=107 --secondary=on --percentile=50 $SYSBEN_DIR/oltp_insert.lua --report-interval=10 run &
  sysbench --mysql-socket=$PSANDBOX_MYSQL_DIR/mysqld.sock --mysql-db=test --tables=64 --table-size=1000 --threads=32 --time=107 --secondary=on --percentile=50 $SYSBEN_DIR/oltp_insert.lua  run &
  sleep 11
  echo "interference" 
  sleep 90
  echo "interference end"
  sleep 10
}


if [[ $1 == 1 ]]; then
    echo "run c2"
    cp ../../libpsandbox.so $PSANDBOXDIR/build/libs/libpsandbox.so
elif [[ $1 == 2 ]]; then
   echo "run c2 cgroup"
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
   echo "run c2 psandbox"
   cp ../../libpsandbox.so $PSANDBOXDIR/build/libs/libpsandbox.so
elif [[ $1 == 6 ]]; then
  echo "run c2 parties"
  sudo cgdelete -g cpuset:/hu_front_1
  sudo cgcreate -g cpuset:/hu_front_1
  echo "0" | sudo tee /sys/fs/cgroup/cpuset/hu_front_1/cpuset.mems
  echo "0-19" | sudo tee /sys/fs/cgroup/cpuset/hu_front_1/cpuset.cpus
  sudo cgdelete -g cpuset:/hu_front_2
  sudo cgcreate -g cpuset:/hu_front_2
  echo "0" | sudo tee /sys/fs/cgroup/cpuset/hu_front_2/cpuset.mems
  echo "0-19" | sudo tee /sys/fs/cgroup/cpuset/hu_front_2/cpuset.cpus
  cp ../../libpsandbox.so $PSANDBOXDIR/build/libs/libpsandbox.so
elif [[ $1 == 7 ]]; then
  echo "run c2 parties baseline"
  cp ../../libpsandbox.so $PSANDBOXDIR/build/libs/libpsandbox.so
elif [[ $1 == 8 ]]; then
  echo "run c2 retro"
  cp ../../libretro.so $PSANDBOXDIR/build/libs/libpsandbox.so
elif [[ $1 == 9 ]]; then
  echo "run c2 psp"
  cp ../../libpsandbox.so $PSANDBOXDIR/build/libs/libpsandbox.so
fi


mkdir -p $LOG_DIR/c2
mysqld --defaults-file=../mysql.cnf  &
sleep 5
if [[ $0 == 2 ]]; then
  TLIST=$(ps -e -T | grep mysqld | awk '{print $2}' | sort -h)
  for T in $TLIST; do (echo "$T") | sudo tee /sys/fs/cgroup/cpu/cpuback/tasks; done >> /dev/null
fi

if [[ $1 == 1 ]]; then
  normal >> $LOG_DIR/c2/no_psandbox.log
  #normal
elif [[ $1 == 2 ]]; then
  cgroup >> $LOG_DIR/c2/cgroup.log
  #cgroup
elif [[ $1 == 3 ]]; then
  sysbench --mysql-socket=$PSANDBOX_MYSQL_DIR/mysqld.sock --mysql-db=test --tables=64 --table-size=1000 --threads=1 --secondary=on $SYSBEN_DIR/oltp_insert.lua cleanup >> /dev/null
  sysbench --mysql-socket=$PSANDBOX_MYSQL_DIR/mysqld.sock --mysql-db=test --tables=64 --table-size=1000 --threads=1 --secondary=on $SYSBEN_DIR/oltp_insert.lua prepare >> /dev/null
  mysqladmin -S $PSANDBOX_MYSQL_DIR/mysqld.sock -u root shutdown
  cp ../../libpsandbox_psandbox.so $PSANDBOXDIR/build/libs/libpsandbox.so
  mysqld --defaults-file=../mysql.cnf &
  sleep 5
  psandbox >> $LOG_DIR/c2/psandbox.log
  #psandbox
elif [[ $1 == 6 ]]; then
  sysbench --mysql-socket=$PSANDBOX_MYSQL_DIR/mysqld.sock --mysql-db=test --tables=64 --table-size=1000 --threads=1 --secondary=on $SYSBEN_DIR/oltp_insert.lua cleanup >> /dev/null
  sysbench --mysql-socket=$PSANDBOX_MYSQL_DIR/mysqld.sock --mysql-db=test --tables=64 --table-size=1000 --threads=1 --secondary=on $SYSBEN_DIR/oltp_insert.lua prepare >> /dev/null
  mkdir -p $LOG_DIR/c2/front_1
  mkdir -p $LOG_DIR/c2/front_2
  parties
elif [[ $1 == 7 ]]; then
  parties_normal >> $LOG_DIR/c2/parties_baseline.log
elif [[ $1 == 8 ]]; then
    psandbox > $LOG_DIR/c2/retro.log
elif [[ $1 == 9 ]]; then
    parties_normal >> $LOG_DIR/c1/parties_baseline.log
fi

pkill -9 mysqld
sleep 10
