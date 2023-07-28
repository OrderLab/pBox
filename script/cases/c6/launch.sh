#!/bin/bash

LOG_DIR="$(pwd)/../../../result/cases/"

function normal {
  ./pgbench postgres -h /tmp -P 10 -c 1 -T 107 -f read.txt &>> $LOG_DIR/c6/no_psandbox.log &
  sleep 11
  echo "normal" &>> $LOG_DIR/c6/no_psandbox.log
  sleep 90
  echo "normal end"  &>> $LOG_DIR/c6/no_psandbox.log
  sleep 10
  ./pgbench postgres -h /tmp -P 10 -c 1 -T 137 -f read.txt &>> $LOG_DIR/c6/no_psandbox.log &
  sleep 1
  ./back.sh >> /dev/null &
  sleep 10
  echo "interference"  &>> $LOG_DIR/c6/no_psandbox.log
  sleep 90
  echo "interference end"  &>> $LOG_DIR/c6/no_psandbox.log
  sleep 5
}

function cgroup {
  ./back.sh >> /dev/null &
  sleep 10
  N=$(ps -e -T | grep postgre | awk '{print $2}' | sort -h | wc -l)
  TLIST=$(ps -e -T | grep postgre | awk '{print $2}' | sort -h | tail -n +${N})
  for T in $TLIST; do echo "$T" | sudo tee /sys/fs/cgroup/cpu/cpuwrite/tasks; done >> /dev/null
  sleep 1
  ./pgbench postgres -h /tmp  -P 10 -c 1 -T 137 -f read.txt &>> $LOG_DIR/c6/cgroup.log &
  sleep 1
  N=$(ps -e -T | grep postgre | awk '{print $2}' | sort -h | wc -l)
  TLIST=$(ps -e -T | grep postgre | awk '{print $2}' | sort -h | tail -n +${N})
  for T in $TLIST; do echo "$T" | sudo tee /sys/fs/cgroup/cpu/cpuread/tasks; done >> /dev/null
  sleep 10
  echo "interference"  &>> $LOG_DIR/c6/cgroup.log
  sleep 90
  echo "interference end"  &>> $LOG_DIR/c6/cgroup.log
  sleep 5
}

function psandbox {
  ./pgbench postgres -h /tmp -P 10 -c 1 -T 207 -f read.txt &>> $LOG_DIR/c6/psandbox.log &
  sleep 1
  ./back.sh >> /dev/null &
  sleep 60
  echo "interference" &>> $LOG_DIR/c6/psandbox.log
  sleep 90
  echo "interference end" &>> $LOG_DIR/c6/psandbox.log
  sleep 20
}

function retro {
  ./pgbench postgres -h /tmp -P 10 -c 1 -T 107 -f read.txt &>> $LOG_DIR/c6/retro.log &
  sleep 1
  ./back.sh >> /dev/null &
  sleep 10
  echo "interference" &>> $LOG_DIR/c6/retro.log
  sleep 90
  echo "interference end" &>> $LOG_DIR/c6/retro.log
  sleep 20
}

function parties {
  ./pgbench postgres -h /tmp -P 1 -c 1 -T 107 -f read.txt &>> $LOG_DIR/c6/front_1/parties.log &
  sleep 1
  TLIST=$(ps -e -T | grep postgre | awk '{print $2}' | sort -h | tail -1)
  for T in $TLIST; do (echo "$T") | sudo tee /sys/fs/cgroup/cpuset/hu_front_1/tasks; done
  sleep 11
  ./back_parties.sh > $LOG_DIR/c6/back_1/parties.log &
  sleep 5
  TLIST=$(ps -e -T | grep postgre | awk '{print $2}' | sort -h | tail -1)
  for T in $TLIST; do (echo "$T") | sudo tee /sys/fs/cgroup/cpuset/hu_back_1/tasks; done
  sleep 10
  echo "interference" >> $LOG_DIR/c6/front_1/parties.log
  sudo ../../comparsion/parties_for_native.py $LOG_DIR/c6/ &
  sleep 60
  echo "interference end" >> $LOG_DIR/c6/front_1/parties.log
  sleep 10
  sudo pkill -f parties_for_native.py
}

