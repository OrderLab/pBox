#!/bin/bash

echo "use test;"
for i in {1..20000}
do
   echo "select count(*) from sbtest$1 where id < 100 for update;"
done
