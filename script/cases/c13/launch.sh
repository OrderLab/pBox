#!/bin/bash

LOG_DIR="$(pwd)/../../../result/cases/"

function normal {
  cp php-fpm_normal.conf $PSANDBOX_APACHE_DIR/php/etc/php-fpm.conf
  $PSANDBOX_APACHE_DIR/php/sbin/php-fpm --fpm-config $PSANDBOX_APACHE_DIR/php/etc/php-fpm.conf
  apachectl -k start
  echo "start normal"
  sleep 20
  ./victim.sh >> $LOG_DIR/c13/no_interference.log
  #ssh client1 'cd eval_script/script/cases/c13/ && ./noisy-neighbor.sh' /dev/null 2>&1 &
  #ssh client2 'cd eval_script/script/cases/c13/ && ./noisy-neighbor.sh' /dev/null 2>&1 &
  #ssh client3 'cd eval_script/script/cases/c13/ && ./noisy-neighbor.sh' /dev/null 2>&1 &
}

function interference {
  cp php-fpm.conf $PSANDBOX_APACHE_DIR/php/etc/php-fpm.conf
  $PSANDBOX_APACHE_DIR/php/sbin/php-fpm --fpm-config $PSANDBOX_APACHE_DIR/php/etc/php-fpm.conf
  apachectl -k start
  echo "start interference"
  sleep 20
  ./victim.sh >> $LOG_DIR/c13/no_psandbox.log
  #ssh client1 'cd eval_script/script/cases/c13/ && ./noisy-neighbor.sh' /dev/null 2>&1 &
  #ssh client2 'cd eval_script/script/cases/c13/ && ./noisy-neighbor.sh' /dev/null 2>&1 &
  #ssh client3 'cd eval_script/script/cases/c13/ && ./noisy-neighbor.sh' /dev/null 2>&1 &
}

function cgroup {
  cp php-fpm.conf $PSANDBOX_APACHE_DIR/php/etc/php-fpm.conf
  $PSANDBOX_APACHE_DIR/php/sbin/php-fpm --fpm-config $PSANDBOX_APACHE_DIR/php/etc/php-fpm.conf
  apachectl -k start
  echo "start cgroup"
  sleep 20
  TLIST=$(ps -e -T | grep "httpd" | awk '{print $2}' | sort -h)
  for T in $TLIST; do echo "$T" | sudo tee /sys/fs/cgroup/cpu/apache/tasks; done >> /dev/null
  #ssh client1 'cd eval_script/script/cases/c12/ && ./noisy-neighbor.sh' /dev/null 2>&1 &
  #ssh client2 'cd eval_script/script/cases/c12/ && ./noisy-neighbor.sh' /dev/null 2>&1 &
  #ssh client3 'cd eval_script/script/cases/c12/ && ./noisy-neighbor.sh' /dev/null 2>&1 &
  ./victim.sh >> $LOG_DIR/c13/cgroup.log
}

function psandbox {
  cp php-fpm.conf $PSANDBOX_APACHE_DIR/php/etc/php-fpm.conf
  $PSANDBOX_APACHE_DIR/php/sbin/php-fpm --fpm-config $PSANDBOX_APACHE_DIR/php/etc/php-fpm.conf
  apachectl -k start
  echo "start psandbox"
  sleep 20
  ./victim.sh >> $LOG_DIR/c13/psandbox.log
  #ssh client1 'cd eval_script/script/cases/c13/ && ./noisy-neighbor.sh' /dev/null 2>&1 &
  #ssh client2 'cd eval_script/script/cases/c13/ && ./noisy-neighbor.sh' /dev/null 2>&1 &
  #ssh client3 'cd eval_script/script/cases/c13/ && ./noisy-neighbor.sh' /dev/null 2>&1 &
}

