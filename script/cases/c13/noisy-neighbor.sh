#!/bin/bash

# this script runs on 5 noisy clients respectively
ab -s 10 -t 110 -c 1 http://$SERVER_NODE:8080/index.php\?arg\=a
