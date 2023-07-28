#!/bin/bash

git clone https://github.com/gongxini/pbox_mysql.git mysql
git clone https://github.com/gongxini/psandbox-sysbench.git sysbench
git clone https://github.com/gongxini/psandbox-sysbench.git sysbench-post
cd sysbench-post
mv compile_post.sh compile.sh
cd ..
git clone https://github.com/OrderLab/perfIsolation-PostgreSQL.git postgresql
git clone https://github.com/OrderLab/perfIsolation-memcached.git memcached
git clone https://github.com/OrderLab/perfIsolation-Apache.git apache
git clone https://github.com/OrderLab/perfIsolation-varnish.git varnish
git clone https://github.com/gongxini/psp-psandbox.git psp_server
