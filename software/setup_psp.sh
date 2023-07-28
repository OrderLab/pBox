#/bin/bash

sudo apt-get update
sudo apt-get install -y libelf-dev python3-pip cmake libreadline-dev scons libevent-dev gengetopt python-docutils libxml2-dev libpcre3-dev libevent-dev re2c libsqlite3-dev

cd ../psandbox-userlib/ && ./setup_pbox_lib.sh
cd -

