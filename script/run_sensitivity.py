#!/usr/bin/python3
import csv
import argparse
import sys
import os
import time

parser = argparse.ArgumentParser()
parser.add_argument('-i','--index', default = 0 , type=int, help="the case index")

def main(args):
    if args.index == 0:
        for dir_name in os.listdir("./script/sensitivity"):
            if os.path.isdir("./script/sensitivity/" + dir_name):
                cmd = "./script/run_experiment.py -i script/sensitivity/" + dir_name 
                os.system(cmd)
                cmd = "cp -r result/cases/" + dir_name + "/no_psandbox.log result/sensitivity/" + dir_name
                os.system(cmd)
        cmd = "./script/log_analyzer.py -i result/sensitivity -o result/data/eval_sensitivity.csv -d 2 -t 3"
        os.system(cmd)
    else:
        cmd = "./script/run_experiment.py -i script/sensitivity/c" + str(args.index) + "/  -p 1"
        os.system(cmd)
        cmd = "cp -r result/cases/c" + str(args.index) + "/no_psandbox.log result/sensitivity/c" + str(args.index)
        os.system(cmd)
        cmd = "./script/log_analyzer.py -i result/sensitivity -o result/data/eval_sensitivity.csv -d 2 -t 3"
        os.system(cmd)


if __name__ == "__main__":
    # execute only if run as a script
    args = parser.parse_args()
    main(args)
