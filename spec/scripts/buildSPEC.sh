#!/bin/bash

#$1 : benchmark (or suite)
#$2 : clean or not
buildGetStats() {
    currTime=$(date +%s)

    if [[ $2 == "clean" ]]; then
        runcpu --config=clang --action=realclean $1
        runcpu --config=clang-unseq --action=realclean $1
    fi

    runcpu --config=clang --action=build --rebuild --tune=base $1
    runcpu --config=clang-unseq --action=build --rebuild --tune=base $1
    mkdir $1_$currTime
    ./moveStats.sh $1_$currTime
}

source shrc
buildGetStats "intrate" $1
buildGetStats "fprate" $1
