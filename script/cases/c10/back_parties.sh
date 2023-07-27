#!/bin/bash

for i in {1..20}
do
   now=$(date +"%s%N")
   num=$((i*500000))
   num=$((num+1500001))
   psql postgres -c "BEGIN;INSERT INTO plan SELECT id + $num,typ,current_date + id * '1 seconds'::interval ,val FROM plan where id < 500000;commit;" >> /dev/null
   now1=$(date +"%s%N")
   echo "Time: $(( now1 - now))"
done
