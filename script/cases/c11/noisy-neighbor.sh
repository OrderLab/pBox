#!/bin/bash

# This script runs on 5 noisy neighbor machines respectively
# It runs for a looong time, so after the victim finishes we can stop it
for i in `seq 1 30`
do
  ab -s 200 -n 10 -c 10 http://$SERVER_NODE:8080/index.html\?name\=a
done

