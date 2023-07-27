#!/bin/bash

mysql -S $PSANDBOX_MYSQL_DIR/mysqld.sock << EOF
use test
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
EOF
