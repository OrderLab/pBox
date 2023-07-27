#!/bin/bash

for i in {1..50}
do
   now=$(date +"%s%N")
   psql postgres -c "VACUUM FULL sbtest1;" >> /dev/null
   now1=$(date +"%s%N")
   echo "Time: $(( now1 - now))"
done