function parties_normal {
  cp php-fpm_normal.conf $PSANDBOX_APACHE_DIR/php/etc/php-fpm.conf
  $PSANDBOX_APACHE_DIR/php/sbin/php-fpm --fpm-config $PSANDBOX_APACHE_DIR/php/etc/php-fpm.conf
  apachectl -k start
  sleep 5
  ab -s 10 -t 110 -c 1 http://127.0.0.1:8080/index.php\?arg\=a >> /dev/null &
  ab -s 10 -t 110 -c 1 http://127.0.0.1:8080/index.php\?arg\=a >> /dev/null &
  ab -s 10 -t 110 -c 1 http://127.0.0.1:8080/index.php\?arg\=a >> /dev/null &
  ab -s 10 -t 90 -n 100000000 -c 1 http://127.0.0.1:8080/index.php >> $LOG_DIR/c13/no_interference.log 
  pkill httpd
  pkill php-fpm
  sleep 10
  cp php-fpm.conf $PSANDBOX_APACHE_DIR/php/etc/php-fpm.conf
  $PSANDBOX_APACHE_DIR/php/sbin/php-fpm --fpm-config $PSANDBOX_APACHE_DIR/php/etc/php-fpm.conf
  apachectl -k start
  sleep 5
  ab -s 10 -t 110 -c 1 http://127.0.0.1:8080/index.php\?arg\=a >> /dev/null &
  TLIST=$(ps -e -T | grep "httpd" | awk '{print $2}' | sort -h)
  for T in $TLIST; do echo "$T" | sudo tee /sys/fs/cgroup/cpuset/hu_apache_2/tasks; done >> /dev/null
  ab -s 10 -t 110 -c 1 http://127.0.0.1:8080/index.php\?arg\=a >> /dev/null &
  TLIST=$(ps -e -T | grep "httpd" | awk '{print $2}' | sort -h)
  for T in $TLIST; do echo "$T" | sudo tee /sys/fs/cgroup/cpuset/hu_apache_3/tasks; done >> /dev/null
  ab -s 10 -t 110 -c 1 http://127.0.0.1:8080/index.php\?arg\=a >> /dev/null &
  TLIST=$(ps -e -T | grep "httpd" | awk '{print $2}' | sort -h)
  for T in $TLIST; do echo "$T" | sudo tee /sys/fs/cgroup/cpuset/hu_apache_4/tasks; done >> /dev/null
  ab -s 10 -t 90 -n 100000000 -c 1 http://127.0.0.1:8080/index.php >> $LOG_DIR/c13/no_parties.log &
  TLIST=$(ps -e -T | grep "httpd" | awk '{print $2}' | sort -h)
  for T in $TLIST; do echo "$T" | sudo tee /sys/fs/cgroup/cpuset/hu_apache_1/tasks; done >> /dev/null
  sleep 95
}

function parties {
  cp php-fpm.conf $PSANDBOX_APACHE_DIR/php/etc/php-fpm.conf
  $PSANDBOX_APACHE_DIR/php/sbin/php-fpm --fpm-config $PSANDBOX_APACHE_DIR/php/etc/php-fpm.conf
  apachectl -k start
  sleep 5
  ab -s 10 -t 110 -c 1 http://127.0.0.1:8080/index.php\?arg\=a >> /dev/null &
  TLIST=$(ps -e -T | grep "httpd" | awk '{print $2}' | sort -h)
  for T in $TLIST; do echo "$T" | sudo tee /sys/fs/cgroup/cpuset/hu_apache_2/tasks; done >> /dev/null
  ab -s 10 -t 110 -c 1 http://127.0.0.1:8080/index.php\?arg\=a >> /dev/null &
  TLIST=$(ps -e -T | grep "httpd" | awk '{print $2}' | sort -h)
  for T in $TLIST; do echo "$T" | sudo tee /sys/fs/cgroup/cpuset/hu_apache_3/tasks; done >> /dev/null
  ab -s 10 -t 110 -c 1 http://127.0.0.1:8080/index.php\?arg\=a >> /dev/null &
  TLIST=$(ps -e -T | grep "httpd" | awk '{print $2}' | sort -h)
  for T in $TLIST; do echo "$T" | sudo tee /sys/fs/cgroup/cpuset/hu_apache_4/tasks; done >> /dev/null
  ab -s 10 -t 90 -n 100000000 -c 1 http://127.0.0.1:8080/index.php >> $LOG_DIR/c13/parties.log &
  TLIST=$(ps -e -T | grep "httpd" | awk '{print $2}' | sort -h)
  for T in $TLIST; do echo "$T" | sudo tee /sys/fs/cgroup/cpuset/hu_apache_1/tasks; done >> /dev/null
  sudo ../../comparsion/parties_for_native.py $LOG_DIR/c13/ &
  sleep 95
  sudo pkill -f parties_for_native.py
}

if [[ $1 == 1 ]]; then
    echo "run c13"
    cp ../../libpsandbox.so $PSANDBOXDIR/build/libs/libpsandbox.so
elif [[ $1 == 2 ]]; then
   echo "run c13 cgroup"
   sudo cgdelete -g cpu:/apache
   sudo cgcreate -g cpu:/apache
   sudo cgset -r cpu.shares=2048 apache
   cp ../../libpsandbox.so $PSANDBOXDIR/build/libs/libpsandbox.so
