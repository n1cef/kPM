#!/bin/bash

SOURCE_DIR="/sources"
REPO_URL="https://raw.githubusercontent.com/n1cef/kraken_repository"
 


  
pkgname="$1"
pkgver=$(awk -F '=' '/^pkgver=/ {print $2}' "$SOURCE_DIR/$pkgname/pkgbuild.kraken")
echo "Package version is: $pkgver"


    kraken_postinstall_content=$(awk '/^kraken_postinstall\(\) {/,/^}/' "$SOURCE_DIR/$pkgname/pkgbuild.kraken")
   echo "prepare contetnt is $kraken_postinstall_content"
    
    eval "$kraken_postinstall_content"
    
    if ! declare -f kraken_postinstall > /dev/null; then
        echo "ERROR: Failed to load kraken_postinstall function."
        exit 1
    fi

    
    if ! kraken_postinstall; then
        echo "ERROR: Failed to execute kraken_postinstall for package $pkgname."
        exit 1
    fi

       echo "kraken_postinstall executed successfully for package $pkgname."
    exit 0



