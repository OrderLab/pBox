#!/bin/bash

LOG_DIR="$(pwd)/../../../result/cases/"
NOISE="$(envsubst < noisy-neighbor.sh)"

function normal {
    cp php-fpm_normal.conf $PSANDBOX_APACHE_DIR/php/etc/php-fpm.conf
    $PSANDBOX_APACHE_DIR/php/sbin/php-fpm --fpm-config $PSANDBOX_APACHE_DIR/php/etc/php-fpm.conf
    apachectl -k start
    sleep 10

    echo "start normal"
    ssh client1 "$NOISE" > /dev/null 2>&1 &
    ssh client2 "$NOISE" > /dev/null 2>&1 &
    ssh client3 "$NOISE" > /dev/null 2>&1 &
    ./victim.sh > $LOG_DIR/c13/no_interference.log
}

function interference {
    cp php-fpm.conf $PSANDBOX_APACHE_DIR/php/etc/php-fpm.conf
    $PSANDBOX_APACHE_DIR/php/sbin/php-fpm --fpm-config $PSANDBOX_APACHE_DIR/php/etc/php-fpm.conf
    apachectl -k start
    sleep 10

    echo "start interference"
    ssh client1 "$NOISE" > /dev/null 2>&1 &
    ssh client2 "$NOISE" > /dev/null 2>&1 &
    ssh client3 "$NOISE" > /dev/null 2>&1 &
    ./victim.sh > $LOG_DIR/c13/no_psandbox.log
}

function cgroup {
    cp php-fpm.conf $PSANDBOX_APACHE_DIR/php/etc/php-fpm.conf
    $PSANDBOX_APACHE_DIR/php/sbin/php-fpm --fpm-config $PSANDBOX_APACHE_DIR/php/etc/php-fpm.conf
    apachectl -k start
    sleep 10

    echo "start cgroup"
    TLIST=$(ps -e -T | grep "httpd" | awk '{print $2}' | sort -h)
    for T in $TLIST; do echo "$T" | sudo tee /sys/fs/cgroup/cpu/apache/tasks; done >> /dev/null
    ssh client1 "$NOISE" > /dev/null 2>&1 &
    ssh client2 "$NOISE" > /dev/null 2>&1 &
    ssh client3 "$NOISE" > /dev/null 2>&1 &
    ./victim.sh > $LOG_DIR/c13/cgroup.log
}

function psandbox {
    cp php-fpm.conf $PSANDBOX_APACHE_DIR/php/etc/php-fpm.conf
    $PSANDBOX_APACHE_DIR/php/sbin/php-fpm --fpm-config $PSANDBOX_APACHE_DIR/php/etc/php-fpm.conf
    apachectl -k start
    sleep 10
    ./victim.sh > /dev/null 2>&1
    echo "start psandbox"
    ssh client1 "$NOISE" > /dev/null 2>&1 &
    ssh client2 "$NOISE" > /dev/null 2>&1 &
    ssh client3 "$NOISE" > /dev/null 2>&1 &
    ./victim.sh > $LOG_DIR/c13/psandbox.log
}

function retro {
    cp php-fpm.conf $PSANDBOX_APACHE_DIR/php/etc/php-fpm.conf
    $PSANDBOX_APACHE_DIR/php/sbin/php-fpm --fpm-config $PSANDBOX_APACHE_DIR/php/etc/php-fpm.conf
    apachectl -k start
    sleep 10
    ./victim.sh > /dev/null 2>&1
    echo "start retro"
    ssh client1 "$NOISE" > /dev/null 2>&1 &
    ssh client2 "$NOISE" > /dev/null 2>&1 &
    ssh client3 "$NOISE" > /dev/null 2>&1 &
    ./victim.sh > $LOG_DIR/c13/retro.log
}

function parties_normal {
    cp php-fpm_normal.conf $PSANDBOX_APACHE_DIR/php/etc/php-fpm.conf
    $PSANDBOX_APACHE_DIR/php/sbin/php-fpm --fpm-config $PSANDBOX_APACHE_DIR/php/etc/php-fpm.conf
    apachectl -k start
    sleep 5
    ab -s 10 -t 110 -c 1 http://127.0.0.1:8080/index.php\?arg\=a >> /dev/null &
    ab -s 10 -t 110 -c 1 http://127.0.0.1:8080/index.php\?arg\=a >> /dev/null &
    ab -s 10 -t 110 -c 1 http://127.0.0.1:8080/index.php\?arg\=a >> /dev/null &
    ab -s 10 -t 90 -n 100000000 -c 1 http://127.0.0.1:8080/index.php > $LOG_DIR/c13/no_interference_parties.log
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
    ab -s 10 -t 90 -n 100000000 -c 1 http://127.0.0.1:8080/index.php > $LOG_DIR/c13/no_parties.log &
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
    ab -s 10 -t 90 -n 100000000 -c 1 http://127.0.0.1:8080/index.php > $LOG_DIR/c13/parties.log &
    TLIST=$(ps -e -T | grep "httpd" | awk '{print $2}' | sort -h)
    for T in $TLIST; do echo "$T" | sudo tee /sys/fs/cgroup/cpuset/hu_apache_1/tasks; done >> /dev/null
    sudo ../../comparsion/parties_for_native.py $LOG_DIR/c13/ &
    sleep 95
    sudo pkill -f parties_for_native.py
}

function cleanup {
    echo "exiting"
    apachectl -k stop
    pkill php-fpm
}

trap cleanup EXIT


####################
# preparing server #
####################

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
elif [[ $1 == 8 ]]; then
  echo "run c13 retro"
  cp ../../libretro.so $PSANDBOXDIR/build/libs/libpsandbox.so
elif [[ $1 == 9 ]]; then
  echo "run c13 psp"
  cp ../../libpsandbox.so $PSANDBOXDIR/build/libs/libpsandbox.so
fi

pkill php-fpm
cp httpd.conf $PSANDBOX_APACHE_DIR/conf/
cp index.php $PSANDBOX_APACHE_DIR/htdocs/
cp index.html $PSANDBOX_APACHE_DIR/htdocs/
mkdir -p $LOG_DIR/c13


###################
# running scripts #
###################

if [[ $1 == 1 ]]; then
    normal
    pkill httpd
    pkill php-fpm
    sleep 5
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
elif [[ $1 == 8 ]]; then
    retro
elif [[ $1 == 9 ]]; then
    ${PSP_DIR}/sosp_aec/psandbox_script/apache_server.sh
fi

sleep 5
