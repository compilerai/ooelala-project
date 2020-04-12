#!/bin/python

import os
import sys
import json
import argparse
import pandas as pd
from collections import defaultdict

aliasStats = {'aa-eval.MAY_ALIAS_COUNT': 'additional may-alias responses',         
              'aa-eval.MUST_ALIAS_COUNT': 'additional must-alias responses',       
              'aa-eval.NO_ALIAS_COUNT': 'additional must-not-alias responses',     
              'aa-eval.PARTIAL_ALIAS_COUNT': 'additional partial-alias responses'  
              }                                                                    
                                                                                   
predStats = {'unseq.FULL_EXPRS': '# initial full exprs unseq. s.e',                
             'unseq.NUM_PREDICATES': '# initial preds',                            
             'unseq.NUM_FUNC_PREDS' : '# preds w/ calls',                     
             'aa-eval.NUM_REAL_PREDICATES': '# final preds',                       
             'aa-eval.NUM_UNIQUE_PREDICATES': '# unique final preds',              
             'aa-eval.NUM_UNIQUE_USEFUL_PREDICATES': '# useful preds'              
             }                                                                     


def getParser():
    parser = argparse.ArgumentParser(
        description='Compare alias stats between clang and clang-unseq')
    parser.add_argument(
        'normal', help='Directory containing the stats generated without Unsequenced AA')
    parser.add_argument(
        'unseq', help='Directory containing the stats generated with Unsequenced AA')
    parser.add_argument(
        '--csv', help='Dump .csv file containing differences')
    return parser


def compare(normalStatsFile, unseqStatsFile, stats):
    with open(normalStatsFile) as normalStatsF, open(unseqStatsFile) as unseqStatsF:
        try:
            normalStats = json.load(normalStatsF)
        except:
            print '{} is not a JSON'.format(normalStatsFile)
            return {}

        try:
            unseqStats = json.load(unseqStatsF)
        except:
            print '{} is not a JSON'.format(unseqStatsFile)
            return {}

        statsDiff = defaultdict(object)
        totalAAQueries, totalAAQueriesUnseq = 0, 0
        for stat in stats:
            if stat in predStats:
                statsDiff[predStats[stat]] = unseqStats.get(
                    stat, 0) - normalStats.get(stat, 0)
            elif stat in aliasStats:
                totalAAQueries += normalStats.get(stat, 0)
                totalAAQueriesUnseq += unseqStats.get(stat, 0)
                statsDiff[aliasStats[stat]] = unseqStats.get(
                    stat, 0) - normalStats.get(stat, 0)
                if normalStats.get(stat, 0):
                    statsDiff['Increase in {}(%)'.format(aliasStats[stat])] = round(
                        (statsDiff[aliasStats[stat]] * 100.0) / normalStats.get(stat, 0), 3)
        statsDiff['Total AA Queries'] = totalAAQueries
        statsDiff['Total AA Queries w/ Unseq'] = totalAAQueriesUnseq
        return statsDiff


def postProcess(df, index='Filename', sort_on=['additional must-not-alias responses']):
    # drop columns with all NAs, replace rest with 0s
    df.dropna(axis=1, how='all', inplace=True)
    df.fillna(0, inplace=True)

    # remove duplicates (like base-peak in SPEC)
    df.drop_duplicates(keep='first', inplace=True)

    # index by filename, sort descending no alias values
    df.set_index(index, inplace=True)
    df.sort_values(sort_on, ascending=False, inplace=True)


def summarise(df, group=['Benchmark'], sort_on=['additional must-not-alias responses']):
    return df.groupby('Benchmark').sum().sort_values(sort_on, ascending=False)


def Run(args):
    df = pd.DataFrame(columns=predStats.values() + aliasStats.values())

    for dirpath, dirs, files in os.walk(args['unseq']):
        for filename in files:
            if not(filename.endswith('.stats')):
                continue

            # get the full filenames
            unseqStatsFile = os.path.join(dirpath, filename)
            normalStatsFile = unseqStatsFile.replace('clang-unseq', 'clang')
            if not(os.path.isfile(normalStatsFile)):
                print('clang did not generate {}'.format(filename))
                continue

            statsDiff = compare(
                normalStatsFile, unseqStatsFile, predStats.keys() + aliasStats.keys())

            if any(statsDiff.values()):
                # add aditional information about files
                dirpathParts = dirpath.split('/')
                statsDiff['Filename'] = filename
                statsDiff['Benchmark'] = dirpathParts[-1]

                df = df.append(statsDiff, ignore_index=True)

    postProcess(df)
    summary = summarise(df)

    if args['csv']:
        df.to_csv('{}.csv'.format(args['csv']))
        summary.to_csv('{}_summary.csv'.format(args['csv']))
    else:
        print df


if __name__ == '__main__':
    args = vars(getParser().parse_args(sys.argv[1:]))
    Run(args)
