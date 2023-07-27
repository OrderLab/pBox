#!/bin/bash

echo "use test;"
echo "SET profiling = 1;"
for i in {1..20000}
do
   echo "select count(*) from sbtest$1 where id < 100 for update;"
done

echo "SHOW PROFILES;"
echo "select sleep(1);"
