#!/bin/bash

# Define the source directory
SOURCE_DIR="/sources"
REPO_URL="https://raw.githubusercontent.com/n1cef/kraken_repository"

 



pkgname="$1"
pkgver=$(awk -F '=' '/^pkgver=/ {print $2}' "$SOURCE_DIR/$pkgname/pkgbuild.kraken")
echo "Package version is: $pkgver"


    kraken_prepare_content=$(awk '/^kraken_prepare\(\) {/,/^}/' "$SOURCE_DIR/$pkgname/pkgbuild.kraken")
   echo "prepare contetnt is $kraken_prepare_content"
    
    eval "$kraken_prepare_content"
    # Ensure the function is loaded in the shell
    if ! declare -f kraken_prepare > /dev/null; then
        echo "ERROR: Failed to load kraken_prepare function."
        return 1
    fi

    # Execute the kraken_prepare function
    if ! kraken_prepare; then
        echo "ERROR: Failed to execute kraken_prepare for package $pkgname."
        return 1
    fi

       echo "kraken_prepare executed successfully for package $pkgname."
    return 0








