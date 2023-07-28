#!/usr/bin/python3
import csv
import argparse
import sys
import os
import pandas as pd
import re
import statistics

parser = argparse.ArgumentParser()
parser.add_argument('-i','--input', help="path to input file")
parser.add_argument('-o', '--output', default="./output.csv", help="path to output file")
parser.add_argument('-d','--depth', default = 1 , type=int, help="the depth of the folder for the input dir")
parser.add_argument('-t','--type', default = 1 , type=int,help="the type of experiment")

sensitivity_logs = [
    'no_psandbox.log',
    'rule_25.log',
    'rule_50.log',
    'rule_75.log',
    'rule_100.log',
    'rule_125.log',
]

sensitivity_apache_logs = [
    'no_interference.log'
    'no_psandbox.log',
    'rule_25.log',
    'rule_50.log',
    'rule_75.log',
    'rule_100.log',
    'rule_125.log',
]

adaptive_logs = [
   'fix_10.log',
   'fix.log',
   'psandbox.log'
]

thread_regex = re.compile(
    'thds: [0-9]* '
)

pgbench_regex = re.compile(
    's, [0-9]*\.[0-9]* tps'
)

qps_regex = re.compile(
    'qps: [0-9]*\.[0-9]* '
)

tail_regex = re.compile(
   '[0-9]*\.[0-9]* err/s'
)

apache_mean_regex = re.compile(
    'Time per request:       [0-9]*\.[0-9]+ \[ms] ' +
    '\(mean\)'
)
float_regex = re.compile(
    '[0-9]*\.[0-9]+'
)

apache_cases = ['c11','c12','c13','c14','c15']
def get_normal_tps(path,file,type):
    try:
        i_file = open(path + "/"+ file, 'r')
        normal_throughputs = []
        interference_throughputs = []
        normal_flag = False
        interference_flag = False
        normal_latency = 0
        interference_request = 0
        interference_latency = 0
        threads = 1
        step = 10
        
        for line in i_file.readlines():
            if line == "normal\n":
                normal_flag = True 
            if line == "normal end\n":
                normal_flag = False

            if line == "interference\n":
                interference_flag = True
            if line == "interference end\n":
                interference_flag = False

            result = thread_regex.search(line)

            if result:   
                threads = int(result.group().split()[1])
                # print(threads)
                if normal_flag:
                    normal_throughputs.append(float(qps_regex.search(line).group().split()[1])/threads)
                if interference_flag:
                    # print(float(qps_regex.search(line).group().split()[1])/threads)
                    interference_throughputs.append(float(qps_regex.search(line).group().split()[1])/threads)

            if type == 1 and pgbench_regex.search(line):
                if normal_flag:
                    normal_throughputs.append(float(pgbench_regex.search(line).group().split()[1]))
                if interference_flag:
                    interference_throughputs.append(float(pgbench_regex.search(line).group().split()[1]))
        
        for normal_throughput in normal_throughputs:
            normal_latency = normal_latency + normal_throughput*step
        if normal_latency != 0:
            normal_latency = (len(interference_throughputs)*step)*1000/normal_latency

        for interference_throughput in interference_throughputs:
            interference_request = interference_request + interference_throughput*step

        if interference_request != 0:
            interference_latency = (len(interference_throughputs)*step)*1000/interference_request
        return [normal_latency,interference_latency]
    except OSError:
        return [0,0]

   

