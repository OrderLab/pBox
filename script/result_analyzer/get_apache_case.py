#!/usr/bin/python3
import re
import statistics
import argparse
import csv
import os
import pandas as pd

parser = argparse.ArgumentParser()
parser.add_argument('-i','--input', help="path to input file")
parser.add_argument('-o', '--output', default="./output.csv", help="path to output file")
parser.add_argument('-t', '--type', default = 1 , type=int,help="the type of experiment" )
cases = ['c11','c12','c13','c14','c15']
logs  = [
    'cgroup.log', 
    'no_interference.log', 
    'no_psandbox.log', 
    'psandbox.log'
]

parties_logs = [
    'no_interference.log',
    'no_parties.log',
    'parties.log'
]

mean_regex = re.compile(
    'Time per request:       [0-9]*\.[0-9]+ \[ms] ' +
    '\(mean\)'
)
median_regex = re.compile(
    '\s+50% +[0-9]+'
)
ninety_nine_regex = re.compile(
    '\s+99% +[0-9]+'
)
float_regex = re.compile(
    '[0-9]*\.[0-9]+'
)

# c11 - 14
def analyze_average(args):
    for case in cases:
        for log in logs:
            file = args.input + "/" + case + "/" + log
            mean_latencies = []
            median_latencies = []
            ninety_nine_latencies = []
            with open(file) as f:
                for line in f:
                    result = mean_regex.search(line)
                    if result:
                        n = float(float_regex.search(line).group())
                        mean_latencies.append(n)
                    result = median_regex.search(line)
                    if result:
                        n = float(result.string.split()[1])
                        median_latencies.append(n)
                    result = ninety_nine_regex.search(line)
                    if result:
                        n = float(result.string.split()[1])
                        ninety_nine_latencies.append(n)
            print('[+] ' + file)
            print(f'avg mean {statistics.mean(mean_latencies)}')
            print(f'avg median {statistics.mean(median_latencies)}')
            print(f'avg 99% tail {statistics.mean(ninety_nine_latencies)}')

def analyze_parties(args):
    fields = ['Name', 'w/o interference(ms)', 'with interference(ms)', 'parites(ms)'] 
    with open(args.output, 'w') as csvfile: 
        csvwriter = csv.writer(csvfile) 
        csvwriter.writerow(fields) 
        for case in cases:
            row = [case]
            for log in parties_logs:
                file = args.input + "/" + case + "/" + log
                mean_latencies = []
                median_latencies = []
                ninety_nine_latencies = []
                with open(file) as f:
                    for line in f:
                        result = mean_regex.search(line)
                        if result:
                            n = float(float_regex.search(line).group())
                            mean_latencies.append(n)
                        result = median_regex.search(line)
                        if result:
                            n = float(result.string.split()[1])
                            median_latencies.append(n)
                        result = ninety_nine_regex.search(line)
                        if result:
                            n = float(result.string.split()[1])
                            ninety_nine_latencies.append(n)
                row.append(statistics.mean(mean_latencies))
                print('[+] ' + file)
                print(f'avg mean {statistics.mean(mean_latencies)}')
                print(f'avg median {statistics.mean(median_latencies)}')
                print(f'avg 99% tail {statistics.mean(ninety_nine_latencies)}')
            csvwriter.writerow(row)

if __name__ == "__main__":
    # execute only if run as a script
    args = parser.parse_args()
    if not args.input :
        sys.stderr.write('Must specify input data file\n')
        sys.exit(1)
    if args.type == 1:
        analyze_average(args)
    elif args.type == 2:
        analyze_parties(args)