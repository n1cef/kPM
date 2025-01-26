#!/bin/bash





pkgname="$1"


SOURCE_DIR="$2"

if [[ ! -f "$SOURCE_DIR/$pkgname/pkgbuild.kraken" ]]; then

        echo "File not found: $SOURCE_DIR/$pkgname/pkgbuild.kraken" >&2

        return 1

    fi


deps=($(awk '/^dependencies=\(/,/\)/' "$SOURCE_DIR/$pkgname/pkgbuild.kraken" | sed -e '1d;$d' -e 's/[",]//g' | xargs -n1))
echo $dep
if [[ ${#deps[@]} -eq 0 ]]; then

        echo "No dependencies found for package: $pkgname"

        return 1

    fi

 
 for dep in "${deps[@]}"; do

        echo "$dep"

    done




