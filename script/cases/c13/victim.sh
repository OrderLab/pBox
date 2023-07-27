#!/bin/sh

# this script runs on the victim client

ab -s 10 -t 90 -n 100000000 -c 1 http://128.110.218.63:8080/index.php
