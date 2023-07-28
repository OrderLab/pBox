#!/usr/bin/env python

import sys
import pandas as pd
from datetime import datetime
import matplotlib.pyplot as plt
import matplotlib.dates as mdates
from matplotlib.ticker import MultipleLocator, PercentFormatter
import numpy as np
import argparse
import matplotlib

matplotlib.rcParams['pdf.fonttype'] = 42
matplotlib.rcParams['ps.fonttype'] = 42
# matplotlib.rc('text', usetex=True)

parser = argparse.ArgumentParser()
parser.add_argument('-o', '--output', help="path to output image file")
parser.add_argument('input', help="path to input data file")

def compute_reduction_ratio(df, rules):
    interference = df['with interference(ms)']
    no_interference = df['w/o interference(ms)']
    suffix = '_reduction_ratio'
    for rule in rules:
        rule_latency = df[rule]
        reduction_ratio = (interference - rule_latency) / (interference - no_interference)
        df[rule + suffix] = reduction_ratio
    return suffix

def plot(args, show_ratio=True):
    # parse data from CSV
    df = pd.read_csv(args.input, index_col='id')

    rules = ['25%', '50%', '75%', '100%','125%']
    rule_vals = [float(r[:-1]) for r in rules]
    if show_ratio:
        suffix = compute_reduction_ratio(df, rules)
        reduction_cols = [rule + suffix for rule in rules]
        print(df)

    # set up plot
    figure, ax = plt.subplots(figsize=(4.6, 2))
    markers = 'oxs^v+*123'
    for i, case in enumerate(df.index):
        values = df.T.loc[reduction_cols][case].values * 100.0
        ax.plot(rule_vals, values, label=case, linewidth=1.5, marker=markers[i % len(markers)], 
                markersize=6, alpha=0.7)
    ax.set_xticks(rule_vals)
    ax.set_xticklabels(rules)
    ax.tick_params(axis='both', which='major', labelsize=10)
    # ax.set_yscale('log')
    ax.grid(axis='y', linestyle='--', zorder=0)
    ax.set_xlabel('Isolation Rule', fontsize=11)
    # ax.set_ylim(bottom=0)
    ax.yaxis.set_major_formatter(PercentFormatter())
    if show_ratio:
        ax.set_ylabel('Reduction ratio', fontsize=11)
    else:
        ax.set_ylabel('Median Latency(ms)', fontsize=11)
    ax.legend(loc='lower center', bbox_to_anchor=(0.4, -0.05), ncol=3, fontsize=9, frameon=False, columnspacing=0.5)

    # plt.tight_layout()
    if args.output:
        plt.savefig(args.output, bbox_inches='tight', pad_inches=0)
    plt.show()

if __name__ == '__main__':
    args = parser.parse_args()
    if not args.input:
        sys.stderr.write('Must specify input data file\n')
        sys.exit(1)
    plot(args)
