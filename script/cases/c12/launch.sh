#!/bin/bash

LOG_DIR="$(pwd)/../../../result/cases/"
NOISE="$(envsubst < noisy-neighbor.sh)"

function normal {
    cp httpd_normal.conf $PSANDBOX_APACHE_DIR/conf/httpd.conf
    apachectl -k start
    sleep 10
    echo "start normal"

    ssh client1 "$NOISE" > /dev/null 2>&1 &
    ssh client2 "$NOISE" > /dev/null 2>&1 &
    ssh client3 "$NOISE" > /dev/null 2>&1 &
    ./victim.sh > $LOG_DIR/c12/no_interference.log
}

function interference {
    cp httpd.conf $PSANDBOX_APACHE_DIR/conf/httpd.conf
    apachectl -k start
    sleep 10
    echo "start interference"

    ssh client1 "$NOISE" > /dev/null 2>&1 &
    ssh client2 "$NOISE" > /dev/null 2>&1 &
    ssh client3 "$NOISE" > /dev/null 2>&1 &
    ./victim.sh > $LOG_DIR/c12/no_psandbox.log
}

function cgroup {
    cp httpd.conf $PSANDBOX_APACHE_DIR/conf/httpd.conf
    apachectl -k start
    sleep 10
    echo "start cgroup"
    TLIST=$(ps -e -T | grep "httpd" | awk '{print $2}' | sort -h)
    for T in $TLIST; do echo "$T" | sudo tee /sys/fs/cgroup/cpu/apache/tasks; done >> /dev/null

    ssh client1 "$NOISE" > /dev/null 2>&1 &
    ssh client2 "$NOISE" > /dev/null 2>&1 &
    ssh client3 "$NOISE" > /dev/null 2>&1 &
    ./victim.sh > $LOG_DIR/c12/cgroup.log
}

function psandbox {
    cp httpd.conf $PSANDBOX_APACHE_DIR/conf/httpd.conf
    apachectl -k start
    sleep 10
    echo "start psandbox"

    ssh client1 "$NOISE" > /dev/null 2>&1 &
    ssh client2 "$NOISE" > /dev/null 2>&1 &
    ssh client3 "$NOISE" > /dev/null 2>&1 &
    ./victim.sh > $LOG_DIR/c12/psandbox.log
}

function retro {
    cp httpd.conf $PSANDBOX_APACHE_DIR/conf/httpd.conf
    apachectl -k start
    sleep 10
    echo "start retro"

    ssh client1 "$NOISE" > /dev/null 2>&1 &
    ssh client2 "$NOISE" > /dev/null 2>&1 &
    ssh client3 "$NOISE" > /dev/null 2>&1 &
    ./victim.sh > $LOG_DIR/c12/retro.log
}

function parties_normal {
    cp httpd_normal.conf $PSANDBOX_APACHE_DIR/conf/httpd.conf
    apachectl -k start
    sleep 10
    ab -s 10 -t 110 -c 1 http://127.0.0.1:8080/index.html\?name\=a >> /dev/null &
    ab -s 10 -t 110 -c 1 http://127.0.0.1:8080/index.html\?name\=a >> /dev/null &
    ab -s 10 -t 110 -c 1 http://127.0.0.1:8080/index.html\?name\=a >> /dev/null &
    ab -s 10 -t 90 -n 100000000 -c 1 http://127.0.0.1:8080/index.html > $LOG_DIR/c12/no_interference_parties.log
    pkill httpd
    sleep 1
    cp httpd.conf $PSANDBOX_APACHE_DIR/conf/httpd.conf
    apachectl -k start
    sleep 5
    ab -s 10 -t 110 -c 1 http://127.0.0.1:8080/index.html\?name\=a >> /dev/null &
    TLIST=$(ps -e -T | grep "httpd" | awk '{print $2}' | sort -h)
    for T in $TLIST; do echo "$T" | sudo tee /sys/fs/cgroup/cpuset/hu_apache_2/tasks; done >> /dev/null
    ab -s 10 -t 110 -c 1 http://127.0.0.1:8080/index.html\?name\=a >> /dev/null &
    TLIST=$(ps -e -T | grep "httpd" | awk '{print $2}' | sort -h)
    for T in $TLIST; do echo "$T" | sudo tee /sys/fs/cgroup/cpuset/hu_apache_3/tasks; done >> /dev/null
    ab -s 10 -t 110 -c 1 http://127.0.0.1:8080/index.html\?name\=a >> /dev/null &
    TLIST=$(ps -e -T | grep "httpd" | awk '{print $2}' | sort -h)
    for T in $TLIST; do echo "$T" | sudo tee /sys/fs/cgroup/cpuset/hu_apache_4/tasks; done >> /dev/null
    ab -s 10 -t 90 -n 100000000 -c 1 http://127.0.0.1:8080/index.html > $LOG_DIR/c12/no_parties.log &
    TLIST=$(ps -e -T | grep "httpd" | awk '{print $2}' | sort -h)
    for T in $TLIST; do echo "$T" | sudo tee /sys/fs/cgroup/cpuset/hu_apache_1/tasks; done >> /dev/null
}

