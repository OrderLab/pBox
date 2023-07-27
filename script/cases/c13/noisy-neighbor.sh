#!/bin/sh

# this script runs on 5 noisy clients respectively
ab -s 10 -t 110 -c 1 http://128.110.218.63:8080/index.php\?arg\=a
