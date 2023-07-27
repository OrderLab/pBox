#!/bin/bash

LOG_DIR="$(pwd)/../../../result/overhead/"
# change the client_ip in bind to gettpid

function run() {
   ab -s 10 -t $2 -n 1000000 -c $1 http://127.0.0.1:8081/index.html
}
 


if [[ $1 == 0 ]]; then
    echo "run normal"
    cp ../../libpsandbox.so $PSANDBOXDIR/build/libs/libpsandbox.so
elif [[ $1 == 1 ]]; then
   echo "run psandbox"
   cp ../../libpsandbox_psandbox.so $PSANDBOXDIR/build/libs/libpsandbox.so
fi

cp httpd.conf $PSANDBOX_VARNISH_DIR/../httpd/dist/conf/
cp php_wrapper $PSANDBOX_VARNISH_DIR/../httpd/dist/php/bin/php-wrapper
cp $PSANDBOX_VARNISH_DIR/../httpd/php-7.4.23/php.ini-development $PSANDBOX_VARNISH_DIR/../httpd/dist/php/php.ini
cp index.html $PSANDBOX_VARNISH_DIR/../httpd/dist/htdocs/
cp 500M.html $PSANDBOX_VARNISH_DIR/../httpd/dist/htdocs/
mkdir -p $LOG_DIR/varnish
$PSANDBOX_VARNISH_DIR/../httpd/dist/bin/apachectl -k start
sleep 5
varnishd -a :8081 -f $PSANDBOX_VARNISH_DIR/../script/default.vcl -s malloc,256m -p thread_pools=1 -p thread_pool_min=1 -p thread_pool_max=100 -p thread_pool_timeout=10
sleep 5

if [[ $1 == 0 ]]; then
    run $2 $3 > $LOG_DIR/varnish/normal_$2.log
elif [[ $1 == 1 ]]; then
    run $2 $3 > $LOG_DIR/varnish/psandbox_normal_$2.log
fi
pkill httpd 
pkill varnish
sleep 10
