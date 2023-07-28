#!/bin/bash

LOG_DIR="$(pwd)/../../../result/cases/"

if [ $# -eq 0 ]
  then
    echo "No arguments supplied"
fi

function normal {
  sysbench --mysql-socket=$PSANDBOX_MYSQL_DIR/mysqld.sock --mysql-db=test --tables=1 --table-size=1000 --threads=1 --time=200  --percentile=50 --report-interval=10 $SYSBEN_DIR/oltp_point_select.lua run & 
  sleep 11
  echo "normal"
  sleep 90
  echo "normal end" 
  for i in {2..6}
  do
    ./back.sh $i | mysql -S $PSANDBOX_MYSQL_DIR/mysqld.sock  > /dev/null &
  done
  sleep 10
  echo "interference"
  sleep 90
  echo "interference end" 
  sleep 10
  pkill back.sh
}

function cgroup {
  sysbench --mysql-socket=$PSANDBOX_MYSQL_DIR/mysqld.sock --mysql-db=test --tables=1 --table-size=1000 --threads=1 --time=117 --percentile=50 $SYSBEN_DIR/oltp_point_select.lua --report-interval=10 run &
  sleep 2
  N=$(ps -e -T | grep mysqld | awk '{print $2}' | sort -h | wc -l)
  N=$((N))
  TLIST=$(ps -e -T | grep mysqld | awk '{print $2}' | sort -h | tail -n +${N})
  for i in {2..6}
  do
    ./back.sh $i | mysql -S $PSANDBOX_MYSQL_DIR/mysqld.sock  > /dev/null &
  done
  for T in $TLIST; do echo "$T" | sudo tee /sys/fs/cgroup/cpu/cpuread/tasks; done >> /dev/null
  sleep 2
  N=$(ps -e -T | grep mysqld | awk '{print $2}' | sort -h | wc -l)
  N=$((N-4))
  TLIST=$(ps -e -T | grep mysqld | awk '{print $2}' | sort -h | tail -n +${N})
  for T in $TLIST; do echo "$T" | sudo tee /sys/fs/cgroup/cpu/cpuwrite/tasks; done >> /dev/null
  sleep 7
  echo "interference"
  sleep 90
  echo "interference end"
  sleep 5
  pkill back.sh
}

function psandbox {
  sysbench --mysql-socket=$PSANDBOX_MYSQL_DIR/mysqld.sock --mysql-db=test --tables=1 --table-size=1000 --threads=1 --time=117 --percentile=50 --report-interval=10  $SYSBEN_DIR/oltp_point_select.lua run & 
  sleep 1
  for i in {2..6}
  do
    ./back.sh $i | mysql -S $PSANDBOX_MYSQL_DIR/mysqld.sock  > /dev/null &
  done
  sleep 10
  echo "interference"
  sleep 90
  echo "interference end" 
  sleep 10
  pkill back.sh
}


function parties {
  sysbench --mysql-socket=$PSANDBOX_MYSQL_DIR/mysqld.sock --mysql-db=test --tables=1 --table-size=1000 --threads=1 --time=120  --percentile=50 --report-interval=1 $SYSBEN_DIR/oltp_point_select.lua run >> $LOG_DIR/c3/front_1/parties.log & 
  sleep 1
  TLIST=$(ps -e -T | grep mysqld | awk '{print $2}' | sort -h | tail -1)
  for T in $TLIST; do (echo "$T") | sudo tee /sys/fs/cgroup/cpuset/hu_front_1/tasks; done 
  for i in {2..6}
  do
    ./back_parties.sh $i >> $LOG_DIR/c3/back_$i/parties.log &
    sleep 1
    TLIST=$(ps -e -T | grep mysqld | awk '{print $2}' | sort -h | tail -1)
    for T in $TLIST; do (echo "$T") | sudo tee /sys/fs/cgroup/cpuset/hu_back_$i/tasks; done
  done
  sleep 5
  echo "interference" >> $LOG_DIR/c3/front_1/parties.log 
  sudo ../../comparsion/parties_for_native.py $LOG_DIR/c3/ &
  sleep 100
  echo "interference end" >> $LOG_DIR/c3/front_1/parties.log
  sleep 20
  sudo pkill -f parties_for_native.py
  pkill back_parties
}

function parties_normal {
  sysbench --mysql-socket=$PSANDBOX_MYSQL_DIR/mysqld.sock --mysql-db=test --tables=1 --table-size=1000 --threads=1 --time=200  --percentile=50 --report-interval=10 $SYSBEN_DIR/oltp_point_select.lua run & 
  sleep 11
  echo "normal"
  sleep 90
  echo "normal end" 
  for i in {2..6}
  do
    ./back_parties.sh $i >> /dev/null &
  done
  sleep 10
  echo "interference"
  sleep 90
  echo "interference end" 
  sleep 10
  pkill parties_for_native
  pkill back_parties
}

function side {
  sysbench --mysql-socket=$PSANDBOX_MYSQL_DIR/mysqld.sock --mysql-db=test --tables=5 --table-size=1000 --threads=1 --time=100  $SYSBEN_DIR/oltp_point_select.lua run &
  sleep 1
  for i in {2..6}
  do
    time ./back_back.sh $i | mysql -S $PSANDBOX_MYSQL_DIR/mysqld.sock  > /dev/null &
  done
}

function interference {
  sysbench --mysql-socket=$PSANDBOX_MYSQL_DIR/mysqld.sock --mysql-db=test --tables=5 --table-size=1000 --threads=1 --time=120  --percentile=99 --report-interval=10 $SYSBEN_DIR/oltp_point_select.lua run & 
  sleep 3 
  sysbench --mysql-socket=$PSANDBOX_MYSQL_DIR/mysqld.sock --mysql-db=test --tables=5 --table-size=1000 --threads=5 --time=117 $SYSBEN_DIR/oltp_write_only.lua run > /dev/null &
  sleep 3
  echo "interference"
  sleep 90
  echo "interference end" 
  sleep 10
}


function no_interference {
  sysbench --mysql-socket=$PSANDBOX_MYSQL_DIR/mysqld.sock --mysql-db=test --tables=5 --table-size=1000 --threads=1 --time=107  --percentile=99 --report-interval=10 $SYSBEN_DIR/oltp_point_select.lua run & 
  sleep 11
  echo "normal"
  sleep 90
  echo "normal end" 
  sleep 10
}


if [[ $1 == 1 ]]; then
   echo "run c3"
   cp ../../libpsandbox.so $PSANDBOXDIR/build/libs/libpsandbox.so
elif [[ $1 == 2 ]]; then
  echo "run c3 cgroup"
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
  echo "run c3 psandbox"
  cp ../../libpsandbox_psandbox.so $PSANDBOXDIR/build/libs/libpsandbox.so
elif [[ $1 == 4 ]]; then
  echo "run c3 side psandbox"
  cp ../../libpsandbox_psandbox.so $PSANDBOXDIR/build/libs/libpsandbox.so
elif [[ $1 == 5 ]]; then
  echo "run c3 tail"
  cp ../../libpsandbox.so $PSANDBOXDIR/build/libs/libpsandbox.so
elif [[ $1 == 6 ]]; then
  echo "run c3 parties"
  sudo cgdelete -g cpuset:/hu_front_1
  sudo cgcreate -g cpuset:/hu_front_1
  echo "0" | sudo tee /sys/fs/cgroup/cpuset/hu_front_1/cpuset.mems
  echo "0-19" | sudo tee /sys/fs/cgroup/cpuset/hu_front_1/cpuset.cpus
  for i in {2..6}
  do
    sudo cgdelete -g cpuset:/hu_back_$i
    sudo cgcreate -g cpuset:/hu_back_$i
    echo "0" | sudo tee /sys/fs/cgroup/cpuset/hu_back_$i/cpuset.mems
    echo "0-19" | sudo tee /sys/fs/cgroup/cpuset/hu_back_$i/cpuset.cpus
  done

  cp ../../libpsandbox.so $PSANDBOXDIR/build/libs/libpsandbox.so
elif [[ $1 == 7 ]]; then
  echo "run c3 parties baseline"
  cp ../../libpsandbox.so $PSANDBOXDIR/build/libs/libpsandbox.so
elif [[ $1 == 8 ]]; then
  echo "run c3 retro"
  cp ../../libretro.so $PSANDBOXDIR/build/libs/libpsandbox.so
elif [[ $1 == 9 ]]; then
  echo "run c3 psp"
  cp ../../libpsandbox.so $PSANDBOXDIR/build/libs/libpsandbox.so
fi

if [[ $1 != 9 ]]; then
mkdir -p $LOG_DIR/c3
mysqld --defaults-file=my.cnf &
sleep 5
if [[ $0 == 2 ]]; then
  TLIST=$(ps -e -T | grep mysqld | awk '{print $2}' | sort -h)
  for T in $TLIST; do (echo "$T") | sudo tee /sys/fs/cgroup/cpu/cpuback/tasks; done >> /dev/null
fi

sysbench --mysql-socket=$PSANDBOX_MYSQL_DIR/mysqld.sock --mysql-db=test --tables=6 --table-size=1000 --threads=1 --time=70 $SYSBEN_DIR/oltp_point_select.lua --report-interval=3 cleanup >> /dev/null
sysbench --mysql-socket=$PSANDBOX_MYSQL_DIR/mysqld.sock --mysql-db=test --tables=6 --table-size=1000 --threads=1 --time=70 $SYSBEN_DIR/oltp_point_select.lua --report-interval=3 prepare >> /dev/null
fi
if [[ $1 == 1 ]]; then
  normal > $LOG_DIR/c3/no_psandbox.log
  #normal
elif [[ $1 == 2 ]]; then
  cgroup > $LOG_DIR/c3/cgroup.log
  #cgroup
elif [[ $1 == 3 ]]; then
  psandbox > $LOG_DIR/c3/psandbox.log
  #psandbox
elif [[ $1 == 4 ]]; then
  side > $LOG_DIR/c3/side_psandbox.log
  #side
elif [[ $1 == 5 ]]; then
  no_interference
  mysqladmin -S $PSANDBOX_MYSQL_DIR/mysqld.sock -u root shutdown
  mysqld --defaults-file=../mysql.cnf &
  sleep 5
  interference
elif [[ $1 == 6 ]]; then
  mkdir -p $LOG_DIR/c3/front_1
  for i in {2..6}
  do
    mkdir -p $LOG_DIR/c3/back_$i
  done  
  parties
elif [[ $1 == 7 ]]; then
  parties_normal > $LOG_DIR/c3/parties_baseline.log
elif [[ $1 == 8 ]]; then
    psandbox > $LOG_DIR/c3/retro.log
elif [[ $1 == 9 ]]; then
    ${PSP_DIR}/sosp_aec/psandbox_script/mysql_server3.sh
fi


mysqladmin -S $PSANDBOX_MYSQL_DIR/mysqld.sock -u root shutdown
sleep 10
