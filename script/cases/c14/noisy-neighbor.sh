#!/bin/bash

# This script runs on 5 noisy neighbor machines respectively
# It runs for a looong time, so after the victim finishes we can stop it
ab -s 10 -t 110 -c 1 http://128.110.218.63:8081/500MB.html\?name\=a
