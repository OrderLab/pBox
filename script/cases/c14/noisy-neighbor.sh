#!/bin/bash

ab -s 10 -t 110 -c 1 http://$SERVER_NODE:8081/500M.html

# while true; do
    # wget -O/dev/null http://$SERVER_NODE:8081/500M.html
# done
