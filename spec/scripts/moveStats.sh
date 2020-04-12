#!/bin/bash

#$1 : base/peak
#$2 : config label
#$3 : destination directory
#$4 : action - copy or move
moveStats() {
    dest=${3:-stats}/$2/$1

    # TODO - make the grep pattern less SPEC-specific
    for file in $(find -name "*.stats" | grep "build_$1_$2-m")
    do
        temp=${file%%/build/*}
        benchmark=${temp##*/}
        mkdir -p "$dest/$benchmark"

        if [[ $4 == "cp" ]]; then
            name=$(basename -- "$file")
            cp $file "$dest/$benchmark/$name.stats"
        else
            mv $file "$dest/$benchmark/"
        fi
    done
}

moveStats "base" "clang" $1 $2
moveStats "peak" "clang" $1 $2

moveStats "base" "clang-unseq" $1 $2
moveStats "peak" "clang-unseq" $1 $2
