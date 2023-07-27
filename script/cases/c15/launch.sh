#!/bin/bash

LOG_DIR="$(pwd)/../../../result/cases/"

function normal {
  ab -t 90 -n 50000000 -c 1 http://127.0.0.1:8081/index.html >> $LOG_DIR/c15/no_interference.log
  pkill httpd
}

function interference {
  ab -t 90 -n 50000000 -c 16 http://127.0.0.1:8081/index.html >> $LOG_DIR/c15/no_psandbox.log 
  sleep 1
  pkill httpd
}

function cgroup {
  TLIST=$(ps -e -T | grep "httpd" | awk '{print $2}' | sort -h)
  for T in $TLIST; do echo "$T" | sudo tee /sys/fs/cgroup/cpu/apache/tasks; done >> /dev/null
  ab -t 90 -n 50000000 -c 16 http://127.0.0.1:8081/index.html >> $LOG_DIR/c15/cgroup.log
  pkill httpd
}

function psandbox {
  ab -t 30 -n 50000000 -c 16 http://127.0.0.1:8081/index.html >> $LOG_DIR/c15/psandbox.log 
  pkill httpd
}

function parties_normal {
  sleep 5
  ab -t 90 -n 50000000 -c 1 http://127.0.0.1:8081/index.html >> $LOG_DIR/c15/no_interference.log
  sleep 1
  pkill varnishd
  sleep 5
  varnishd -a :8081 -f $PSANDBOX_VARNISH_DIR/../script/default.vcl -s malloc,256m -p thread_pools=1 -p thread_pool_min=1 -p thread_pool_max=100 -p thread_pool_timeout=10
  sleep 5
  ab -s 10 -t 100 -n 50000000 -c 16 http://127.0.0.1:8081/index.html >> /dev/null &
  TLIST=$(ps -e -T | grep "varnish" | awk '{print $2}' | sort -h)
  for T in $TLIST; do echo "$T" | sudo tee /sys/fs/cgroup/cpuset/hu_apache_2/tasks; done >> /dev/null
  ab -s 10 -t 90 -n 50000000 -c 16 http://127.0.0.1:8081/index.html >> $LOG_DIR/c15/no_parties.log &
  TLIST=$(ps -e -T | grep "varnish" | awk '{print $2}' | sort -h)
  for T in $TLIST; do echo "$T" | sudo tee /sys/fs/cgroup/cpuset/hu_apache_1/tasks; done >> /dev/null
  sleep 95
}

function parties {
  sleep 5
  ab -s 10 -t 90 -n 50000000 -c 16 http://127.0.0.1:8081/index.html >> /dev/null &
  TLIST=$(ps -e -T | grep "varnish" | awk '{print $2}' | sort -h)
  for T in $TLIST; do echo "$T" | sudo tee /sys/fs/cgroup/cpuset/hu_apache_2/tasks; done >> /dev/null
  ab -s 10 -t 90 -n 50000000 -c 16 http://127.0.0.1:8081/index.html >> $LOG_DIR/c15/parties.log &
  TLIST=$(ps -e -T | grep "varnish" | awk '{print $2}' | sort -h)
  for T in $TLIST; do echo "$T" | sudo tee /sys/fs/cgroup/cpuset/hu_apache_1/tasks; done >> /dev/null
  sudo ../../comparsion/parties_for_native.py $LOG_DIR/c15/ &
  sleep 95
  sudo pkill -f parties_for_native.py
}


if [[ $1 == 1 ]]; then
  echo "run c15"
  cp ../../libpsandbox.so $PSANDBOXDIR/build/libs/libpsandbox.so
elif [[ $1 == 2 ]]; then
  echo "run c15 cgroup"
  sudo cgdelete -g cpu:/apache
  sudo cgcreate -g cpu:/apache
  sudo cgset -r cpu.shares=2048 apache
  cp ../../libpsandbox.so $PSANDBOXDIR/build/libs/libpsandbox.so
elif [[ $1 == 3 ]]; then
  echo "run c15 psandbox"
  cp ../../libpsandbox_psandbox.so $PSANDBOXDIR/build/libs/libpsandbox.so
elif [[ $1 == 6 ]]; then
  echo "run c15 parties"
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
  cp ../../libpsandbox.so $PSANDBOXDIR/build/libs/libpsandbox.so
elif [[ $1 == 7 ]]; then
  echo "run c15 parties baseline"
  cp ../../libpsandbox.so $PSANDBOXDIR/build/libs/libpsandbox.so
fi

cp httpd.conf $PSANDBOX_VARNISH_DIR/../httpd/dist/conf/
cp php_wrapper $PSANDBOX_VARNISH_DIR/../httpd/dist/php/bin/php-wrapper
cp $PSANDBOX_VARNISH_DIR/../httpd/php-7.4.23/php.ini-development $PSANDBOX_VARNISH_DIR/../httpd/dist/php/php.ini
cp index.html $PSANDBOX_VARNISH_DIR/../httpd/dist/htdocs/
mkdir -p $LOG_DIR/c15
$PSANDBOX_VARNISH_DIR/../httpd/dist/bin/apachectl -k start
varnishd -a :8081 -f $PSANDBOX_VARNISH_DIR/../script/default.vcl -s malloc,256m -p thread_pools=1 -p thread_pool_min=1 -p thread_pool_max=100 -p thread_pool_timeout=10
sleep 1

if [[ $1 == 1 ]]; then
  normal
#  pkill varnishd
#  sleep 5
#  $PSANDBOX_VARNISH_DIR/../httpd/dist/bin/apachectl -k start
#  varnishd -a :8081 -f $PSANDBOX_VARNISH_DIR/../script/default.vcl -s malloc,256m -p thread_pools=1 -p thread_pool_min=1 -p thread_pool_max=100 -p thread_pool_timeout=10
#  sleep 5
#  interference 
elif [[ $1 == 2 ]]; then
  cgroup 
elif [[ $1 == 3 ]]; then
  psandbox
elif [[ $1 == 6 ]]; then
  mkdir -p $LOG_DIR/c15/apache_1
  mkdir -p $LOG_DIR/c15/apache_2
  parties
elif [[ $1 == 7 ]]; then
  parties_normal
fi

sleep 1
pkill varnishd
apachectl -k stop
