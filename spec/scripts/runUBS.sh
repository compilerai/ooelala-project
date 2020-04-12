#!/bin/bash

#$1 : benchmark (or suite)
#$2 : clean or not
runSPEC() {
    if [[ $2 == "clean" ]]; then
        runcpu --config=clang-ubsan --action=realclean $1
        runcpu --config=clang-unseq-ubsan --action=realclean $1
    fi

    runcpu --config=clang-ubsan --action=run --tune=base --copies=1 --iterations=1 $1
    runcpu --config=clang-unseq-ubsan --action=run --tune=base --copies=1 --iterations=1 $1
}

source shrc
runSPEC "intrate" $1
runSPEC "fprate" $1
