#!/bin/bash

#$1 : benchmark (or suite)
#$2 : clean or not
runSPEC() {
    if [[ $2 == "clean" ]]; then
        runcpu --config=clang --action=realclean $1
        runcpu --config=clang-unseq --action=realclean $1
    fi

    runcpu --config=clang --action=run --tune=base --copies=1 --iterations=3 $1
    runcpu --config=clang-unseq --action=run --tune=base --copies=1 --iterations=3 $1
}

source shrc
runSPEC "intrate" $1
runSPEC "fprate" $1
