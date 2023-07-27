#!/bin/bash

LOG_DIR="$(pwd)/../../../result/overhead/"
# change the client_ip in bind to gettpid

function run() {
   ab -s 10 -t $2 -n 1000000 -c $1 http://128.110.218.66:8080/index.html
}
 


if [[ $1 == 0 ]]; then
    echo "run normal"
    cp ../../libpsandbox.so $PSANDBOXDIR/build/libs/libpsandbox.so
elif [[ $1 == 1 ]]; then
   echo "run psandbox"
   cp ../../libpsandbox_psandbox.so $PSANDBOXDIR/build/libs/libpsandbox.so
fi

cp httpd.conf $PSANDBOX_APACHE_DIR/conf/
cp index.html $PSANDBOX_APACHE_DIR/htdocs/
mkdir -p $LOG_DIR/apache
apachectl -k start


if [[ $1 == 0 ]]; then
    run $2 $3 > $LOG_DIR/apache/normal_$2.log
elif [[ $1 == 1 ]]; then
    run $2 $3 > $LOG_DIR/apache/psandbox_normal_$2.log
fi
apachectl -k stop
sleep 10
