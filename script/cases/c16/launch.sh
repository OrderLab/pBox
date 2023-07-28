#!/bin/bash

LOG_DIR="$(pwd)/../../../result/cases/"

function normal {
  memcached -m 2048 -u root -t 4 &
  sleep 5
  mutilate -s 127.0.0.1:11211 -u 0.1 -T 8 -t 60
  pkill memcached
  sleep 5
}

function interference {
  memcached -m 2048 -u root -t 16 &
  sleep 5
  mutilate -s 127.0.0.1:11211 -u 0.1 -T 8 -t 60
  pkill memcached
  sleep 5
}


function cgroup {
  memcached -m 2048 -u root -t 16 &
  sleep 1
  if [[ $0 == 2 ]]; then
    TLIST=$(ps -e -T | grep postgre | awk '{print $2}' | sort -h)
    for T in $TLIST; do echo "$T" | sudo tee /sys/fs/cgroup/cpu/cpuback/tasks; done >> /dev/null
  fi
  sleep 5
  mutilate -s 127.0.0.1:11211 -u 0.1 -T 8 -t 60
  pkill memcached
  sleep 5
}

function parties_normal {
  memcached -m 2048 -u root -t 4 &
  sleep 5
  mutilate -s 127.0.0.1:11211 -u 0.1 -T 8 -t 60
  pkill memcached
  sleep 5
}

function parties {
  memcached -m 2048 -u root -t 16 > $LOG_DIR/c1/front_1/parties.log &
  sleep 1
  TLIST=$(ps -e -T | grep memcached | awk '{print $2}' | sort -h | tail -1)
  for T in $TLIST; do (echo "$T") | sudo tee /sys/fs/cgroup/cpuset/hu_front_1/tasks; done
  sleep 5
  mutilate -s 127.0.0.1:11211 -u 0.1 -T 8 -t 60
  sudo ../../comparsion/parties_for_native.py $LOG_DIR/c16/ &
  pkill memcached
  sleep 5

  sleep 90
  echo "interference end" &>> $LOG_DIR/c1/front_1/parties.log
  sleep 20
  sudo pkill -f parties_for_native.py
  pkill back_parties
}


if [[ $1 == 1 ]]; then
    echo "run c16"
    cp ../../libpsandbox.so $PSANDBOXDIR/build/libs/libpsandbox.so
elif [[ $1 == 2 ]]; then
   echo "run c16 cgroup"
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
   echo "run c16 psandbox"
   cp ../../libpsandbox_psandbox.so $PSANDBOXDIR/build/libs/libpsandbox.so
elif [[ $1 == 6 ]]; then
  echo "run c10 parties"
  sudo cgdelete -g cpuset:/hu_front_1
  sudo cgcreate -g cpuset:/hu_front_1
  echo "0" | sudo tee /sys/fs/cgroup/cpuset/hu_front_1/cpuset.mems
  echo "0-19" | sudo tee /sys/fs/cgroup/cpuset/hu_front_1/cpuset.cpus
  sudo cgdelete -g cpuset:/hu_back_1
  sudo cgcreate -g cpuset:/hu_back_1
  echo "0" | sudo tee /sys/fs/cgroup/cpuset/hu_back_1/cpuset.mems
  echo "0-19" | sudo tee /sys/fs/cgroup/cpuset/hu_back_1/cpuset.cpus
  sudo cgdelete -g cpuset:/hu_front_2
  sudo cgcreate -g cpuset:/hu_front_2
  echo "0" | sudo tee /sys/fs/cgroup/cpuset/hu_front_2/cpuset.mems
  echo "0-19" | sudo tee /sys/fs/cgroup/cpuset/hu_front_2/cpuset.cpus
  cp ../../libpsandbox.so $PSANDBOXDIR/build/libs/libpsandbox.so
elif [[ $1 == 7 ]]; then
  echo "run c16 parties baseline"
  cp ../../libpsandbox.so $PSANDBOXDIR/build/libs/libpsandbox.so
elif [[ $1 == 8 ]]; then
  echo "run c16 retro"
  cp ../../libretro.so $PSANDBOXDIR/build/libs/libpsandbox.so
elif [[ $1 == 9 ]]; then
  echo "run c16 psp"
  cp ../../libpsandbox.so $PSANDBOXDIR/build/libs/libpsandbox.so
fi

mkdir -p  $LOG_DIR/c16

if [[ $1 == 1 ]]; then
    interference > $LOG_DIR/c16/no_psandbox.log
    #interference
    normal  > $LOG_DIR/c16/no_interference.log
    #normal
elif [[ $1 == 2 ]]; then
    cgroup > $LOG_DIR/c16/cgroup.log
    #interference
elif [[ $1 == 3 ]]; then
    interference > $LOG_DIR/c16/psandbox.log
    #interference
elif [[ $1 == 6 ]]; then
  mkdir -p $LOG_DIR/c16/front_1
  mkdir -p $LOG_DIR/c16/back_1
  parties
elif [[ $1 == 7 ]]; then
  parties_normal > $LOG_DIR/c16/no_interference_parties.log
  interference > $LOG_DIR/c16/no_parties.log
elif [[ $1 == 8 ]]; then
  interference > $LOG_DIR/c16/retro.log
elif [[ $1 == 9 ]]; then
    parties_normal > $LOG_DIR/c5/parties_baseline.log
fi

pkill memcached
sleep 10
sleep 10
