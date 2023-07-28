#!/usr/bin/python3
import csv
import argparse
import sys
import os
import time

parser = argparse.ArgumentParser()
parser.add_argument('-n','--name', default = "all" , type=str, help="the tested application name")
parser.add_argument('-t','--threads', default = 1 , type=str, help="the number of thread")
parser.add_argument('-r','--isread', default = 0 , type=str, help="0: write, 1: read")
parser.add_argument('-p','--ispbox', default = 0 , type=str, help="0: no pbox, 1: pbox")

def main(args):
    if args.name.lower() == "all":
        for name in ["mysql","postgresql"]:
            cmd = "./script/run_experiment.py -i script/overhead/" + name.lower() + "/  -p 0 0 64 1 60 "
            os.system(cmd)
            cmd = "./script/run_experiment.py -i script/overhead/" + name.lower() + "/  -p 0 0 64 16 60 "
            os.system(cmd)
            cmd = "./script/run_experiment.py -i script/overhead/" + name.lower() + "/  -p 0 0 64 32 60 "
            os.system(cmd)
            cmd = "./script/run_experiment.py -i script/overhead/" + name.lower() + "/  -p 0 0 64 64 60 "
            os.system(cmd)
            cmd = "./script/run_experiment.py -i script/overhead/" + name.lower() + "/  -p 0 1 64 1 60 "
            os.system(cmd)
            cmd = "./script/run_experiment.py -i script/overhead/" + name.lower() + "/  -p 0 1 64 16 60 "
            os.system(cmd)
            cmd = "./script/run_experiment.py -i script/overhead/" + name.lower() + "/  -p 0 1 64 32 60 "
            os.system(cmd)
            cmd = "./script/run_experiment.py -i script/overhead/" + name.lower() + "/  -p 0 1 64 64 60 "
            os.system(cmd)
            cmd = "./script/run_experiment.py -i script/overhead/" + name.lower() + "/  -p 1 0 64 1 60 "
            os.system(cmd)
            cmd = "./script/run_experiment.py -i script/overhead/" + name.lower() + "/  -p 1 0 64 16 60 "
            os.system(cmd)
            cmd = "./script/run_experiment.py -i script/overhead/" + name.lower() + "/  -p 1 0 64 32 60 "
            os.system(cmd)
            cmd = "./script/run_experiment.py -i script/overhead/" + name.lower() + "/  -p 1 0 64 64 60 "
            os.system(cmd)
            cmd = "./script/run_experiment.py -i script/overhead/" + name.lower() + "/  -p 1 1 64 1 60 "
            os.system(cmd)
            cmd = "./script/run_experiment.py -i script/overhead/" + name.lower() + "/  -p 1 1 64 16 60 "
            os.system(cmd)
            cmd = "./script/run_experiment.py -i script/overhead/" + name.lower() + "/  -p 1 1 64 32 60 "
            os.system(cmd)
            cmd = "./script/run_experiment.py -i script/overhead/" + name.lower() + "/  -p 1 1 64 64 60 "
            os.system(cmd)
        for name in ["apache","varnish"]:
            cmd = "./script/run_experiment.py -i script/overhead/" + name.lower() + "/  -p 0 1 60"
            os.system(cmd)
            cmd = "./script/run_experiment.py -i script/overhead/" + name.lower() + "/  -p 0 16 60"
            os.system(cmd)
            cmd = "./script/run_experiment.py -i script/overhead/" + name.lower() + "/  -p 0 32 60"
            os.system(cmd)
            cmd = "./script/run_experiment.py -i script/overhead/" + name.lower() + "/  -p 0 64 60"
            os.system(cmd)
            cmd = "./script/run_experiment.py -i script/overhead/" + name.lower() + "/  -p 1 1 60 "
            os.system(cmd)
            cmd = "./script/run_experiment.py -i script/overhead/" + name.lower() + "/  -p 1 16 60 "
            os.system(cmd)
            cmd = "./script/run_experiment.py -i script/overhead/" + name.lower() + "/  -p 1 32 60 "
            os.system(cmd)
            cmd = "./script/run_experiment.py -i script/overhead/" + name.lower() + "/  -p 1 64 60 "
            os.system(cmd)
        name = "memcached"
        cmd = "./script/run_experiment.py -i script/overhead/" + name.lower() + "/  -p 0 1 1"
        os.system(cmd)
        cmd = "./script/run_experiment.py -i script/overhead/" + name.lower() + "/  -p 0 1 16 60"
        os.system(cmd)
        cmd = "./script/run_experiment.py -i script/overhead/" + name.lower() + "/  -p 0 1 32 60"
        os.system(cmd)
        cmd = "./script/run_experiment.py -i script/overhead/" + name.lower() + "/  -p 0 1 64 60"
        os.system(cmd)
        cmd = "./script/run_experiment.py -i script/overhead/" + name.lower() + "/  -p 1 0 1"
        os.system(cmd)
        cmd = "./script/run_experiment.py -i script/overhead/" + name.lower() + "/  -p 1 0 16"
        os.system(cmd)
        cmd = "./script/run_experiment.py -i script/overhead/" + name.lower() + "/  -p 1 0 32"
        os.system(cmd)
        cmd = "./script/run_experiment.py -i script/overhead/" + name.lower() + "/  -p 1 0 64"
        os.system(cmd)
        cmd = "./script/run_experiment.py -i script/overhead/" + name.lower() + "/  -p 1 1 1"
        os.system(cmd)
        cmd = "./script/run_experiment.py -i script/overhead/" + name.lower() + "/  -p 1 1 16 60"
        os.system(cmd)
        cmd = "./script/run_experiment.py -i script/overhead/" + name.lower() + "/  -p 1 1 32 60"
        os.system(cmd)
        cmd = "./script/run_experiment.py -i script/overhead/" + name.lower() + "/  -p 1 1 64 60"
        os.system(cmd)
        cmd = "./script/run_experiment.py -i script/overhead/" + name.lower() + "/  -p 0 0 1"
        os.system(cmd)
        cmd = "./script/run_experiment.py -i script/overhead/" + name.lower() + "/  -p 0 0 16"
        os.system(cmd)
        cmd = "./script/run_experiment.py -i script/overhead/" + name.lower() + "/  -p 0 0 32"
        os.system(cmd)
        cmd = "./script/run_experiment.py -i script/overhead/" + name.lower() + "/  -p 0 0 64"
        os.system(cmd)
    else:
        if args.name in ["mysql","postgresql","memcached"]:
            cmd = "./script/run_experiment.py -i script/overhead/" + args.name.lower() + "/  -p " + args.ispbox + " " \
            + args.isread + " 64 " + args.threads + " 60"
            os.system(cmd)
            cmd = "./script/log_analyzer.py -i result/overhead/" + args.name.lower() +"/ -o result/data/eval_overhead.csv -t 7"
            os.system(cmd)
        elif args.name in ["apache","varnish"]:
            cmd = "./script/run_experiment.py -i script/overhead/" + args.name.lower() + "/  -p " + args.ispbox + " " \
            + args.threads + " 60"
            os.system(cmd)
        elif args.name == "memcached":
            cmd = "./script/run_experiment.py -i script/overhead/" + args.name.lower() + "/  -p " + args.ispbox + " " \
            + args.isread + " " + args.threads 
            os.system(cmd)
    cmd = "./script/log_analyzer.py -i result/overhead -o result/data/eval_overhead.csv -d 2 -t 7"
    os.system(cmd)

if __name__ == "__main__":
    # execute only if run as a script
    args = parser.parse_args()
    main(args)
