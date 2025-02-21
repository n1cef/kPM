#!/bin/bash

SOURCE_DIR="/sources"
REPO_URL="https://raw.githubusercontent.com/n1cef/kraken_repository"
 
 pkgname="$1"

 

 if [ -z "$1" ]; then
        echo "ERROR: You must specify a package name."
        exit 1
    fi

    
    pkgname="$1"
    echo "Package name is $pkgname"

    
    if [ ! -d "$SOURCE_DIR" ]; then
        echo "Creating source directory $SOURCE_DIR"
        mkdir -p "$SOURCE_DIR"
    fi

    if [ ! -d "$SOURCE_DIR/$pkgname" ]; then 
        echo "Creating /sources/$pkgname directory"
        mkdir -p "$SOURCE_DIR/$pkgname"
    fi

    
    pkgbuild_url="${REPO_URL}/refs/heads/main/pkgbuilds/$pkgname/pkgbuild.kraken"

    echo "Fetching PKGBUILD for $pkgname from repo..."
    wget -q -P "$SOURCE_DIR/$pkgname" "$pkgbuild_url"

    
    source_urls=($(awk '/^sources=\(/,/\)/' "$SOURCE_DIR/$pkgname/pkgbuild.kraken" | sed -e '1d;$d' -e 's/[",]//g' | xargs -n1))

    
    checksums=($(awk '/^md5sums=\(/,/\)/' "$SOURCE_DIR/$pkgname/pkgbuild.kraken" | sed -e '1d;$d' -e 's/[",]//g' | xargs -n1))

    echo "Extracted source entries:"
    for ((i=0; i<${#source_urls[@]}; i++)); do
        url="${source_urls[$i]}"
        echo "url $i is $url"
        checksum="${checksums[$i]}"
          echo "checksum  $i is $checksum"
        echo "Downloading source tarball from $url..."

        
        wget -q "$url" -P "$SOURCE_DIR/$pkgname"
        
        
        tarball_name=$(basename "$url")

        
        downloaded_checksum=$(md5sum "$SOURCE_DIR/$pkgname/$tarball_name" | awk '{print $1}')
           echo "md5sum fo this is $downloaded_checksum"
        echo "Checking checksum for $tarball_name..."

        
        if [ "$downloaded_checksum" != "$checksum" ]; then 
            echo "ERROR: Checksum verification failed for $tarball_name."
            exit 1
        else
            echo "Checksum verification successful for $tarball_name."
        fi
    done

