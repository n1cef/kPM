#!/bin/bash

SOURCE_DIR="/sources"
REPO_URL="https://raw.githubusercontent.com/n1cef/kraken_repository"




pkgname="$1"
pkgver=$(awk -F '=' '/^pkgver=/ {print $2}' "$SOURCE_DIR/$pkgname/pkgbuild.kraken")
echo "Package version is: $pkgver"

metadata_dir="/var/lib/kraken/packages"

if [ ! -d "$metadata_dir" ]; then 
 echo "creating $metadata_dir"
 mkdir -p  "/var/lib/kraken/"
 mkdir -p "$metadata_dir"
 fi

 #if [ ! -f "$metadata_file" ]; then 
 #echo "creating $metadata_file"
  # touch  "$metadata_file"
 #fi
 
  

    source "/kraken/scripts/fake_install.sh"
    if !fake_inst "$pkgname"; then
    echo "error in  fake install "
    exit 1
        
    else
        echo "fake instal complete for the packge $pkgname"
        
   


        kraken_install_content=$(awk '/^kraken_install\(\) {/,/^}/' "$SOURCE_DIR/$pkgname/pkgbuild.kraken")
            echo "prepare contetnt is $kraken_install_content"
    
        eval "$kraken_install_content"
        
        if ! declare -f kraken_install > /dev/null; then
            echo "ERROR: Failed to load kraken_install function."
            exit 1
        fi

        
        if ! kraken_install ; then
            echo "ERROR: Failed to execute kraken_install for package $pkgname."
            exit 1
        fi

        echo "kraken_install executed successfully for package $pkgname. "
    


    fi





