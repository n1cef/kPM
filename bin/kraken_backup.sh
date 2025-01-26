#!/bin/bash

# Define the source directory
SOURCE_DIR="/sources"
REPO_URL="https://raw.githubusercontent.com/n1cef/kraken"
 pkgname="$1"

# Function to download the package
get_package() {
    # Ensure the user provided a package name
    if [ -z "$1" ]; then
        echo "ERROR: You must specify a package name."
        return 1
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
    pkgbuild_url="${REPO_URL}/refs/heads/master/pkgbuilds/$pkgname/pkgbuild.kraken"

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
            return 1
        else
            echo "Checksum verification successful for $tarball_name."
        fi
    done
}



checkdeps(){

pkgname="$1"
deps=($(awk '/^dependencies=\(/,/\)/' "$SOURCE_DIR/$pkgname/pkgbuild.kraken" | sed -e '1d;$d' -e 's/[",]//g' | xargs -n1))
for ((i=0;i<${#deps[@]};i++)); do 
  dep=${deps[$i]}
  echo "dep $i is $dep"
done  
}

prepare(){


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








}

build(){

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





}


postinstall (){
  
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



}



preinstall (){
    pkgname="$1"
    

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
}

test(){

  pkgname="$1"
pkgver=$(awk -F '=' '/^pkgver=/ {print $2}' "$SOURCE_DIR/$pkgname/pkgbuild.kraken")
echo "Package version is: $pkgver"


    kraken_test_content=$(awk '/^kraken_test\(\) {/,/^}/' "$SOURCE_DIR/$pkgname/pkgbuild.kraken")
   echo "prepare contetnt is $kraken_test_content"
    
    eval "$kraken_test_content"
    # Ensure the function is loaded in the shell
    if ! declare -f kraken_test > /dev/null; then
        echo "ERROR: Failed to load kraken_test function."
        return 1
    fi

    # Execute the kraken_prepare function
    if ! kraken_test; then
        echo "ERROR: Failed to execute kraken_test for package $pkgname."
        return 1
    fi

       echo "kraken_test executed successfully for package $pkgname."
    return 0









}








dir_filtring() {
    pkgname="$1"
    pkgver=$(awk -F '=' '/^pkgver=/ {print $2}' "$SOURCE_DIR/$pkgname/pkgbuild.kraken")
    echo "Package version is: $pkgver"

    metadata_dir="/var/lib/kraken/packages"

    # Input metadata file
    input_file="${metadata_dir}/${pkgname}-${pkgver}/DIRS"

    # Ensure input file exists
    if [ ! -f "$input_file" ]; then
        echo "Error: $input_file does not exist."
        return 1
    fi

    # Temporary file to store filtered output
    temp_file=$(mktemp) || { echo "Error: Unable to create temporary file."; return 1; }

    # Define protected paths
    protected_paths=(
        "/usr/bin"
        "/usr/lib"
        "/usr/share"
        "/usr/share/doc"
        "/usr/share/info"
        "/usr/share/man"
        "/usr/share/locale"
    )

# Loop through each line in the input file
    while IFS= read -r line; do
        # Check if the line matches any protected path
        match=0
        for protected_path in "${protected_paths[@]}"; do
            if [ "$line" == "$protected_path" ]; then
                match=1
                break
            fi
        done

        # If no match, write the line to the temporary file
        if [ $match -eq 0 ]; then
        echo "$line is fine "
            echo "$line" >> "$temp_file"
        fi
    done < "$input_file"
      echo "temp file is "
      cat "$temp_file"
    # If the filtering was successful, replace the original file
    if [ $? -eq 0 ]; then
        mv "$temp_file" "$input_file"
        echo "Filtered metadata saved to $input_file"
        
    else
        echo "Error: Failed to filter the directory list."
        rm -f "$temp_file"
        
    fi



}
fake_inst() {
    pkgname="$1"
    pkgver=$(awk -F '=' '/^pkgver=/ {print $2}' "$SOURCE_DIR/$pkgname/pkgbuild.kraken")
    echo "Package version is: $pkgver"

    metadata_dir="/var/lib/kraken/packages"

    # Extract the kraken_install function's content
    kraken_install_content=$(awk '/^kraken_install\(\) {/,/^}/' "$SOURCE_DIR/$pkgname/pkgbuild.kraken")
    echo "Original kraken_install content:"
    echo "$kraken_install_content"

    # Replace make install and ninja install with their DESTDIR=/tmp equivalents
    kraken_install_content=$(echo "$kraken_install_content" | sed -E \
        -e "s/\bmake install\b/make DESTDIR=\/tmp\/${pkgname}-${pkgver} install/" \
        -e "s/\bninja install\b/ninja install DESTDIR=\/tmp\/${pkgname}-${pkgver}/")
    echo "Modified kraken_install content:"
    echo "$kraken_install_content"

    # Evaluate the modified kraken_install function
    eval "$kraken_install_content"

    if ! kraken_install; then
        echo "ERROR: Failed to execute kraken_install for package $pkgname."
        return 1
    fi

    # Create metadata files if not exist
    [ ! -f "${metadata_dir}/${pkgname}-${pkgver}/FILES" ] && mkdir -p "${metadata_dir}/${pkgname}-${pkgver}" && touch "${metadata_dir}/${pkgname}-${pkgver}/FILES"
    [ ! -f "${metadata_dir}/${pkgname}-${pkgver}/DIRS" ] && mkdir -p "${metadata_dir}/${pkgname}-${pkgver}" && touch "${metadata_dir}/${pkgname}-${pkgver}/DIRS"

    # Capture files and directories
    find "/tmp/${pkgname}-${pkgver}" -type f > "${metadata_dir}/${pkgname}-${pkgver}/FILES"
    find "/tmp/${pkgname}-${pkgver}" -type d > "${metadata_dir}/${pkgname}-${pkgver}/DIRS"

    # Remove temporary prefix
    sed -i "s|^/tmp/${pkgname}-${pkgver}||" "${metadata_dir}/${pkgname}-${pkgver}/FILES"
    sed -i "s|^/tmp/${pkgname}-${pkgver}||" "${metadata_dir}/${pkgname}-${pkgver}/DIRS"

    cp "$SOURCE_DIR/$pkgname/pkgbuild.kraken" "${metadata_dir}/${pkgname}-${pkgver}/pkgbuild.kraken"

    # Call dir_filtring to validate the directories
    if ! dir_filtring "$pkgname"; then
        echo "Please review and edit /var/lib/kraken/packages/$pkgname-$pkgver/DIRS before removing the package."
    else
        echo "Removing package $pkgname is fine if you want."
    fi

    echo "fake_inst executed successfully with fake installation."
    return 0
}

























inst (){

pkgname="$1"
pkgver=$(awk -F '=' '/^pkgver=/ {print $2}' "$SOURCE_DIR/$pkgname/pkgbuild.kraken")
echo "Package version is: $pkgver"

metadata_dir="/var/lib/kraken/packages"
metadata_file="$metadata_dir/${pkgname}-${pkgver}.kraken"
if [ ! -d "$metadata_dir" ]; then 
 echo "creating $metadata_dir"
 mkdir -p "$metadata_dir"
 fi

 if [ ! -f "$metadata_file" ]; then 
 echo "creating $metadata_file"
   touch  "$metadata_file"
 fi
 
  



kraken_install_content=$(awk '/^kraken_install\(\) {/,/^}/' "$SOURCE_DIR/$pkgname/pkgbuild.kraken")
   echo "prepare contetnt is $kraken_install_content"
    
    eval "$kraken_install_content"
    # Ensure the function is loaded in the shell
    if ! declare -f kraken_install > /dev/null; then
        echo "ERROR: Failed to load kraken_install function."
        return 1
    fi

    # Execute the kraken_prepare function
    if ! kraken_install ; then
        echo "ERROR: Failed to execute kraken_install for package $pkgname."
        return 1
    fi

       echo "kraken_install executed successfully for package $pkgname. "
    return 0







}






case $1 in
    download)
        get_package $2
        ;;
    checkdeps)
         checkdeps $2
         ;;
    prepare)
         prepare $2
        ;;     
    inst)
        inst $2
        ;;
    preinstall)
      preinstall $2
      ;;   
    build )
      build $2
      ;;
    postinstall)
     postinstall $2
     ;;   
    test)
      test $2
      ;; 
    filter)
     dir_filtring $2
     ;;
     fake)
      fake_inst $2
      ;;  

    *)
        echo "Usage: $0 {download|checkdeps|prepare|build|install|preinstall|postinstall} <package_name>"
        exit 1
        ;;
esac
