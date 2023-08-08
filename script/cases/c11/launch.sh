#!/bin/bash

LOG_DIR="$(pwd)/../../../result/cases/"
NOISE="$(envsubst < noisy-neighbor.sh)"

function normal {
    ab -s 10 -t 90 -n 100000000 -c 10 http://127.0.0.1:8080/index.html > $LOG_DIR/c11/no_interference.log
}

function interference {
    ssh client1 "$NOISE" > /dev/null 2>&1 &
    ssh client2 "$NOISE" > /dev/null 2>&1 &
    ab -s 10 -t 10 -n 100000000 -c 10 http://127.0.0.1:8080/ > $LOG_DIR/c11/no_psandbox.log
}

function cgroup {
    TLIST=$(ps -e -T | grep "httpd" | awk '{print $2}' | sort -h)
    for T in $TLIST; do echo "$T" | sudo tee /sys/fs/cgroup/cpu/apache/tasks; done >> /dev/null
    ssh client1 "$NOISE" > /dev/null 2>&1 &
    ssh client2 "$NOISE" > /dev/null 2>&1 &
    ab -s 10 -t 90 -n 100000000 -c 10 http://127.0.0.1:8080/index.html > $LOG_DIR/c11/cgroup.log
}

function psandbox {
    ssh client1 "$NOISE" > /dev/null 2>&1 &
    ssh client2 "$NOISE" > /dev/null 2>&1 &
    ab -s 10 -t 90 -n 100000000 -c 10 http://127.0.0.1:8080/index.html > $LOG_DIR/c11/psandbox.log
}

function retro {
    ssh client1 "$NOISE" > /dev/null 2>&1 &
    ssh client2 "$NOISE" > /dev/null 2>&1 &
    ab -s 10 -t 90 -n 100000000 -c 10 http://127.0.0.1:8080/index.html > $LOG_DIR/c11/retro.log
}

function parties_normal {
    ab -s 10 -t 90 -n 100000000 -c 10 http://127.0.0.1:8080/index.html > $LOG_DIR/c11/no_interference_parties.log
    sleep 5
    ab -s 10 -t 100 -n 100000000 -c 10 http://127.0.0.1:8080/index.html\?name\=a >> /dev/null  &
    ab -s 10 -t 100 -n 100000000 -c 10 http://127.0.0.1:8080/index.html\?name\=a  >> /dev/null  &
    sleep 1
    ab -s 10 -t 90 -n 100000000 -c 10 http://127.0.0.1:8080/index.html > $LOG_DIR/c11/no_parties.log
}

function parties {
    cd $LOG_DIR/c11/apache_2/ && ab -s 10 -t 100 -n 100000000 -c 10 -o http://127.0.0.1:8080/index.html\?name\=a >> /dev/null &
    sleep 1
    TLIST=$(ps -e -T | grep "httpd" | awk '{print $2}' | sort -h)
    for T in $TLIST; do echo "$T" | sudo tee /sys/fs/cgroup/cpuset/hu_apache_2/tasks; done >> /dev/null
    cd $LOG_DIR/c11/apache_3/ && ab -s 10 -t 100 -n 100000000 -c 10 -o http://127.0.0.1:8080/index.html\?name\=a >> /dev/null &
    sleep 1
    TLIST=$(ps -e -T | grep "httpd" | awk '{print $2}' | sort -h)
    for T in $TLIST; do echo "$T" | sudo tee /sys/fs/cgroup/cpuset/hu_apache_3/tasks; done >> /dev/null
    cd $LOG_DIR/c11/apache_1/ && ab -s 10 -t 90 -n 100000000 -c 10 -o http://127.0.0.1:8080/index.html > $LOG_DIR/c11/parties.log &
    sleep 1
    TLIST=$(ps -e -T | grep "httpd" | awk '{print $2}' | sort -h)
    for T in $TLIST; do echo "$T" | sudo tee /sys/fs/cgroup/cpuset/hu_apache_1/tasks; done >> /dev/null
    core=$(nproc --all)
    sudo ../../comparsion/parties_for_native.py $LOG_DIR/c11/ $core &
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
    echo "run c11"
    cp ../../libpsandbox.so $PSANDBOXDIR/build/libs/libpsandbox.so
elif [[ $1 == 2 ]]; then
    echo "run c11 cgroup"
    sudo cgdelete -g cpu:/apache
    sudo cgcreate -g cpu:/apache
    sudo cgset -r cpu.shares=2048 apache
    cp ../../libpsandbox.so $PSANDBOXDIR/build/libs/libpsandbox.so
elif [[ $1 == 3 ]]; then
    echo "run c11 psandbox"
    cp ../../libpsandbox_psandbox.so $PSANDBOXDIR/build/libs/libpsandbox.so
elif [[ $1 == 6 ]]; then
    echo "run c11 parties"
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
    echo "run c11 parties baseline"
    cp ../../libpsandbox.so $PSANDBOXDIR/build/libs/libpsandbox.so
elif [[ $1 == 8 ]]; then
  echo "run c11 retro"
  cp ../../libretro.so $PSANDBOXDIR/build/libs/libpsandbox.so
elif [[ $1 == 9 ]]; then
  echo "run c11 psp"
  cp ../../libpsandbox.so $PSANDBOXDIR/build/libs/libpsandbox.so
fi

if [[ $1 != 9 ]]; then
cp httpd.conf $PSANDBOX_APACHE_DIR/conf/
cp php_wrapper $PSANDBOX_APACHE_DIR/php/bin/php-wrapper
cp $PSANDBOX_APACHE_DIR/../php-7.4.23/php.ini-development $PSANDBOX_APACHE_DIR/php/php.ini
cp index.html $PSANDBOX_APACHE_DIR/htdocs/
mkdir -p $LOG_DIR/c11
apachectl -k start

sleep 1
fi
if [[ $0 == 2 ]]; then
    TLIST=$(ps -e -T | grep "httpd" | awk '{print $2}' | sort -h)
    for T in $TLIST; do echo "$T" | sudo tee /sys/fs/cgroup/cpu/apache/tasks; done >> /dev/null
fi

###################
# running scripts #
###################

if [[ $1 == 1 ]]; then
    echo "start normal"
    normal
    sleep 5
    echo "start interference"
    interference
elif [[ $1 == 2 ]]; then
    echo "start cgroup"
    cgroup
elif [[ $1 == 3 ]]; then
    echo "start psandbox"
    psandbox
elif [[ $1 == 6 ]]; then
    mkdir -p $LOG_DIR/c11/apache_1
    mkdir -p $LOG_DIR/c11/apache_2
    mkdir -p $LOG_DIR/c11/apache_3
    cp index_parties.html $PSANDBOX_APACHE_DIR/htdocs/index.html
    parties
elif [[ $1 == 7 ]]; then
    cp index_parties.html $PSANDBOX_APACHE_DIR/htdocs/index.html
    parties_normal
elif [[ $1 == 8 ]]; then
    retro
elif [[ $1 == 9 ]]; then
    ${PSP_DIR}/sosp_aec/psandbox_script/apache_server.sh
fi
