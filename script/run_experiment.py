#!/usr/bin/python3
import csv
import argparse
import sys
import os
import time

parser = argparse.ArgumentParser()
parser.add_argument('-i','--input', help="path to input file")
parser.add_argument('-r','--rounds', default = 1 , type=int, help="the number of round")
parser.add_argument('-p','--parameter', default = 0, nargs="+", type=int, help="parameter for the lanuch.sh")
parser.add_argument('-d','--depth', default = 1 , type=int, help="the depth of the folder for the input dir")
parser.add_argument('-f','--force', action='store_true', help="force to write to the input folder")


def execute_file(path, file,rounds, command_set): 
    command = ""
    for i in command_set:
        command = command + " " + str(i) 
        
    for i in range(rounds):
        cmd = "cd " + path + " && ./" + file + command
        os.system(cmd)
        #print(cmd)
        time.sleep(1)

def execute_command(path):
    for file in os.listdir(args.input + "/"+ path):
        if file == "launch.sh":
            if args.parameter == 0:
                execute_file(args.input + "/"+ path,file,args.rounds,[])
            else: 
                list_p = list(args.parameter)
                execute_file(args.input + "/"+ path,file,args.rounds,list_p)

def main(args):
    if args.force:
        cmd = "rm -rf result" 
        os.system(cmd)
    
    cmd = "mkdir -p result && mkdir -p result/cases"
    os.system(cmd)
    cmd = "mkdir -p result/overhead" 
    os.system(cmd)
    cmd = "mkdir -p result/sensitivity"
    os.system(cmd)
    cmd = "mkdir -p result/figures"
    os.system(cmd)
    cmd = "mkdir -p result/data"
    os.system(cmd)
    if args.depth == 2:
        for path in os.listdir(args.input):
            if os.path.isdir(args.input + "/"+  path):
                execute_command(path)
    elif args.depth == 1:
        execute_command("")
    
if __name__ == "__main__":
    # execute only if run as a script
    args = parser.parse_args()
    if not args.input:
        sys.stderr.write('Must specify input data folder\n')
        sys.exit(1)
    if int(args.depth) > 2:
        sys.stderr.write('The input data folder can not be deeper than three layer \n') 
        sys.exit(1)
    main(args)
