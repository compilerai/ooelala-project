#!/bin/bash

#$1 : compiler
#$2 : benchmark directory
#$3 : number of runs
#$4 : rebuild or not
getTime() {
    if [[ $1 == "clang-unseq" ]]; then
        suffix="-unseq"
    fi

    benchmark=${2##*/}
    bin=$2/${benchmark}${suffix}

    if [[ $4 == "clean" ]]; then
        make -s $bin-clean
    fi

    polyb="-Wno-unknown-pragmas -DPOLYBENCH_TIME"

    if [[ $1 == "clang" ]] || [[ $1 == "clang-unseq" ]]; then 
        opt="-O3"
        make -s $bin OPT_FLAGS="$opt" POLYBFLAGS="$polyb"
    else 
        make -s $bin COMP=$1 POLYBFLAGS="$polyb"
    fi

    runtimes=()
    for i in $(seq 1 $3); do
        runtimes+=($(./$bin));
    done
    sorted=$(printf '%s\n' "${runtimes[@]}" | sort -n)
    midIdx=$(($3 / 2 + 1))
    echo $(echo $sorted | cut -d" " -f$midIdx)
}

echo "$1 : $(getTime $1 $2 $3 clean)"