elif [[ $1 == 3 ]]; then
   echo "run c13 psandbox"
   cp ../../libpsandbox_psandbox.so $PSANDBOXDIR/build/libs/libpsandbox.so
elif [[ $1 == 6 ]]; then
  echo "run c13 parties"
  sudo cgdelete -g cpuset:/hu_apache_1
  sudo cgcreate -g cpuset:/hu_apache_1
  echo "0" | sudo tee /sys/fs/cgroup/cpuset/hu_apache_1/cpuset.mems
  echo "0-19" | sudo tee /sys/fs/cgroup/cpuset/hu_apache_1/cpuset.cpus
  sudo cgdelete -g cpuset:/hu_apache_2
  sudo cgcreate -g cpuset:/hu_apache_2
  echo "0" | sudo tee /sys/fs/cgroup/cpuset/hu_apache_2/cpuset.mems
  echo "0-19" | sudo tee /sys/fs/cgroup/cpuset/hu_apache_2/cpuset.cpus
  sudo cgdelete -g cpuset:/hu_apache_3
  sudo cgcreate -g cpuset:/hu_apache_3
  echo "0" | sudo tee /sys/fs/cgroup/cpuset/hu_apache_3/cpuset.mems
  echo "0-19" | sudo tee /sys/fs/cgroup/cpuset/hu_apache_3/cpuset.cpus
  sudo cgdelete -g cpuset:/hu_apache_4
  sudo cgcreate -g cpuset:/hu_apache_4
  echo "0" | sudo tee /sys/fs/cgroup/cpuset/hu_apache_4/cpuset.mems
  echo "0-19" | sudo tee /sys/fs/cgroup/cpuset/hu_apache_4/cpuset.cpus
  cp ../../libpsandbox.so $PSANDBOXDIR/build/libs/libpsandbox.so
elif [[ $1 == 7 ]]; then
  echo "run c13 parties baseline"
    sudo cgdelete -g cpuset:/hu_apache_1
  sudo cgcreate -g cpuset:/hu_apache_1
  echo "0" | sudo tee /sys/fs/cgroup/cpuset/hu_apache_1/cpuset.mems
  echo "0-19" | sudo tee /sys/fs/cgroup/cpuset/hu_apache_1/cpuset.cpus
  sudo cgdelete -g cpuset:/hu_apache_2
  sudo cgcreate -g cpuset:/hu_apache_2
  echo "0" | sudo tee /sys/fs/cgroup/cpuset/hu_apache_2/cpuset.mems
  echo "0-19" | sudo tee /sys/fs/cgroup/cpuset/hu_apache_2/cpuset.cpus
  sudo cgdelete -g cpuset:/hu_apache_3
  sudo cgcreate -g cpuset:/hu_apache_3
  echo "0" | sudo tee /sys/fs/cgroup/cpuset/hu_apache_3/cpuset.mems
  echo "0-19" | sudo tee /sys/fs/cgroup/cpuset/hu_apache_3/cpuset.cpus
  sudo cgdelete -g cpuset:/hu_apache_4
  sudo cgcreate -g cpuset:/hu_apache_4
  echo "0" | sudo tee /sys/fs/cgroup/cpuset/hu_apache_4/cpuset.mems
  echo "0-19" | sudo tee /sys/fs/cgroup/cpuset/hu_apache_4/cpuset.cpus
  cp ../../libpsandbox.so $PSANDBOXDIR/build/libs/libpsandbox.so
fi

pkill php-fpm
cp httpd.conf $PSANDBOX_APACHE_DIR/conf/
cp index.php $PSANDBOX_APACHE_DIR/htdocs/
cp index.html $PSANDBOX_APACHE_DIR/htdocs/
mkdir -p $LOG_DIR/c13

sleep 1
if [[ $0 == 2 ]]; then
  TLIST=$(ps -e -T | grep "httpd" | awk '{print $2}' | sort -h)
  for T in $TLIST; do echo "$T" | sudo tee /sys/fs/cgroup/cpu/apache/tasks; done >> /dev/null
fi


if [[ $1 == 1 ]]; then
#    normal
#    pkill httpd
#    pkill php-fpm
#    sleep 5
    interference 
elif [[ $1 == 2 ]]; then
    cgroup 
elif [[ $1 == 3 ]]; then
    psandbox
elif [[ $1 == 6 ]]; then
  mkdir -p $LOG_DIR/c13/apache_1
  mkdir -p $LOG_DIR/c13/apache_2
  mkdir -p $LOG_DIR/c13/apache_3
  mkdir -p $LOG_DIR/c13/apache_4
  parties
elif [[ $1 == 7 ]]; then
  parties_normal
fi
apachectl -k stop
sleep 5
