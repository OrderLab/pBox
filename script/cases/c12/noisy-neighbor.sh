#!/bin/bash

ab -s 10 -t 110 -c 1 http://$SERVER_NODE:8080/index.html\?name\=a
