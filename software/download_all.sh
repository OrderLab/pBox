#!/bin/bash

git clone git@github.com:gongxini/pbox_mysql.git mysql
git clone git@github.com:gongxini/psandbox-sysbench.git sysbench
git clone git@github.com:gongxini/psandbox-sysbench.git sysbench-post
cd sysbench-post
mv compile_post.sh compile.sh
cd ..
git clone git@github.com:OrderLab/perfIsolation-PostgreSQL.git postgresql
git clone git@github.com:OrderLab/perfIsolation-memcached.git memcached
git clone git@github.com:OrderLab/perfIsolation-Apache.git apache
git clone git@github.com:OrderLab/perfIsolation-varnish.git varnish
