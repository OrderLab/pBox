#!/bin/bash
 
psql postgres<< EOF
begin;
select 1 from sbtest1 for share;
SELECT pg_sleep(3);
commit;
begin;
select 1 from sbtest1 for share;
SELECT pg_sleep(3);
commit;
begin;
select 1 from sbtest1 for share;
SELECT pg_sleep(3);
commit;
begin;
select 1 from sbtest1 for share;
SELECT pg_sleep(3);
commit;
begin;
select 1 from sbtest1 for share;
SELECT pg_sleep(3);
commit;
begin;
select 1 from sbtest1 for share;
SELECT pg_sleep(3);
commit;
begin;
select 1 from sbtest1 for share;
SELECT pg_sleep(3);
commit;
begin;
select 1 from sbtest1 for share;
SELECT pg_sleep(3);
commit;
begin;
select 1 from sbtest1 for share;
SELECT pg_sleep(3);
commit;
begin;
select 1 from sbtest1 for share;
SELECT pg_sleep(3);
commit;
begin;
select 1 from sbtest1 for share;
SELECT pg_sleep(3);
commit;
begin;
select 1 from sbtest1 for share;
SELECT pg_sleep(3);
commit;
begin;
select 1 from sbtest1 for share;
SELECT pg_sleep(3);
commit;
begin;
select 1 from sbtest1 for share;
SELECT pg_sleep(3);
commit;
begin;
select 1 from sbtest1 for share;
SELECT pg_sleep(3);
commit;
begin;
select 1 from sbtest1 for share;
SELECT pg_sleep(3);
commit;
begin;
select 1 from sbtest1 for share;
SELECT pg_sleep(3);
commit;
begin;
select 1 from sbtest1 for share;
SELECT pg_sleep(3);
commit;
begin;
select 1 from sbtest1 for share;
SELECT pg_sleep(3);
commit;
begin;
select 1 from sbtest1 for share;
SELECT pg_sleep(3);
commit;
begin;
select 1 from sbtest1 for share;
SELECT pg_sleep(3);
commit;
begin;
select 1 from sbtest1 for share;
SELECT pg_sleep(3);
commit;
begin;
select 1 from sbtest1 for share;
SELECT pg_sleep(3);
commit;
begin;
select 1 from sbtest1 for share;
SELECT pg_sleep(3);
commit;
begin;
select 1 from sbtest1 for share;
SELECT pg_sleep(3);
commit;
begin;
select 1 from sbtest1 for share;
SELECT pg_sleep(3);
commit;
begin;
select 1 from sbtest1 for share;
SELECT pg_sleep(3);
commit;
begin;
select 1 from sbtest1 for share;
SELECT pg_sleep(3);
commit;
begin;
select 1 from sbtest1 for share;
SELECT pg_sleep(3);
commit;
begin;
select 1 from sbtest1 for share;
SELECT pg_sleep(3);
commit;
begin;
select 1 from sbtest1 for share;
SELECT pg_sleep(3);
commit;
begin;
select 1 from sbtest1 for share;
SELECT pg_sleep(3);
commit;
begin;
select 1 from sbtest1 for share;
SELECT pg_sleep(3);
commit;
begin;
select 1 from sbtest1 for share;
SELECT pg_sleep(3);
commit;
begin;
select 1 from sbtest1 for share;
SELECT pg_sleep(3);
commit;
begin;
select 1 from sbtest1 for share;
SELECT pg_sleep(3);
commit;
begin;
select 1 from sbtest1 for share;
SELECT pg_sleep(3);
commit;
begin;
select 1 from sbtest1 for share;
SELECT pg_sleep(3);
commit;
begin;
select 1 from sbtest1 for share;
SELECT pg_sleep(3);
commit;
begin;
select 1 from sbtest1 for share;
SELECT pg_sleep(3);
commit;
begin;
select 1 from sbtest1 for share;
SELECT pg_sleep(3);
commit;
EOF

