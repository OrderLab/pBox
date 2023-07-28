#!/bin/bash

# This script runs on the client side
ab -s 10 -t 90 -n 1000000 -c 1 http://$SERVER_NODE:8081/index.html
