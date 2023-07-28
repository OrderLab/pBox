#!/usr/bin/python3
import re
import argparse
import csv
import os
import pandas as pd

parser = argparse.ArgumentParser()
parser.add_argument('-i','--input', help="path to input file")
parser.add_argument('-o', '--output', default="./output.csv", help="path to output file")

overhead_logs = [
    'read_1.log',
    'read_16.log',
    'read_32.log',
    'read_64.log',
    'write_1.log',
    'write_16.log',
    'write_32.log',
    'write_64.log',
    'psandbox_read_1.log',
    'psandbox_read_16.log',
    'psandbox_read_32.log',
    'psandbox_read_64.log',
    'psandbox_write_1.log',
    'psandbox_write_16.log',
    'psandbox_write_32.log',
    'psandbox_write_64.log',
]

read_regex = re.compile(
    'read +[0-9]*\.[0-9]+'
)
write_regex = re.compile(
    'update +[0-9]*\.[0-9]+'
)


def get_result(args):
    means = []
    fields = {'setting':["s1","s2","s3","s4","s5","s6","s7","s8"],
               'app':["Memcached","Memcached","Memcached","Memcached","Memcached","Memcached","Memcached","Memcached"],
               'w/o psandbox(average)':[0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0], 
               'w/o psandbox(99 per)':[0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0],
               'psandbox(average)':[0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0],
               'psandbox(99 per)':[0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0],
               'ratio(average)':[0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0]}
    df = pd.DataFrame(fields)
    for log in overhead_logs:
        file = args.input + "/" + log
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
            if "read" in log:
                n = int(log.split(".")[0].split("_")[-1])
                if n == 1:
                    index = df.loc[df['setting'] == "s1"].index
                elif n == 16:
                    index = df.loc[df['setting'] == "s2"].index
                elif n == 32:
                    index = df.loc[df['setting'] == "s3"].index
                elif n == 64:
                    index = df.loc[df['setting'] == "s4"].index
                if "psandbox" in log:
                    print (log)
                    print ("write avg " + str(write_avg))
                    print ("read avg " + str(read_avg))
                    print ("--------")
                    df.at[index,"psandbox(average)"] = write_avg*0.1 + read_avg * 0.9
                    df.at[index,"psandbox(99 per)"]= tail_write*0.1 + tail_read * 0.9
                else:
                    print (log)
                    print ("write avg " + str(write_avg))
                    print ("read avg " + str(read_avg))
                    print ("--------")
                    df.at[index,"w/o psandbox(average)"] = write_avg*0.1 + read_avg * 0.9
                    df.at[index,"w/o psandbox(99 per)"]= tail_write*0.1 + tail_read * 0.9
            else:
                n = int(log.split(".")[0].split("_")[-1])
                if n == 1:
                    index = df.loc[df['setting'] == "s5"].index
                elif n == 16:
                    index = df.loc[df['setting'] == "s6"].index
                elif n == 32:
                    index = df.loc[df['setting'] == "s7"].index
                elif n == 64:
                    index = df.loc[df['setting'] == "s8"].index
                if "psandbox" in log:
                    print (log)
                    print ("write avg " + str(write_avg))
                    print ("read avg " + str(read_avg))
                    print ("--------")
                    df.at[index,"psandbox(average)"] = write_avg*0.9 + read_avg * 0.1
                    df.at[index,"psandbox(99 per)"]= tail_write*0.9 + tail_read * 0.1
                else:
                    print (log)
                    print ("write avg " + str(write_avg))
                    print ("read avg " + str(read_avg))
                    print ("--------")
                    df.at[index,"w/o psandbox(average)"] = write_avg*0.9 + read_avg * 0.1
                    df.at[index,"w/o psandbox(99 per)"]= tail_write*0.9 + tail_read * 0.1
    values = (df["psandbox(average)"] - df["w/o psandbox(average)"]) / df["w/o psandbox(average)"] 
    df["ratio(average)"] = values
    df.to_csv(args.output, index=False)

if __name__ == "__main__":
    # execute only if run as a script
    args = parser.parse_args()
    if not args.input :
        sys.stderr.write('Must specify input data file\n')
        sys.exit(1)
    get_result(args)
