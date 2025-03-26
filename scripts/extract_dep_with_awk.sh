#!/bin/bash





pkgname="$1"


SOURCE_DIR="$2"

if [[ ! -f "$SOURCE_DIR/$pkgname/pkgbuild.kraken" ]]; then

       

        exit 1

    fi


deps=($(awk '/^dependencies=\(/,/\)/' "$SOURCE_DIR/$pkgname/pkgbuild.kraken" | sed -e '1d;$d' -e 's/[",]//g' | xargs -n1))

if [[ ${#deps[@]} -eq 0 ]]; then

        

        exit 1

    fi

 
 for dep in "${deps[@]}"; do

        echo "$dep"

    done




