#!/bin/bash

SOURCES=(selected_benchmarks)

#$1 : clang-unseq or not
#$2 : destination directory
getStats() {
    for benchmark in $(find ${SOURCES[@]} -name "*.c");
    do
        benchmark=${benchmark%.c}
        if [[ $1 == "clang-unseq" ]]; then
            benchmark=${benchmark}-unseq
        fi

        make $benchmark-clean
        
        polyb="-Wno-unknown-pragmas -DPOLYBENCH_TIME"
        if [[ $4 == "restrict" ]] && [[ $1 != "clang-unseq" ]]; then
            polyb+=" -DPOLYBENCH_USE_RESTRICT"
        fi

        make $benchmark.stats POLYBFLAGS="$polyb"
    done

    dest=${2:-stats}/$1
    mkdir -p $dest
    mv *.stats $dest/
}

getStats "clang" $1 
getStats "clang-unseq" $1
