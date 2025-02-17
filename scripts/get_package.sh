#!/bin/bash
# Define the source directory
SOURCE_DIR="/sources"
REPO_URL="https://raw.githubusercontent.com/n1cef/kraken_repository"
 
 pkgname="$1"

    # Ensure the user provided a package name
    if [ -z "$1" ]; then
        echo "ERROR: You must specify a package name."
        exit 1
    fi

    # Package name passed by user
    pkgname="$1"
    echo "Package name is $pkgname"

    # Check if the source directory exists, create if it doesn't
    if [ ! -d "$SOURCE_DIR" ]; then
        echo "Creating source directory $SOURCE_DIR"
        mkdir -p "$SOURCE_DIR"
    fi

    if [ ! -d "$SOURCE_DIR/$pkgname" ]; then 
        echo "Creating /sources/$pkgname directory"
        mkdir -p "$SOURCE_DIR/$pkgname"
    fi

    # Search the repository for the PKGBUILD file corresponding to the package
    pkgbuild_url="${REPO_URL}/refs/heads/main/pkgbuilds/$pkgname/pkgbuild.kraken"

    echo "Fetching PKGBUILD for $pkgname from repo..."
    wget -q -P "$SOURCE_DIR/$pkgname" "$pkgbuild_url"

    # Extract source URLs from the PKGBUILD
    source_urls=($(awk '/^sources=\(/,/\)/' "$SOURCE_DIR/$pkgname/pkgbuild.kraken" | sed -e '1d;$d' -e 's/[",]//g' | xargs -n1))

    # Extract sha1sums from the PKGBUILD
    checksums=($(awk '/^md5sums=\(/,/\)/' "$SOURCE_DIR/$pkgname/pkgbuild.kraken" | sed -e '1d;$d' -e 's/[",]//g' | xargs -n1))

    echo "Extracted source entries:"
    for ((i=0; i<${#source_urls[@]}; i++)); do
        url="${source_urls[$i]}"
        echo "url $i is $url"
        checksum="${checksums[$i]}"
          echo "checksum  $i is $checksum"
        echo "Downloading source tarball from $url..."

        # Download the source tarball
        wget -q "$url" -P "$SOURCE_DIR/$pkgname"
        
        # Get the filename of the downloaded tarball
        tarball_name=$(basename "$url")

        # Calculate the checksum of the downloaded tarball
        downloaded_checksum=$(md5sum "$SOURCE_DIR/$pkgname/$tarball_name" | awk '{print $1}')
           echo "md5sum fo this is $downloaded_checksum"
        echo "Checking checksum for $tarball_name..."

        # Check if the downloaded checksum matches the expected checksum
        if [ "$downloaded_checksum" != "$checksum" ]; then 
            echo "ERROR: Checksum verification failed for $tarball_name."
            exit 1
        else
            echo "Checksum verification successful for $tarball_name."
        fi
    done

