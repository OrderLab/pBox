#!/bin/bash

# This script runs on the client side
ab -s 10 -t 10 -n 1000000 -c 1 http://128.110.218.63:8081/index.html
