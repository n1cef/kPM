#!/bin/bash


SOURCE_DIR="/sources"
REPO_URL="https://raw.githubusercontent.com/n1cef/kraken_repository"
 



pkgname="$1"
pkgver=$(awk -F '=' '/^pkgver=/ {print $2}' "$SOURCE_DIR/$pkgname/pkgbuild.kraken")
echo "Package version is: $pkgver"


    kraken_build_content=$(awk '/^kraken_build\(\) {/,/^}/' "$SOURCE_DIR/$pkgname/pkgbuild.kraken")
   echo "prepare contetnt is $kraken_build_content"
    
    eval "$kraken_build_content"
   
    if ! declare -f kraken_build > /dev/null; then
        echo "ERROR: Failed to load kraken_build function."
        exit 1
    fi

    
    if ! kraken_build; then
        echo "ERROR: Failed to execute kraken_build for package $pkgname."
        exit 1
    fi

       echo "kraken_build executed successfully for package $pkgname."
    exit 0






