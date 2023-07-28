#!/usr/bin/python3
import csv
import argparse
import sys
import os
import time

parser = argparse.ArgumentParser()
parser.add_argument('-i','--index', default = 0 , type=int, help="the case index")
parser.add_argument('-t','--type', default = 0 , type=int, help="the  type of experiment")

def run_pbox(args):
    if args.index == 0:
        cmd = "./script/run_experiment.py -i script/cases/c2/  -p 3"
        os.system(cmd)
        for index in range(1,17):
            cmd = "./script/run_experiment.py -i script/cases/c" + str(index) + "/  -p 1"
            os.system(cmd)
            cmd = "./script/run_experiment.py -i script/cases/c" + str(index) + "/  -p 2"
            os.system(cmd)
            if index != 2:
                cmd = "./script/run_experiment.py -i script/cases/c" + str(index) + "/  -p 3"
                os.system(cmd)
    else:
        cmd = "./script/run_experiment.py -i script/cases/c" + str(args.index) + "/  -p 1"
        os.system(cmd)
        cmd = "./script/run_experiment.py -i script/cases/c" + str(args.index) + "/  -p 2"
        os.system(cmd)
        cmd = "./script/run_experiment.py -i script/cases/c" + str(args.index) + "/  -p 3"
        os.system(cmd)
    cmd = "./script/log_analyzer.py -i result/cases -o result/data/mitigation_pbox.csv -d 2 -t 2"
    os.system(cmd)


def run_comparsion(args):
    if args.index == 0:
        for index in range(1,17):
            cmd = "./script/run_experiment.py -i script/cases/c" + str(index) + "/  -p 6"
            os.system(cmd)
            cmd = "./script/run_experiment.py -i script/cases/c" + str(index) + "/  -p 7"
            os.system(cmd)
            cmd = "./script/run_experiment.py -i script/cases/c" + str(index) + "/  -p 8"
            os.system(cmd)
    else:
        cmd = "./script/run_experiment.py -i script/cases/c" + str(args.index) + "/  -p 6"
        os.system(cmd)
        cmd = "./script/run_experiment.py -i script/cases/c" + str(args.index) + "/  -p 7"
        os.system(cmd)
        cmd = "./script/run_experiment.py -i script/cases/c" + str(args.index) + "/  -p 8"
        os.system(cmd)
    cmd = "./script/log_analyzer.py -i result/cases -o result/data/eval_mitigation.csv -d 2 -t 5"
    os.system(cmd)

def main(args):
    if args.type == 0:
        run_pbox(args)
    elif args.type == 1:
        run_comparsion(args)

if __name__ == "__main__":
    # execute only if run as a script
    args = parser.parse_args()
    main(args)
