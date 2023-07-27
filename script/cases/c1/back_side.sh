#!/bin/bash
  
mysql -S $PSANDBOX_MYSQL_DI/mysqld.sock << EOF
use test
SET profiling = 1;
select count(*) from sbtest1 for update;
select count(*) from sbtest1 for update;
select count(*) from sbtest1 for update;
select count(*) from sbtest1 for update;
select count(*) from sbtest1 for update;
select count(*) from sbtest1 for update;
select count(*) from sbtest1 for update;
select count(*) from sbtest1 for update;
select count(*) from sbtest1 for update;
select count(*) from sbtest1 for update;
select count(*) from sbtest1 for update;
select count(*) from sbtest1 for update;
select count(*) from sbtest1 for update;
select count(*) from sbtest1 for update;
select count(*) from sbtest1 for update;
select count(*) from sbtest1 for update;
select count(*) from sbtest1 for update;
select count(*) from sbtest1 for update;
select count(*) from sbtest1 for update;
select count(*) from sbtest1 for update;
SHOW PROFILES;
select sleep(1);
EOF