function parties {
    cp httpd.conf $PSANDBOX_APACHE_DIR/conf/httpd.conf
    apachectl -k start
    sleep 10
    ab -s 10 -t 110 -c 1 http://127.0.0.1:8080/index.html\?name\=a >> /dev/null &
    TLIST=$(ps -e -T | grep "httpd" | awk '{print $2}' | sort -h)
    for T in $TLIST; do echo "$T" | sudo tee /sys/fs/cgroup/cpuset/hu_apache_2/tasks; done >> /dev/null
    ab -s 10 -t 110 -c 1 http://127.0.0.1:8080/index.html\?name\=a >> /dev/null &
    TLIST=$(ps -e -T | grep "httpd" | awk '{print $2}' | sort -h)
    for T in $TLIST; do echo "$T" | sudo tee /sys/fs/cgroup/cpuset/hu_apache_3/tasks; done >> /dev/null
    ab -s 10 -t 110 -c 1 http://127.0.0.1:8080/index.html\?name\=a >> /dev/null &
    TLIST=$(ps -e -T | grep "httpd" | awk '{print $2}' | sort -h)
    for T in $TLIST; do echo "$T" | sudo tee /sys/fs/cgroup/cpuset/hu_apache_4/tasks; done >> /dev/null
    ab -s 10 -t 90 -n 100000000 -c 1 http://127.0.0.1:8080/index.html > $LOG_DIR/c12/parties.log &
    TLIST=$(ps -e -T | grep "httpd" | awk '{print $2}' | sort -h)
    for T in $TLIST; do echo "$T" | sudo tee /sys/fs/cgroup/cpuset/hu_apache_1/tasks; done >> /dev/null
    sudo ../../comparsion/parties_for_native.py $LOG_DIR/c12/ &
    sleep 90
    sudo pkill -f parties_for_native.py
}

function cleanup {
    echo "exiting"
    apachectl -k stop
}

trap cleanup EXIT


####################
# preparing server #
####################

if [[ $1 == 1 ]]; then
    echo "run c12"
    cp ../../libpsandbox.so $PSANDBOXDIR/build/libs/libpsandbox.so
elif [[ $1 == 2 ]]; then
    echo "run c12 cgroup"
    sudo cgdelete -g cpu:/apache
    sudo cgcreate -g cpu:/apache
    sudo cgset -r cpu.shares=2048 apache
    cp ../../libpsandbox.so $PSANDBOXDIR/build/libs/libpsandbox.so
elif [[ $1 == 3 ]]; then
    echo "run c12 psandbox"
    cp ../../libpsandbox_psandbox.so $PSANDBOXDIR/build/libs/libpsandbox.so
elif [[ $1 == 6 ]]; then
    echo "run c12 parties"
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
    echo "run c12 parties baseline"
    cp ../../libpsandbox.so $PSANDBOXDIR/build/libs/libpsandbox.so
elif [[ $1 == 8 ]]; then
  echo "run c12 retro"
  cp ../../libretro.so $PSANDBOXDIR/build/libs/libpsandbox.so
elif [[ $1 == 9 ]]; then
  echo "run c12 psp"
  cp ../../libpsandbox.so $PSANDBOXDIR/build/libs/libpsandbox.so
fi


cp php_wrapper $PSANDBOX_APACHE_DIR/php/bin/php-wrapper
cp $PSANDBOX_APACHE_DIR/../php-7.4.23/php.ini-development $PSANDBOX_APACHE_DIR/php/php.ini
cp index.html $PSANDBOX_APACHE_DIR/htdocs/
mkdir -p $LOG_DIR/c12

###################
# running scripts #
###################

if [[ $1 == 1 ]]; then
    normal
    apachectl -k stop
    sleep 5
    interference
elif [[ $1 == 2 ]]; then
    cgroup
elif [[ $1 == 3 ]]; then
    psandbox
elif [[ $1 == 6 ]]; then
    mkdir -p $LOG_DIR/c12/apache_1
    mkdir -p $LOG_DIR/c12/apache_2
    mkdir -p $LOG_DIR/c12/apache_3
    mkdir -p $LOG_DIR/c12/apache_4
    parties
elif [[ $1 == 7 ]]; then
    parties_normal
elif [[ $1 == 8 ]]; then
    retro
elif [[ $1 == 9 ]]; then
    ${PSP_DIR}/sosp_aec/psandbox_script/apache_server.sh
fi


sleep 15
