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

overhead_logs = [
    'normal_1.log',
    'psandbox_normal_1.log',
    'normal_16.log',
    'psandbox_normal_16.log',
     'normal_32.log',
    'psandbox_normal_32.log',
     'normal_64.log',
    'psandbox_normal_64.log',
]

read_regex = re.compile(
   'normal_[0-9]*.log'
)


mean_regex = re.compile(
    'Time per request:       [0-9]*\.[0-9]+ \[ms] ' +
    '\(mean, across all concurrent requests\)'
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

psandbox_regex = re.compile(
   'psandbox_'
)


# Overhead
def get_result(args):
    means = []
    fields = {'Setting':["s1","s2","s3","s4"],
               'app':["Apache","Apache","Apache","Apache"],
               'w/o psandbox(average)':[0.0,0.0,0.0,0.0], 
               'w/o psandbox(99 per)':[0.0,0.0,0.0,0.0],
               'psandbox(average)':[0.0,0.0,0.0,0.0],
               'psandbox(99 per)':[0.0,0.0,0.0,0.0,]}
    df = pd.DataFrame(fields)
    for log in overhead_logs:
        file = args.input + "/" + log
        mean_latencies = []
        ninety_nine_latencies = []
        with open(file) as f:
            for line in f:
                result = mean_regex.search(line)
                if result:
                    n = float(float_regex.search(line).group())
                    mean_latencies.append(n)
                result = ninety_nine_regex.search(line)
                if result:
                    n = float(result.string.split()[1])
                    ninety_nine_latencies.append(n)
        result = read_regex.search(file)
        if result:
            n = int(result.group().split(".")[0].split("_")[1])
            if n == 1:
                index = df.loc[df['Setting'] == "s1"].index.values.astype(int)[0]
            elif n == 16:
                index = df.loc[df['Setting'] == "s2"].index.values.astype(int)[0]
            elif n == 32:
                index = df.loc[df['Setting'] == "s3"].index.values.astype(int)[0]
            elif n == 64:
                index = df.loc[df['Setting'] == "s4"].index.values.astype(int)[0]

        if psandbox_regex.search(file):
            df.at[index,"psandbox(average)"]= statistics.mean(mean_latencies)
            df.at[index,"psandbox(99 per)"]= statistics.mean(ninety_nine_latencies)
        else:
            df.at[index,"w/o psandbox(average)"]= statistics.mean(mean_latencies)
            df.at[index,"w/o psandbox(99 per)"]= statistics.mean(mean_latencies)
      
    df.to_csv(args.output, sep=',')


if __name__ == "__main__":
    # execute only if run as a script
    args = parser.parse_args()
    if not args.input :
        sys.stderr.write('Must specify input data file\n')
        sys.exit(1)
    get_result(args)