function parties_normal {
  ./pgbench postgres -h /tmp -P 10 -c 1 -T 107 -f read.txt &>> $LOG_DIR/c6/parties_baseline.log &
  sleep 11
  echo "normal" >> $LOG_DIR/c6/parties_baseline.log
  sleep 90
  echo "normal end" >> $LOG_DIR/c6/parties_baseline.log
  sleep 10
  ./pgbench postgres -h /tmp -P 10 -c 1 -T 137 -f read.txt &>> $LOG_DIR/c6/parties_baseline.log &
  sleep 1
  ./back_parties.sh >> /dev/null &
  sleep 10
  echo "interference" >> $LOG_DIR/c6/parties_baseline.log
  sleep 90
  echo "interference end" >> $LOG_DIR/c6/parties_baseline.log
  sleep 5
}

function side {
  ./pgbench postgres -h /tmp -P 10 -c 1 -T 100 -f read.txt &
  sleep 1
  time ./back.sh
}

function no_interference {
  ./pgbench postgres -h /tmp -P 3 -c 1 -T 67 -f read.txt &
  sleep 4
  echo "normal"
  sleep 60
  echo "normal end"
  sleep 5
}

function interference {
  ./pgbench postgres -h /tmp -P 10 -c 1 -T 100 -f read.txt &
  sleep 1
   ./back.sh >> /dev/null &
}

function tail_psandbox {
  ./pgbench -h /tmp -U postgres -P 3 -c 1 -T 200 -f read.txt &
  sleep 1
  ./back.sh >> /dev/null &
}

if [[ $1 == 1 ]]; then
    echo "run c6"
    cp ../../libpsandbox.so $PSANDBOXDIR/build/libs/libpsandbox.so
elif [[ $1 == 2 ]]; then
   echo "run c6 cgroup"
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
   echo "run c6 psandbox"
   cp ../../libpsandbox.so $PSANDBOXDIR/build/libs/libpsandbox.so
elif [[ $1 == 4 ]]; then
  echo "run c6 side psandbox"
  cp ../../libpsandbox_psandbox.so $PSANDBOXDIR/build/libs/libpsandbox.so
elif [[ $1 == 5 ]]; then
  echo "run c6 tail"
  cp ../libpsandbox.so $PSANDBOXDIR/build/libs/libpsandbox.so
elif [[ $1 == 6 ]]; then
  echo "run c6 parties"
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
  echo "run c6 parties baseline"
  cp ../../libpsandbox.so $PSANDBOXDIR/build/libs/libpsandbox.so
elif [[ $1 == 8 ]]; then
  echo "run c6 retro"
  cp ../../libretro.so $PSANDBOXDIR/build/libs/libpsandbox.so
elif [[ $1 == 9 ]]; then
  echo "run c6 psp"
  cp ../../libpsandbox.so $PSANDBOXDIR/build/libs/libpsandbox.so
fi

cp gendata.pl $PSANDBOX_POSTGRES_DIR
cd $PSANDBOX_POSTGRES_DIR && ./gendata.pl
cd -
mkdir -p $LOG_DIR/c6
postgres -D $PSANDBOX_POSTGRES_DIR/data/ --config-file=$PSANDBOX_POSTGRES_DIR/data/postgresql.conf &
sleep 5
if [[ $0 == 2 ]]; then
    TLIST=$(ps -e -T | grep postgre | awk '{print $2}' | sort -h)
    for T in $TLIST; do echo "$T" | sudo tee /sys/fs/cgroup/cpu/cpuback/tasks; done >> /dev/null
fi
./create.sh 
if [[ $1 == 1 ]]; then
    #normal >> $LOG_DIR/c6/no_psandbox.log
    rm $LOG_DIR/c6/no_psandbox.log
    normal
elif [[ $1 == 2 ]]; then
    #cgroup >> $LOG_DIR/c6/cgroup.log
    rm $LOG_DIR/c6/cgroup.log
    cgroup
elif [[ $1 == 3 ]]; then
    #psandbox >> $LOG_DIR/c6/psandbox.log
    rm $LOG_DIR/c6/psandbox.log
    psandbox
elif [[ $1 == 4 ]]; then
    side >> $LOG_DIR/c6/side_psandbox.log
    #side
elif [[ $1 == 5 ]]; then
    no_interference
elif [[ $1 == 6 ]]; then
    mkdir -p $LOG_DIR/c6/front_1
    mkdir -p $LOG_DIR/c6/back_1
    rm $LOG_DIR/c6/parties.log
    parties 
elif [[ $1 == 7 ]]; then
    rm $LOG_DIR/c6/parties_baseline.log
    parties_normal
elif [[ $1 == 8 ]]; then
    rm $LOG_DIR/c6/retro.log
    retro 
elif [[ $1 == 9 ]]; then
    ${PSP_DIR}/sosp_aec/psandbox_script/postgre_server6.sh
fi
pkill postgre
sleep 10
