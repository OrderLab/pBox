#!/usr/bin/python3
import re
import argparse
import csv
import os
import pandas as pd

parser = argparse.ArgumentParser()
parser.add_argument('-i','--input', help="path to input file")
parser.add_argument('-o', '--output', default="./output.csv", help="path to output file")

cases = ['c16']
logs  = [
    'cgroup.log', 
    'no_interference.log', 
    'no_psandbox.log', 
    'psandbox.log'
]

read_regex = re.compile(
    'read +[0-9]*\.[0-9]+'
)
write_regex = re.compile(
    'update +[0-9]*\.[0-9]+'
)


def get_result(args):
    for case in cases:
        for log in logs:
            file = args.input + "/" + case + "/" + log
            mean_latencies = []
            ninety_nine_latencies = []
            write_avg = 0
            tail_write = 0
            read_avg = 0
            tail_read = 0
            with open(file) as f:
                for line in f:
                    result = read_regex.search(line)
                    if result:
                        read_avg = float(result.group().split()[1])
                        tail_read = float(line.split()[-1])
                    result = write_regex.search(line)
                    if result:
                        write_avg = float(result.group().split()[1])
                        tail_write = float(line.split()[-1])
                print('[+] ' + file)
                print('avg mean ' + str(write_avg*0.1 + read_avg * 0.9))
                print('avg 99% tail ' + str(tail_write*0.1 + tail_read * 0.9))

if __name__ == "__main__":
    # execute only if run as a script
    args = parser.parse_args()
    if not args.input :
        sys.stderr.write('Must specify input data file\n')
        sys.exit(1)
    get_result(args)