#!/bin/bash


for f in mysql postgresql memcached apache varnish; do
	source ~/.bashrc
	cd $f
	./compile.sh
	cd ..
done
