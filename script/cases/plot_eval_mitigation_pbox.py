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
parser.add_argument('--metric', choices=['average', 'tail_99'], 
        default='average', help='the performance metric to use')
parser.add_argument('input', help="path to input data file")

def hatch_bar(ax, df, skip=0):
    bars = ax.patches
    hatches = '/\\-x.+/o'
    hatch_repeats = 4 
    all_hatches = []
    n = len(df)
    for h in hatches:
        all_hatches.extend([h * hatch_repeats] * n)
    skip_left = n * skip
    skip_right = n * (skip + 1)
    i = 0
    for bar, hatch in zip(bars, all_hatches):
        if skip < 0 or i < skip_left or i >= skip_right:
            bar.set_hatch(hatch)
        i = i + 1

def plot(args, relative=False, ratio_only=False, show_normal=True, large=True):
    # parse data from CSV
    df = pd.read_csv(args.input)
    df = df.sort_values(by=['id'], ascending=True)
    print(df)
    normal = df["w/o interference(ms)"]
    interference = df["with interference(ms)"]
    psandbox = df["pbox(ms)"]
    cgroup = df["cgroup(ms)"]
    # parties = df["parties(ms)"]
    # parties_normal = df["parties(w/o interference)"]
    # parties_interference = df["parties(with interference)"]
    # psp = df["psp(ms)"]
    # psp_normal = df["psp(w/o interference)"]
    # psp_interference = df["psp(with interference)"]
    # retro = df["retro(ms)"]
    # retro_normal = df["retro(w/o interference)"]
    # retro_interference = df["retro(with interference)"]

    # set up plot
    width = 0.15
    if large:
        figure, ax = plt.subplots(figsize=(10, 3))
    else:
        figure, ax = plt.subplots(figsize=(12.5, 2.6))

    if relative:
        normal = normal / interference
        psandbox = psandbox / interference
        cgroup = cgroup / interference
        # parties = parties / parties_interference
        # retro = retro/retro_interference
        # psp = psp /psp_interference
        interference = interference / interference

    series = [normal, interference, psandbox, cgroup]
    labels = ['w/o interference', 'w/ interference', 'pbox', 'cgroup']
    colors = ['#a6dc80', '#c00000', '#ffc433', '#98c8df']
    if not show_normal:
        del series[0]
        del labels[0]
        del colors[0]
    indices = [np.arange(len(df))]

    for i in range(0, len(series)):
        bars = ax.bar(indices[i], series[i], width, bottom=0, label=labels[i], 
                color=colors[i], zorder=3)
        indices.append([x + width for x in indices[i]])
    ax.set_xticks(indices[0] + 2.5 * width)
    ax.set_xticklabels(df["Name"].values, rotation=0)

    hatch_bar(ax, psandbox)
    if not relative and not ratio_only:
        ax.set_yticks(np.arange(0, 1.1, 0.2))
        ax.set_yscale('log')
    ax.set_xlim(-0.1, len(df)-0.1)
    ax.legend(loc='lower center', bbox_to_anchor=(0.7, 0.65), frameon=True, edgecolor='black', fontsize=10, ncol=3)
    if relative:
        ax.set_ylabel("Avg. latency (norm.)", fontsize=11)
        ax.yaxis.set_major_locator(MultipleLocator(1.0))
    else:
        ax.set_ylabel("Latency (ms)", fontsize=11)
    ax.set_xlabel("Case", fontsize=11)
    ax.grid(axis='y', linestyle='--', lw=0.3, zorder=0)

    for tick in ax.get_xticklabels():
        tick.set_rotation(0)
    plt.tight_layout()
    if args.output:
        plt.savefig(args.output, bbox_inches='tight', pad_inches=0)
    plt.show()

if __name__ == '__main__':
    args = parser.parse_args()
    if not args.input:
        sys.stderr.write('Must specify input data file\n')
        sys.exit(1)
    plot(args, relative=True, show_normal=False, large=False)