def taillatency_analyzer(file_name,type):
    i_file = open(file_name, 'r')
    normal_throughputs = []
    interference_throughputs = []
    normal_flag = False
    interference_flag = False
    normal_latency = 0.0
    normal_request = 0.0
    interference_request = 0.0
    interference_latency = 0.0
    threads = 1
    step = 10
    for line in i_file.readlines():
        curLine=line.strip().split(" ")
        if line == "normal\n":
            normal_flag = True 
        if line == "normal end\n":
            normal_flag = False

        if line == "interference\n":
            interference_flag = True
        if line == "interference end\n":
            interference_flag = False

        result = thread_regex.search(line)
        if result:   
            threads = int(result.group().split()[1])
            if normal_flag:
                # print(float(tail_regex.search(line).group().split()[0]))

                normal_throughputs.append(float(tail_regex.search(line).group().split()[0])/threads)
            if interference_flag:
                interference_throughputs.append(float(tail_regex.search(line).group().split()[0])/threads)
    
    for normal_throughput in normal_throughputs:
        normal_request = normal_request + normal_throughput

    
    if normal_request != 0:
        normal_latency = normal_request/ len(normal_throughputs)

    for interference_throughput in interference_throughputs:
        interference_request = interference_request + interference_throughput

    if interference_request != 0:
        interference_latency = interference_request/len(interference_throughputs)
    
    return [normal_latency,interference_latency]

def analyzer_apache(path,file):
    i_file = open(path + "/"+ file, 'r')
    mean_latencies = []
    for line in i_file:
        result = apache_mean_regex.search(line)
        if result:
            n = float(float_regex.search(line).group())
            mean_latencies.append(n)
    return statistics.mean(mean_latencies)

def average_analyzer(args):
    fields = ['id','Name', 'w/o interference(ms)', 'with interference(ms)', 'cgroup(ms)','psandbox(ms)'] 
    with open(args.output, 'w') as csvfile: 
        csvwriter = csv.writer(csvfile) 
        csvwriter.writerow(fields) 
        if args.depth == 2:
            for dir_name in os.listdir(args.input):
                path = args.input + "/" + dir_name
                if os.path.isdir(path):
                    id = dir_name[1:]
                    row = [id,dir_name]
                    if dir_name in apache_cases:
                        for file in os.listdir(path):
                            if file == "no_psandbox.log":
                                interference_latencys = analyzer_apache(path,file)
                                row.insert(3,interference_latencys)
                            elif file == "no_interference.log":
                                normal_latencys = analyzer_apache(path,file)
                                row.insert(2,normal_latencys)
                            elif file == "cgroup.log":
                                cgroup_latencys = analyzer_apache(path,file)
                                row.insert(4,cgroup_latencys)
                            elif file == "psandbox.log":
                                psandbox_latencys = analyzer_apache(path,file)
                                row.insert(5,psandbox_latencys)
                    else:
                        for file in os.listdir(path):
                            if (file == "no_psandbox.log"):
                                if dir_name == "c6":
                                    normal_latencys = get_normal_tps(path,file,1)
                                else:
                                    normal_latencys = get_normal_tps(path,file,0)
                                # normal_latencys = get_normal_tps(path,file,0)
                                row.insert(2,normal_latencys[0])
                                row.insert(3,normal_latencys[1])
                            elif (file == "cgroup.log"):
                                if dir_name == "c6":
                                    cgroup_latency = get_normal_tps(path,file,1)
                                else:
                                    cgroup_latency = get_normal_tps(path,file,0)
                                # cgroup_latency = get_normal_tps(path,file,0)
                                row.insert(4,cgroup_latency[1])
                            elif (file == "psandbox.log"):
                                if dir_name == "c6":
                                    psandbox_latency = get_normal_tps(path,file,1)
                                else:
                                    psandbox_latency = get_normal_tps(path,file,0)
                                # psandbox_latency = get_normal_tps(path,file,0)
                                row.insert(5,psandbox_latency[1])
                    csvwriter.writerow(row)
        elif args.depth == 1:
            row = [args.input]
            for file in os.listdir(args.input):
                if (file == "no_psandbox.log"):
                    if dir_name == "c6":
                        normal_latencys = get_normal_tps(args.input,file,1)
                    else:
                        normal_latencys = get_normal_tps(args.input,file,0)
                    # normal_latencys = get_normal_tps(args.input,file,0)
                    #print(args.input  + " : " + str(normal_latencys[0]) + " " +  str(normal_latencys[1]))
                    row.insert(2,normal_latencys[0])
                    row.insert(3,normal_latencys[1])
                elif (file == "cgroup.log"):
                    if dir_name == "c6":
                        cgroup_latency = get_normal_tps(args.input,file,1)
                    else:
                        cgroup_latency = get_normal_tps(args.input,file,0)
                    # cgroup_latency = get_normal_tps(args.input,file,0)
                    #print(args.input  + " : " + str(cgroup_latency[1]) )
                    row.insert(4,cgroup_latency[1])
                elif (file == "psandbox.log"):
                    if dir_name == "c6":
                        psandbox_latency = get_normal_tps(args.input,file,1)
                    else:
                        psandbox_latency = get_normal_tps(args.input,file,0)
                    # psandbox_latency = get_normal_tps(args.input,file,0)
                    #print(args.input  + " : " + str(psandbox_latency[1]))
                    row.insert(5,psandbox_latency[1])
            csvwriter.writerow(row)
            # print(file + ": " + row)

