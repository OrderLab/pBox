#!/bin/bash

LOG_DIR="$(pwd)/result/eval_micro.csv"
OUTPUT_DIR="$(pwd)/result/figures"

./script/microbenchmark/plot_micro.py $LOG_DIR -o $OUTPUT_DIR/fig10.eps 

