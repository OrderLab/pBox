#!/bin/bash

# This script runs on the client side
ab -s 10 -t 90 -n 100000000 -c 1 http://127.0.0.1:8080/index.html