def retro_analyzer(args):
    fields = ['id','Name', 'w/o interference(ms)', 'with interference(ms)', 'retro(ms)'] 
    with open(args.output, 'w') as csvfile: 
        csvwriter = csv.writer(csvfile) 
        csvwriter.writerow(fields) 
        if args.depth == 2:
            for dir_name in os.listdir(args.input):
                path = args.input + "/" +dir_name
                if os.path.isdir(path):
                    id = dir_name[1:]
                    row = [id,dir_name]
                    if dir_name in apache_cases:
                        for file in os.listdir(path):
                            if file == "no_psandbox.log":
                                interference_latencys = analyzer_apache(path,file)
                                row.insert(3,interference_latencys)
                            elif file == "no_interference.log":
                                normal_latencys = analyzer_apache(path,file)
                                row.insert(2,normal_latencys)
                            elif file == "retro.log":
                                cgroup_latencys = analyzer_apache(path,file)
                                row.insert(4,cgroup_latencys)
                    else:
                        for file in os.listdir(path):
                            if (file == "no_psandbox.log"):
                                if dir_name == "c6":
                                    normal_latencys = get_normal_tps(path,file,1)
                                else:
                                    normal_latencys = get_normal_tps(path,file,0)
                                # normal_latencys = get_normal_tps(path,file,0)
                                row.insert(2,normal_latencys[0])
                                row.insert(3,normal_latencys[1])
                            elif (file == "retro.log"):
                                if dir_name == "c6":
                                    cgroup_latency = get_normal_tps(path,file,1)
                                else:
                                    cgroup_latency = get_normal_tps(path,file,0)
                                # cgroup_latency = get_normal_tps(path,file,0)
                                row.insert(4,cgroup_latency[1])
                    csvwriter.writerow(row)
        elif args.depth == 1:
            row = [1, args.input]
            for file in os.listdir(args.input):
                if (file == "no_psandbox.log"):
                    if dir_name == "c6":
                        cgroup_latency = get_normal_tps(args.input,file,1)
                    else:
                        cgroup_latency = get_normal_tps(args.input,file,0)
                    # normal_latencys = get_normal_tps(args.input,file,0)
                    #print(args.input  + " : " + str(normal_latencys[0]) + " " +  str(normal_latencys[1]))
                    row.insert(2,normal_latencys[0])
                    row.insert(3,normal_latencys[1])
                elif (file == "retro.log"):
                    if dir_name == "c6":
                        cgroup_latency = get_normal_tps(args.input,file,1)
                    else:
                        cgroup_latency = get_normal_tps(args.input,file,0)
                    # cgroup_latency = get_normal_tps(args.input,file,0)
                    #print(args.input  + " : " + str(cgroup_latency[1]) )
                    row.insert(4,cgroup_latency[1])
            csvwriter.writerow(row)
            # print(file + ": " + row)


