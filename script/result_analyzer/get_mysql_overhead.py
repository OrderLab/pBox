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

read_regex = re.compile(
   'read_[0-9]*.log'
)

write_regex = re.compile(
   'write_[0-9]*.log'
)

psandbox_regex = re.compile(
   'psandbox_'
)

mean_regex = re.compile(
    'avg: +[0-9]*\.[0-9]+'
)

ninety_nine_regex = re.compile(
    '99th percentile: +[0-9]*\.[0-9]+'
)

thread_regex = re.compile(
    'thds: [0-9]* '
)

qps_regex = re.compile(
    'qps: [0-9]*\.[0-9]* '
)

def get_normal_tps(path,file):
   
    for line in i_file.readlines():
        curLine=line.strip().split(" ")
        
    return latency

def get_result(args):
    means = []
    fields = {'Setting':["s1","s2","s3","s4","s5","s6","s7","s8"],
               'app':["MySQL","MySQL","MySQL","MySQL","MySQL","MySQL","MySQL","MySQL"],
               'w/o psandbox(average)':[0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0], 
               'w/o psandbox(99 per)':[0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0],
               'psandbox(average)':[0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0],
               'psandbox(99 per)':[0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0]}
    df = pd.DataFrame(fields)
    for file in os.listdir(args.input):
        i_file = open(args.input + "/"+ file, 'r')
        mean_latencies = 0
        ninety_nine_latencies = 0
        throughputs = []
        threads = 1
        step = 10
        request = 0
        for line in i_file.readlines():
            result = thread_regex.search(line)
            if result:   
                threads = int(result.group().split()[1])
                throughputs.append(float(qps_regex.search(line).group().split()[1])/threads)

            mean = mean_regex.search(line)
            if mean:
                mean_latencies = float(mean.group().split()[1])
            ninety_nine = ninety_nine_regex.search(line)
            if ninety_nine:
                ninety_nine_latencies = float(ninety_nine.group().split()[2])



        result = read_regex.search(file)
        if result:
            n = int(result.group().split(".")[0].split("_")[1])
            if n == 1:
                index = df.loc[df['Setting'] == "s1"].index.values.astype(int)[0]
            elif n == 16:
                for throughput in throughputs:
                    request = request + throughput*step

                if request != 0:
                    mean_latencies = (len(throughputs)*step)*1000/request
                index = df.loc[df['Setting'] == "s2"].index.values.astype(int)[0]
            elif n == 32:
                for throughput in throughputs:
                    request = request + throughput*step

                if request != 0:
                    mean_latencies = (len(throughputs)*step)*1000/request
                index = df.loc[df['Setting'] == "s3"].index.values.astype(int)[0]
            elif n == 64:
                for throughput in throughputs:
                    request = request + throughput*step

                if request != 0:
                    mean_latencies = (len(throughputs)*step)*1000/request
                index = df.loc[df['Setting'] == "s4"].index.values.astype(int)[0]
        result = write_regex.search(file)
        if result:
            n = int(result.group().split(".")[0].split("_")[1])
            if n == 1:
                index = df.loc[df['Setting'] == "s5"].index.values.astype(int)[0]
            elif n == 16:
                for throughput in throughputs:
                    request = request + throughput*step

                if request != 0:
                    mean_latencies = (len(throughputs)*step)*1000/request
                index = df.loc[df['Setting'] == "s6"].index.values.astype(int)[0]
            elif n == 32:
                for throughput in throughputs:
                    request = request + throughput*step

                if request != 0:
                    mean_latencies = (len(throughputs)*step)*1000/request
                index = df.loc[df['Setting'] == "s7"].index.values.astype(int)[0]
            elif n == 64:
                for throughput in throughputs:
                    request = request + throughput*step

                if request != 0:
                    mean_latencies = (len(throughputs)*step)*1000/request
                index = df.loc[df['Setting'] == "s8"].index.values.astype(int)[0]

        if psandbox_regex.search(file):
            df.at[index,"psandbox(average)"]= mean_latencies
            df.at[index,"psandbox(99 per)"]= ninety_nine_latencies
        else:
            df.at[index,"w/o psandbox(average)"]= mean_latencies
            df.at[index,"w/o psandbox(99 per)"]= ninety_nine_latencies
    df.to_csv(args.output, sep=',')
           
if __name__ == "__main__":
    # execute only if run as a script
    args = parser.parse_args()
    if not args.input :
        sys.stderr.write('Must specify input data file\n')
        sys.exit(1)
    get_result(args)