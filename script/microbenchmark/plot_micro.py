#!/usr/bin/env python

import sys
import os
import pandas as pd
from datetime import datetime
import matplotlib.pyplot as plt
import matplotlib.dates as mdates
from matplotlib.ticker import MultipleLocator, LogLocator
import numpy as np
import argparse
import matplotlib

matplotlib.rcParams['pdf.fonttype'] = 42
matplotlib.rcParams['ps.fonttype'] = 42
# matplotlib.rc('text', usetex=True)

parser = argparse.ArgumentParser()
parser.add_argument('-o', '--output', help="path to output image file")
parser.add_argument('input', help="path to input data file")

def format_label(label):
    if len(label) <= 8:
        return label
    return label[:7] + '..'

def plot(args):
    # parse data from CSV
    df = pd.read_csv(args.input)

    figure, ax = plt.subplots(figsize=(4.6, 2))

    ind = np.arange(len(df))
    width = 0.35
    bar = ax.bar(ind, df['latency'].values, width, color='#66a61e')
    ax.set_ylim(bottom=10)
    ax.set_yscale('log')
    ax.yaxis.set_major_locator(LogLocator(base=10, numticks=8))
    ax.yaxis.set_minor_locator(LogLocator(base=10, subs=(0.2,0.4,0.6,0.8), numticks=8))
    ax.yaxis.set_minor_formatter(matplotlib.ticker.NullFormatter())
    ax.set_ylabel('Latency (ns)')
    for p in bar:
        height = p.get_height()
        ax.text(p.get_x() + p.get_width() / 2., 1.05 * height, '%d' % round(height),
                ha='center', va='bottom')
    bar[-2].set_color('#e6ab02')
    bar[-1].set_color('#e6ab02')
    abbrev_labels = [ format_label(x) for x in df['operation'].values]
    ax.set_xticks(ind)
    ax.set_xticklabels(abbrev_labels, rotation=25)

    figure.tight_layout()
    if args.output:
        figure.savefig(args.output, bbox_inches='tight', pad_inches=0)
    plt.show()

if __name__ == '__main__':
    args = parser.parse_args()
    if not args.input:
        sys.stderr.write('Must specify input data file\n')
        sys.exit(1)
    plot(args)