def tail_analyzer(args):
    fields = ['Name', 'w/o interference(ms)', 'with interference(ms)', 'cgroup(ms)','psandbox(ms)'] 
    with open(args.output, 'w') as csvfile: 
        csvwriter = csv.writer(csvfile) 
        csvwriter.writerow(fields) 
        if args.depth == 2:
            for dir_name in os.listdir(args.input):
                path = args.input + "/" + dir_name
                if os.path.isdir(path):
                    row = [dir_name]
                    for file_name in os.listdir(path):
                        if (file_name == "no_psandbox.log"):
                            normal_latencys = taillatency_analyzer(path + "/"+ file_name,0)
                            row.insert(1,normal_latencys[0])
                            row.insert(2,normal_latencys[1])
                        elif (file_name == "cgroup.log"):
                            cgroup_latency = taillatency_analyzer(path + "/"+ file_name,0)
                            row.insert(3,cgroup_latency[1])
                        elif (file_name == "psandbox.log"):
                            psandbox_latency = taillatency_analyzer(path + "/"+ file_name,0);
                            row.insert(4,psandbox_latency[1])
                        elif (fine_name == "parties.log"):
                            psandbox_latency = taillatency_analyzer(path + "/"+ file_name,0);
                            row.insert(4,psandbox_latency[1])
                    csvwriter.writerow(row)
        elif args.depth == 1:
            row = [args.input]
            for file in os.listdir(args.input):
                if (file == "no_psandbox.log"):
                    normal_latencys = taillatency_analyzer(args.input+ "/"+  file,0)
                    print(args.input  + " : " + str(normal_latencys[0]) + " " +  str(normal_latencys[1]))
                    row.insert(1,normal_latencys[0])
                    row.insert(2,normal_latencys[1])
                elif (file == "cgroup.log"):
                    cgroup_latency = taillatency_analyzer(args.input+ "/"+  file,0)
                    row.insert(3,cgroup_latency[1])
                elif (file == "psandbox.log"):
                    psandbox_latency = taillatency_analyzer(args.input+ "/"+  file,0)
                    row.insert(4,psandbox_latency[1])
                elif (file == "parties.log"):
                    psandbox_latency = taillatency_analyzer(path + "/"+ file,0);
                    row.insert(4,psandbox_latency[1])
            csvwriter.writerow(row)
            # print(file + ": " + row)


def parties_analyzer(args):
    fields = ['id','Name', 'w/o interference(ms)', 'with interference(ms)', 'parites(ms)'] 
    with open(args.output, 'w') as csvfile: 
        csvwriter = csv.writer(csvfile) 
        csvwriter.writerow(fields) 
        if args.depth == 2:
            for dir_name in os.listdir(args.input):
                path = args.input + "/" + dir_name
                if os.path.isdir(path):
                    id = dir_name[1:]
                    row = [id,dir_name]
                    if dir_name in apache_cases:
                        for file in os.listdir(path):
                            if file == "no_interference_parties.log":
                                interference_latencys = analyzer_apache(path,file)
                                row.insert(3,interference_latencys)
                            elif file == "no_parties.log":
                                normal_latencys = analyzer_apache(path,file)
                                row.insert(2,normal_latencys)
                            elif file == "parties.log":
                                cgroup_latencys = analyzer_apache(path,file)
                                row.insert(4,cgroup_latencys)
                    else:
                        for file_name in os.listdir(path):
                            if (file_name == "parties_baseline.log"):
                                if dir_name == "c6":
                                    normal_latencys = get_normal_tps(path,file_name,1)
                                else:
                                    normal_latencys = get_normal_tps(path,file_name,0)
                                row.insert(2,normal_latencys[0])
                                row.insert(3,normal_latencys[1])
                        if os.path.isdir(path + "/front_1"):
                            for file_name in os.listdir(path + "/front_1"):
                                if (file_name == "parties.log"):
                                    if dir_name == "c6":
                                        psandbox_latency = get_normal_tps(path + "/front_1",file_name,1)
                                    else:
                                        psandbox_latency = get_normal_tps(path + "/front_1",file_name,0)
                                    row.insert(4,psandbox_latency[1])
                    csvwriter.writerow(row)
        elif args.depth == 1:
            row = [args.input]
            for file in os.listdir(args.input):
                if (file == "parties_baseline.log"):
                    if "c6" in args.input:
                        normal_latencys = get_normal_tps(args.input,file,1)
                    else:
                        normal_latencys = get_normal_tps(args.input,file,0)
                    # print(args.input  + " : " + str(normal_latencys[0]) + " " +  str(normal_latencys[1]))
                    row.insert(1,normal_latencys[0])
                    row.insert(2,normal_latencys[1])
            if os.path.isdir(args.input + "/front_1"):
                for file_name in os.listdir(args.input + "/front_1"):
                    if (file_name == "parties.log"):
                        if "c6" in args.input:
                            psandbox_latency = get_normal_tps(args.input +  "/front_1",file_name,1)
                        else:
                            psandbox_latency = get_normal_tps(args.input + "/front_1",file_name,0)
                        row.insert(3,psandbox_latency[1])
            csvwriter.writerow(row)
            # print(row)



