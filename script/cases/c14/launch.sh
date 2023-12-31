#!/bin/bash

LOG_DIR="$(pwd)/../../../result/cases/"
NOISE="$(envsubst < noisy-neighbor.sh)"

function normal {
    echo "start normal"
    ssh client1 "$NOISE" > /dev/null 2>&1 &
    ssh client2 "$NOISE" > /dev/null 2>&1 &
    ssh client3 "$NOISE" > /dev/null 2>&1 &
    ./victim.sh > $LOG_DIR/c14/no_interference.log
    sleep 3
    pkill httpd
}

function interference {
    echo "start interference"
    ssh client1 "$NOISE" > /dev/null 2>&1 &
    ssh client2 "$NOISE" > /dev/null 2>&1 &
    ssh client3 "$NOISE" > /dev/null 2>&1 &
    ./victim.sh > $LOG_DIR/c14/no_psandbox.log
    sleep 3
    pkill httpd
}

function cgroup {
    echo "start cgroup"
    TLIST=$(ps -e -T | grep "httpd" | awk '{print $2}' | sort -h)
    for T in $TLIST; do echo "$T" | sudo tee /sys/fs/cgroup/cpu/apache/tasks; done >> /dev/null
    ssh client1 "$NOISE" > /dev/null 2>&1 &
    ssh client2 "$NOISE" > /dev/null 2>&1 &
    ssh client3 "$NOISE" > /dev/null 2>&1 &
    ./victim.sh > $LOG_DIR/c14/cgroup.log
    sleep 1
    pkill httpd
}

function psandbox {
    echo "start psandbox"
    ssh client1 "$NOISE" > /dev/null 2>&1 &
    ssh client2 "$NOISE" > /dev/null 2>&1 &
    ssh client3 "$NOISE" > /dev/null 2>&1 &
    ./victim.sh > $LOG_DIR/c14/psandbox.log
    sleep 1
    pkill httpd
}

function retro {
    echo "start retro"
    ssh client1 "$NOISE" > /dev/null 2>&1 &
    ssh client2 "$NOISE" > /dev/null 2>&1 &
    ssh client3 "$NOISE" > /dev/null 2>&1 &
    ./victim.sh > $LOG_DIR/c14/retro.log
    sleep 1
    pkill httpd
}

function parties_normal {
    $PSANDBOX_VARNISH_DIR/../httpd/dist/bin/apachectl -k start
    varnishd -a :8081 -f $PSANDBOX_VARNISH_DIR/../script/default.vcl -s malloc,256m -p thread_pools=1 -p thread_pool_min=1 -p thread_pool_max=100 -p thread_pool_timeout=10
    sleep 20
    ab -s 100 -t 110 -c 1 http://127.0.0.1:8081/10M.html >> /dev/null &
    ab -s 100 -t 110 -c 1 http://127.0.0.1:8081/10M.html >> /dev/null &
    ab -s 100 -t 90 -n 100000000 -c 1 http://127.0.0.1:8081/index.html > $LOG_DIR/c14/no_interference_parties.log
    sleep 1
    pkill varnishd
    sleep 5
    varnishd -a :8081 -f $PSANDBOX_VARNISH_DIR/../script/default.vcl -s malloc,256m -p thread_pools=1 -p thread_pool_min=1 -p thread_pool_max=3 -p thread_pool_timeout=10
    sleep 20
    ab -s 100 -t 110 -c 1 http://127.0.0.1:8081/10M.html >> /dev/null &
    TLIST=$(ps -e -T | grep "varnish" | awk '{print $2}' | sort -h)
    for T in $TLIST; do echo "$T" | sudo tee /sys/fs/cgroup/cpuset/hu_apache_2/tasks; done >> /dev/null
    ab -s 100 -t 110 -c 1 http://127.0.0.1:8081/10M.html >> /dev/null &
    TLIST=$(ps -e -T | grep "varnish" | awk '{print $2}' | sort -h)
    for T in $TLIST; do echo "$T" | sudo tee /sys/fs/cgroup/cpuset/hu_apache_3/tasks; done >> /dev/null
    ab -s 100 -t 90 -c 1 http://127.0.0.1:8081/index.html > $LOG_DIR/c14/no_parties.log &
    TLIST=$(ps -e -T | grep "varnish" | awk '{print $2}' | sort -h)
    for T in $TLIST; do echo "$T" | sudo tee /sys/fs/cgroup/cpuset/hu_apache_1/tasks; done >> /dev/null
    sleep 95
}

