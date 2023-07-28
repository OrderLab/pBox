#!/bin/bash

# This script runs on the client side
ab -s 10 -t 90 -n 100000000 -c 1 http://$SERVER_NODE:8080/index.html
