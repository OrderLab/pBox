#!/bin/bash

for i in {1..15}
do
   now=$(date +"%s%N")
   psql postgres -c "BEGIN;INSERT INTO plan SELECT id + 200001,typ,current_date + id * '1 seconds'::interval ,val FROM plan;SELECT pg_sleep(10);delete from plan;COPY plan FROM './plan1.dat' (DELIMITER ',', NULL '');commit;analyze;" >> /dev/null
   now1=$(date +"%s%N")
   echo "Time: $(( now1 - now))"
done

