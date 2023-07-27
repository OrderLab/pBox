#!/bin/bash
  
mysql -S $PSANDBOX_MYSQL_DI/mysqld.sock << EOF
use test
SET profiling = 1;
begin;
select c from sbtest1 limit 1;
select sleep(10);
commit;
begin;
select c  from sbtest1 limit 1;
select sleep(20);
commit;
begin;
select c from sbtest1 limit 1;
select sleep(20);
commit;
begin;
select c  from sbtest1 limit 1;
select sleep(20);
commit;
begin;
select c  from sbtest1 limit 1;
select sleep(20);
commit;
begin;
select c  from sbtest1 limit 1;
select sleep(20);
commit;
begin;
select c  from sbtest1 limit 1;
select sleep(20);
commit;
SHOW PROFILES;
select sleep(1);
EOF
