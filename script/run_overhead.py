#!/usr/bin/python3
import csv
import argparse
import sys
import os
import time

parser = argparse.ArgumentParser()
parser.add_argument('-n','--name', default = "MySQL" , type=str, help="the   number of round")


def main(args):
    if args.name.lower() == "all":
        for name in ["mysql","postgresql","apache","varnish","memcached"]:
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
        cmd = "./script/log_analyzer.py -i result/overhead -o result/data/mitigation_parties.csv -d 2 -t 7"
        os.system(cmd)
    else:
        cmd = "./script/run_experiment.py -i script/overhead/" + args.name.lower() + "/  -p 0 0 64 1 60 "
        os.system(cmd)
        cmd = "./script/run_experiment.py -i script/overhead/" + args.name.lower() + "/  -p 0 0 64 16 60 "
        os.system(cmd)
        cmd = "./script/run_experiment.py -i script/overhead/" + args.name.lower() + "/  -p 0 0 64 32 60 "
        os.system(cmd)
        cmd = "./script/run_experiment.py -i script/overhead/" + args.name.lower() + "/  -p 0 0 64 64 60 "
        os.system(cmd)
        cmd = "./script/run_experiment.py -i script/overhead/" + args.name.lower() + "/  -p 0 1 64 1 60 "
        os.system(cmd)
        cmd = "./script/run_experiment.py -i script/overhead/" + args.name.lower() + "/  -p 0 1 64 16 60 "
        os.system(cmd)
        cmd = "./script/run_experiment.py -i script/overhead/" + args.name.lower() + "/  -p 0 1 64 32 60 "
        os.system(cmd)
        cmd = "./script/run_experiment.py -i script/overhead/" + args.name.lower() + "/  -p 0 1 64 64 60 "
        os.system(cmd)
        cmd = "./script/run_experiment.py -i script/overhead/" + args.name.lower() + "/  -p 1 0 64 1 60 "
        os.system(cmd)
        cmd = "./script/run_experiment.py -i script/overhead/" + args.name.lower() + "/  -p 1 0 64 16 60 "
        os.system(cmd)
        cmd = "./script/run_experiment.py -i script/overhead/" + args.name.lower() + "/  -p 1 0 64 32 60 "
        os.system(cmd)
        cmd = "./script/run_experiment.py -i script/overhead/" + args.name.lower() + "/  -p 1 0 64 64 60 "
        os.system(cmd)
        cmd = "./script/run_experiment.py -i script/overhead/" + args.name.lower() + "/  -p 1 1 64 1 60 "
        os.system(cmd)
        cmd = "./script/run_experiment.py -i script/overhead/" + args.name.lower() + "/  -p 1 1 64 16 60 "
        os.system(cmd)
        cmd = "./script/run_experiment.py -i script/overhead/" + args.name.lower() + "/  -p 1 1 64 32 60 "
        os.system(cmd)
        cmd = "./script/run_experiment.py -i script/overhead/" + args.name.lower() + "/  -p 1 1 64 64 60 "
        os.system(cmd)
        cmd = "./script/log_analyzer.py -i result/overhead/" + args.name.lower() +"/ -o result/data/mitigation_pbox.csv -t 7"
        os.system(cmd)


if __name__ == "__main__":
    # execute only if run as a script
    args = parser.parse_args()
    main(args)
