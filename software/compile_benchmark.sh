#!/bin/bash


for f in sysbench sysbench-post; do
	cd $f
	./compile.sh
	cd ..
done
