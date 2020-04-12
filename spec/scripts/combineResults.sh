#!/bin/bash
# $1 : intrate results file
# $2 : fprate results file
# $3 : number of runs
# $4 : output file name

intrate=( 500.perlbench_r 502.gcc_r 505.mcf_r 525.x264_r 557.xz_r )
fprate=( 519.lbm_r 538.imagick_r 544.nab_r )
prod=1

runs=$(($3 + 1))
echo "benchmark, time, score" > $4

for benchmark in "${intrate[@]}"; do
    row=$(less $1 | grep -m$runs $benchmark | tail -n1)
    time=$(echo $row | cut -d, -f3)
    score=$(echo $row | cut -d, -f4)
    echo "$benchmark, $time, $score" >> $4
    prod=$(echo $(awk "BEGIN {print $prod * $score}"));
done;

for benchmark in "${fprate[@]}"; do
    row=$(less $2 | grep -m$runs $benchmark | tail -n1)
    time=$(echo $row | cut -d, -f3)
    score=$(echo $row | cut -d, -f4)
    echo "$benchmark, $time, $score" >> $4
    prod=$(echo $(awk "BEGIN {print $prod * $score}"));
done;

echo $(awk "BEGIN {print $prod ** (1.0/8)}")
