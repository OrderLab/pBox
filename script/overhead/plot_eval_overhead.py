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
parser.add_argument('--name', help='the name of the software')
parser.add_argument('input', help="path to input data file")
def hatch_bar(ax, df):
    bars = ax.patches
    hatches = '-\\/.-+o'
    hatch_repeats = 4 
    all_hatches = []
    for h in hatches:
        all_hatches.extend([h * hatch_repeats] * len(df))
    for bar, hatch in zip(bars, all_hatches):
        bar.set_hatch(hatch)

def plot(args, show_ratio=True, show_relative=False):
    # parse data from CSV
    df = pd.read_csv(args.input)
    vanilla = df["w/o psandbox(average)"]
    psandbox = df["psandbox(average)"]
    overhead = (psandbox - vanilla) / vanilla
    apps = ['MySQL', 'PostgreSQL', 'Apache', 'Varnish', 'Memcached']
    setting = df['setting'][df['app'] == apps[0]]

    # set up plot
    width = 0.4
    figure, ax = plt.subplots(figsize=(4.6, 2))
    ind = np.arange(len(setting))
    markers = 'oxs^v+*'
    if show_ratio:
        for i, app in enumerate(apps):
            values = overhead[df['app'] == app].values * 100.0
            print(values)
            print("Average overhead for '%s': %.2f%%" % (app, values.mean()))
            marker = markers[i % len(markers)]
            ax.plot(ind[:len(values)], values, label=app, linewidth=2, 
                    marker=marker, markersize=6)
        ax.set_ylim(-15, 15)
        ax.yaxis.set_major_locator(MultipleLocator(5))
        ax.yaxis.set_major_formatter(PercentFormatter())
        ax.set_ylabel("Overhead")
        ax.legend(loc='lower center', bbox_to_anchor=(0.5, 0.92), 
                frameon=False, columnspacing=1, fontsize=9, ncol=3)
        ax.set_xticks(ind)
        ax.grid(axis='y', linestyle='--', lw=0.3, zorder=0)
    else:
        ind2 = [x + width for x in ind]
        vanilla_bars = ax.bar(ind, vanilla, width - 0.03, bottom=0, label='Vanilla', color='#a6dc80')
        psandbox_bars = ax.bar(ind2, psandbox, width - 0.03, bottom=0, label='pSandboxs', color='#98c8df')
        hatch_bar(ax, psandbox)
        ax.set_yticks(np.arange(0, 1.1, 0.2))
        ax.set_yscale('log')
        ax.set_ylabel("Latency (ms)")
        ax.legend(loc='lower left', bbox_to_anchor=(0., 0.92), frameon=False, fontsize=9, ncol=3)
        ax.set_xticks(ind + 0.5 * width)
    ax.set_xlabel('Setting')
    ax.set_xticklabels(setting.values, rotation=0)
    # ax.set_ylim(0, 1.1)
    # ax.set_xlabel(args.name)
    plt.tight_layout()
    if args.output:
        plt.savefig(args.output, bbox_inches='tight', pad_inches=0)
    plt.show()

if __name__ == '__main__':
    args = parser.parse_args()
    if not args.input:
        sys.stderr.write('Must specify input data file\n')
        sys.exit(1)
    plot(args)
