#!/bin/bash

echo "\timing on"
for i in {1..30}
do
    echo "begin;"
    echo "select 1 from sbtest1 for share;"
    echo "SELECT pg_sleep(3);"
    echo "commit;"
done