def sentivity_result(args):
    fields = ['id', 'w/o interference(ms)', 'with interference(ms)','25%', '50%', '75%','100%','125%']
    with open(args.output, 'w') as csvfile: 
        csvwriter = csv.writer(csvfile) 
        csvwriter.writerow(fields) 
        if args.depth == 2:
            for dir_name in os.listdir(args.input):
                path = args.input + "/" + dir_name
                if os.path.isdir(path):
                    row = [dir_name]
                    for index,file in enumerate(sensitivity_logs):
                        normal_latencys = get_normal_tps(path,file,0)
                        if (file == "no_psandbox.log"):
                            row.insert(1,normal_latencys[0])
                            row.insert(2,normal_latencys[1])
                        else:
                            row.insert(index+2,normal_latencys[1])
                    csvwriter.writerow(row)

def adaptive_result(args):
    fields = ['case', 'Fixed_10','Fixed_100','adaptive']
    with open(args.output, 'w') as csvfile: 
        csvwriter = csv.writer(csvfile) 
        csvwriter.writerow(fields) 
        if args.depth == 2:
            for dir_name in os.listdir(args.input):
                path = args.input + "/" + dir_name
                if os.path.isdir(path):
                    row = [dir_name]
                    for index,file in enumerate(adaptive_logs):
                        # print(file)
                        normal_latencys = get_normal_tps(path,file)
                        # print(normal_latencys)
                        row.insert(index+1,normal_latencys[1])
                    csvwriter.writerow(row)

def overhead_analyzer(args):
    for dir_name in os.listdir(args.input):
        path = args.input + "/" + dir_name
        if os.path.isdir(path):
            cmd = "./script/result_analyzer/get_" + dir_name + "_overhead.py -i result/overhead/" + dir_name + " -o result/data/overhead_" + dir_name + ".csv"
            os.system(cmd)
            

    final_df = pd.DataFrame(columns = ['setting', 'app','w/o psandbox(average)','w/o psandbox(99 per)','psandbox(average)','psandbox(99 per)'])
    for dir_name in os.listdir(args.input):
        path = "./result/data/overhead_" + dir_name + ".csv"
        df = pd.read_csv(path)
        final_df = pd.concat([df, final_df], ignore_index=True, sort=False).reset_index(drop=True)
    final_df.to_csv(args.output, encoding='utf-8', index=False)


if __name__ == "__main__":
    # execute only if run as a script
    args = parser.parse_args()
    if not args.input :
        sys.stderr.write('Must specify input data file\n')
        sys.exit(1)
    if int(args.depth) > 2:
        sys.stderr.write('The input data folder can not be deeper than three layer \n') 
        sys.exit(1)
    if args.type == 1:
        tail_analyzer(args)
    elif args.type == 2:
        average_analyzer(args)
    elif args.type == 3:
        sentivity_result(args)
    elif args.type == 4:
        adaptive_result(args)
    elif args.type == 5:
        parties_analyzer(args)
    elif args.type == 6:
        retro_analyzer(args)
    elif args.type == 7:
        overhead_analyzer(args)
