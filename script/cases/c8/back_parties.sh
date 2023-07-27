#!/bin/bash

for i in {1..50}
do
   now=$(date +"%s%N")
   psql postgres -c "begin;select 1 from sbtest1 for share;SELECT pg_sleep(3);commit;" >> /dev/null
   now1=$(date +"%s%N")
   echo "Time: $(( now1 - now))"
done
