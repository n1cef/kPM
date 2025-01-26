#!/bin/bash
# Define the source directory
SOURCE_DIR="/sources"
REPO_URL="https://raw.githubusercontent.com/n1cef/kraken"
 


  
pkgname="$1"
pkgver=$(awk -F '=' '/^pkgver=/ {print $2}' "$SOURCE_DIR/$pkgname/pkgbuild.kraken")
echo "Package version is: $pkgver"


    kraken_postinstall_content=$(awk '/^kraken_postinstall\(\) {/,/^}/' "$SOURCE_DIR/$pkgname/pkgbuild.kraken")
   echo "prepare contetnt is $kraken_postinstall_content"
    
    eval "$kraken_postinstall_content"
    # Ensure the function is loaded in the shell
    if ! declare -f kraken_postinstall > /dev/null; then
        echo "ERROR: Failed to load kraken_postinstall function."
        return 1
    fi

    # Execute the kraken_prepare function
    if ! kraken_postinstall; then
        echo "ERROR: Failed to execute kraken_postinstall for package $pkgname."
        return 1
    fi

       echo "kraken_postinstall executed successfully for package $pkgname."
    return 0



