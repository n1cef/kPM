#!/bin/bash


SOURCE_DIR="/sources"
REPO_URL="https://raw.githubusercontent.com/n1cef/kraken_repository"

 



pkgname="$1"
pkgver=$(awk -F '=' '/^pkgver=/ {print $2}' "$SOURCE_DIR/$pkgname/pkgbuild.kraken")
echo "Package version is: $pkgver"


    kraken_prepare_content=$(awk '/^kraken_prepare\(\) {/,/^}/' "$SOURCE_DIR/$pkgname/pkgbuild.kraken")
   echo "prepare contetnt is $kraken_prepare_content"
    
    eval "$kraken_prepare_content"
    
    if ! declare -f kraken_prepare > /dev/null; then
        echo "ERROR: Failed to load kraken_prepare function."
        exit 1
    fi

    
    if ! kraken_prepare; then
        echo "ERROR: Failed to execute kraken_prepare for package $pkgname."
        exit 1
    fi

       echo "kraken_prepare executed successfully for package $pkgname."
    exit 0








