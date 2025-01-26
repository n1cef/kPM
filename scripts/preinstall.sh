#!/bin/bash

# Define the source directory
SOURCE_DIR="/sources"
REPO_URL="https://raw.githubusercontent.com/n1cef/kraken"


  
    

pkgname="$1"
kraken_preinstall_content=$(awk '/^kraken_preinstall\(\) {/,/^}/' "$SOURCE_DIR/$pkgname/pkgbuild.kraken")
   echo "prepare contetnt is $kraken_preinstall_content"
    
    eval "$kraken_preinstall_content"
    # Ensure the function is loaded in the shell
    if ! declare -f kraken_preinstall > /dev/null; then
        echo "ERROR: Failed to load kraken_preinstall function."
        return 1
    fi

    # Execute the kraken_prepare function
    if ! kraken_preinstall; then
        echo "ERROR: Failed to execute kraken_preinstall for package $pkgname."
        return 1
    fi

       echo "kraken_preinstall executed successfully for package $pkgname. "
    return 0
