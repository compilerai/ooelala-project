#!/bin/python

import os
import sys
import argparse
import pandas as pd
from subprocess import check_output


def getParser():
    parser = argparse.ArgumentParser(
        description='Compare benchmark times between clang and clang-unseq')
    parser.add_argument('benchmarks', nargs='+',
                        help='Directories containing the benchmarks')
    parser.add_argument('--exclude', nargs='+', default=[],
                        help='Directories to exclude (./ may be needed')
    parser.add_argument('--runs', default=3,
                        help='Number of runs per benchmark')
    parser.add_argument('--compilers', nargs='+', default=[
                        'clang', 'clang-unseq', 'gcc', 'icc'], help='List of compilers to use')
    parser.add_argument('--csv', help='Dump .csv file containing differences')
    return parser


def getTimes(compilers, benchmark, runs):
    times = {}
    for compiler in compilers:
        command = ['./scripts/timeBenchmark.sh',
                   compiler, benchmark, str(runs)]
        times[compiler] = float(check_output(command).strip().split(':')[1])
    return times


def postProcess(df, dataCols):
    # taking dataCol[0] as base, get the diff and improvement
    base = dataCols[0]
    for i in xrange(1, len(dataCols)):
        col = dataCols[i]
        df['{} vs {}(x)'.format(col, base)] = df[base] / df[col]
    df.sort_values('{} vs {}(x)'.format(
        dataCols[1], base), ascending=False, inplace=True)


def Run(args):
    df = pd.DataFrame()

    for benchmarkDir in args['benchmarks']:
        for dirpath, dirs, files in os.walk(benchmarkDir):
            if dirpath in args['exclude']:
                continue
            for srcFile in files:
                if not srcFile.endswith('.c'):
                    continue
                print 'Running {}'.format(srcFile[:-2])
                row = getTimes(args['compilers'], dirpath,args['runs'])
                row['benchmark'] = srcFile[:-2]
                df = df.append(row, ignore_index=True)

    postProcess(df, args['compilers'])

    if args['csv']:
        df.to_csv('{}.csv'.format(args['csv']))
    else:
        print df


if __name__ == '__main__':
    args = vars(getParser().parse_args(sys.argv[1:]))
    Run(args)
