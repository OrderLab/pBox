#!/bin/bash

ab -s 10 -t 110 -c 1 http://$SERVER_NODE:8081/10M.html