function parties {
    $PSANDBOX_VARNISH_DIR/../httpd/dist/bin/apachectl -k start
    varnishd -a :8081 -f $PSANDBOX_VARNISH_DIR/../script/default.vcl -s malloc,256m -p thread_pools=1 -p thread_pool_min=1 -p thread_pool_max=3 -p thread_pool_timeout=10
    sleep 20
    ab -s 100 -t 110 -c 1 http://127.0.0.1:8081/10M.html >> /dev/null &
    TLIST=$(ps -e -T | grep "httpd" | awk '{print $2}' | sort -h)
    for T in $TLIST; do echo "$T" | sudo tee /sys/fs/cgroup/cpuset/hu_apache_2/tasks; done >> /dev/null
    ab -s 100 -t 110 -c 1 http://127.0.0.1:8081/10M.html >> /dev/null &
    TLIST=$(ps -e -T | grep "httpd" | awk '{print $2}' | sort -h)
    for T in $TLIST; do echo "$T" | sudo tee /sys/fs/cgroup/cpuset/hu_apache_3/tasks; done >> /dev/null
    ab -s 100 -t 90 -n 100000000 -c 1 http://127.0.0.1:8081/index.html > $LOG_DIR/c14/parties.log &
    TLIST=$(ps -e -T | grep "httpd" | awk '{print $2}' | sort -h)
    for T in $TLIST; do echo "$T" | sudo tee /sys/fs/cgroup/cpuset/hu_apache_1/tasks; done >> /dev/null
    core=$(nproc --all)
    sudo ../../comparsion/parties_for_native.py $LOG_DIR/c14/ $core &
    sleep 95
    sudo pkill -f parties_for_native.py
}

function cleanup {
    echo "exiting"
    pkill varnishd
    pkill httpd
}

trap cleanup EXIT

####################
# preparing server #
####################

if [[ $1 == 1 ]]; then
    echo "run c14"
    cp ../../libpsandbox.so $PSANDBOXDIR/build/libs/libpsandbox.so
elif [[ $1 == 2 ]]; then
    echo "run c14 cgroup"
    sudo cgdelete -g cpu:/apache
    sudo cgcreate -g cpu:/apache
    sudo cgset -r cpu.shares=2048 apache
    cp ../../libpsandbox.so $PSANDBOXDIR/build/libs/libpsandbox.so
elif [[ $1 == 3 ]]; then
    echo "run c14 psandbox"
    cp ../../libpsandbox_psandbox.so $PSANDBOXDIR/build/libs/libpsandbox.so
elif [[ $1 == 6 ]]; then
    echo "run c14 parties"
    sudo cgdelete -g cpuset:/hu_apache_1
    sudo cgcreate -g cpuset:/hu_apache_1
    core=$(nproc --all)
    core=$(( core - 1))
    echo "0" | sudo tee /sys/fs/cgroup/cpuset/hu_apache_1/cpuset.mems
    echo "0-$core" | sudo tee /sys/fs/cgroup/cpuset/hu_apache_1/cpuset.cpus
    sudo cgdelete -g cpuset:/hu_apache_2
    sudo cgcreate -g cpuset:/hu_apache_2
    echo "0" | sudo tee /sys/fs/cgroup/cpuset/hu_apache_2/cpuset.mems
    echo "0-$core" | sudo tee /sys/fs/cgroup/cpuset/hu_apache_2/cpuset.cpus
    sudo cgdelete -g cpuset:/hu_apache_3
    sudo cgcreate -g cpuset:/hu_apache_3
    echo "0" | sudo tee /sys/fs/cgroup/cpuset/hu_apache_3/cpuset.mems
    echo "0-$core" | sudo tee /sys/fs/cgroup/cpuset/hu_apache_3/cpuset.cpus
    cp ../../libpsandbox.so $PSANDBOXDIR/build/libs/libpsandbox.so
