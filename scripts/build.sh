#!/bin/bash

# Define the source directory
SOURCE_DIR="/sources"
REPO_URL="https://raw.githubusercontent.com/n1cef/kraken_repository"
 



pkgname="$1"
pkgver=$(awk -F '=' '/^pkgver=/ {print $2}' "$SOURCE_DIR/$pkgname/pkgbuild.kraken")
echo "Package version is: $pkgver"


    kraken_build_content=$(awk '/^kraken_build\(\) {/,/^}/' "$SOURCE_DIR/$pkgname/pkgbuild.kraken")
   echo "prepare contetnt is $kraken_build_content"
    
    eval "$kraken_build_content"
    # Ensure the function is loaded in the shell
    if ! declare -f kraken_build > /dev/null; then
        echo "ERROR: Failed to load kraken_build function."
        return 1
    fi

    # Execute the kraken_prepare function
    if ! kraken_build; then
        echo "ERROR: Failed to execute kraken_build for package $pkgname."
        return 1
    fi

       echo "kraken_build executed successfully for package $pkgname."
    return 0






