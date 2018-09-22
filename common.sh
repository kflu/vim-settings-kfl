#!/bin/sh
source_rc() {
    dir="$1"
    pattern="$2"
    printf "sourcing $dir/$pattern\n"
    find "$dir" -type f -name "$pattern" | while read fn
    do 
        printf "sourcing $fn" 
        source $fn
    done
}