elif [[ $1 == 7 ]]; then
    echo "run c14 parties baseline"
    cp ../../libpsandbox.so $PSANDBOXDIR/build/libs/libpsandbox.so
elif [[ $1 == 8 ]]; then
  echo "run c14 retro"
  cp ../../libretro.so $PSANDBOXDIR/build/libs/libpsandbox.so
elif [[ $1 == 9 ]]; then
  echo "run c14 psp"
  cp ../../libpsandbox.so $PSANDBOXDIR/build/libs/libpsandbox.so
fi

cp httpd.conf $PSANDBOX_VARNISH_DIR/../httpd/dist/conf/
cp php_wrapper $PSANDBOX_VARNISH_DIR/../httpd/dist/php/bin/php-wrapper
cp $PSANDBOX_VARNISH_DIR/../httpd/php-7.4.23/php.ini-development $PSANDBOX_VARNISH_DIR/../httpd/dist/php/php.ini
cp index.html $PSANDBOX_VARNISH_DIR/../httpd/dist/htdocs/
cp 10M.html $PSANDBOX_VARNISH_DIR/../httpd/dist/htdocs/
mkdir -p $LOG_DIR/c14


###################
# running scripts #
###################

if [[ $1 == 1 ]]; then
    $PSANDBOX_VARNISH_DIR/../httpd/dist/bin/apachectl -k start
    varnishd -a :8081 -f $PSANDBOX_VARNISH_DIR/../script/default.vcl -s malloc,256m -p thread_pools=1 -p thread_pool_min=1 -p thread_pool_max=100 -p thread_pool_timeout=10
    sleep 10
    normal
    pkill varnishd
    pkill httpd
    sleep 20
    $PSANDBOX_VARNISH_DIR/../httpd/dist/bin/apachectl -k start
    varnishd -a :8081 -f $PSANDBOX_VARNISH_DIR/../script/default.vcl -s malloc,256m -p thread_pools=1 -p thread_pool_min=1 -p thread_pool_max=3 -p thread_pool_timeout=10
    sleep 10
    interference
elif [[ $1 == 2 ]]; then
    $PSANDBOX_VARNISH_DIR/../httpd/dist/bin/apachectl -k start
    varnishd -a :8081 -f $PSANDBOX_VARNISH_DIR/../script/default.vcl -s malloc,256m -p thread_pools=1 -p thread_pool_min=1 -p thread_pool_max=3 -p thread_pool_timeout=10
    sleep 10
    cgroup
elif [[ $1 == 3 ]]; then
    $PSANDBOX_VARNISH_DIR/../httpd/dist/bin/apachectl -k start
    varnishd -a :8081 -f $PSANDBOX_VARNISH_DIR/../script/default.vcl -s malloc,256m -p thread_pools=1 -p thread_pool_min=1 -p thread_pool_max=3 -p thread_pool_timeout=10
    sleep 10
    psandbox
elif [[ $1 == 6 ]]; then
    mkdir -p $LOG_DIR/c14/apache_1
    mkdir -p $LOG_DIR/c14/apache_2
    mkdir -p $LOG_DIR/c14/apache_3
    $PSANDBOX_VARNISH_DIR/../httpd/dist/bin/apachectl -k start
    varnishd -a :8081 -f $PSANDBOX_VARNISH_DIR/../script/default.vcl -s malloc,256m -p thread_pools=1 -p thread_pool_min=1 -p thread_pool_max=3 -p thread_pool_timeout=10
    sleep 10
    parties
elif [[ $1 == 7 ]]; then
    parties_normal
elif [[ $1 == 8 ]]; then
    $PSANDBOX_VARNISH_DIR/../httpd/dist/bin/apachectl -k start
    varnishd -a :8081 -f $PSANDBOX_VARNISH_DIR/../script/default.vcl -s malloc,256m -p thread_pools=1 -p thread_pool_min=1 -p thread_pool_max=3 -p thread_pool_timeout=10
    sleep 10
    retro
elif [[ $1 == 9 ]]; then
    ${PSP_DIR}/sosp_aec/psandbox_script/varnish_server.sh
fi


sleep 1
