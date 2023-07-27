#!/bin/bash
LOG_DIR="$(pwd)/../../../result/overhead/"

# open the futex tracing

function write_run() {
  if [[ $1 == 1 ]]; then
     mutilate -s 127.0.0.1:11211 -u 0.9 -T 1  -t 90
  else
     mutilate -s 127.0.0.1:11211 -u 0.9 -T $(($1/4)) -c 4  -t 90 
  fi
}
 
function read_run() {
  if [[ $1 == 1 ]]; then
     mutilate -s 127.0.0.1:11211 -u 0.1 -T 1  -t 90
  else
     mutilate -s 127.0.0.1:11211 -u 0.1 -T $(($1/4)) -c 4 -t 90
  fi
}

if [[ $1 == 0 ]]; then
    echo "run normal"
    cp ../../libpsandbox.so $PSANDBOXDIR/build/libs/libpsandbox.so
elif [[ $1 == 1 ]]; then
   echo "run psandbox"
   cp ../../libpsandbox_psandbox.so $PSANDBOXDIR/build/libs/libpsandbox.so
fi

mkdir -p $LOG_DIR/memcached
memcached -m 2048  -u root -t 4 &
sleep 5

if [[ $2 == 0 ]]; then
    if [[ $1 == 0 ]]; then
        write_run $3 >> $LOG_DIR/memcached/write_$3.log
    elif [[ $1 == 1 ]]; then
	write_run $3  >> $LOG_DIR/memcached/psandbox_write_$3.log
    fi
elif [[ $2 == 1 ]]; then
    if [[ $1 == 0 ]]; then
        read_run $3  >> $LOG_DIR/memcached/read_$3.log
    elif [[ $1 == 1 ]]; then
	read_run $3  >> $LOG_DIR/memcached/psandbox_read_$3.log
    fi
fi

pkill memcached
sleep 5
