#!/bin/bash
# Define the source directory
SOURCE_DIR="/sources"
REPO_URL="https://raw.githubusercontent.com/n1cef/kraken_repository"
 pkgname="$1"

fake_inst() {
    pkgname="$1"
    echo "$pkgname"
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
        exit 1
    fi

    # Create metadata files if not exist
    [ ! -f "${metadata_dir}/${pkgname}-${pkgver}/FILES" ] && sudo mkdir -p "${metadata_dir}/${pkgname}-${pkgver}" && sudo touch "${metadata_dir}/${pkgname}-${pkgver}/FILES"
    [ ! -f "${metadata_dir}/${pkgname}-${pkgver}/DIRS" ] && sudo mkdir -p "${metadata_dir}/${pkgname}-${pkgver}" && sudo touch "${metadata_dir}/${pkgname}-${pkgver}/DIRS"

    sudo chmod 755 "${metadata_dir}/${pkgname}-${pkgver}/FILES"

    sudo chmod 755 "${metadata_dir}/${pkgname}-${pkgver}/DIRS"


    # Capture files and directories
    sudo find "/tmp/${pkgname}-${pkgver}" -type f > "${metadata_dir}/${pkgname}-${pkgver}/FILES"
    sudo find "/tmp/${pkgname}-${pkgver}" -type d > "${metadata_dir}/${pkgname}-${pkgver}/DIRS"

    # Remove temporary prefix
    sudo sed -i "s|^/tmp/${pkgname}-${pkgver}||" "${metadata_dir}/${pkgname}-${pkgver}/FILES"
    sudo sed -i "s|^/tmp/${pkgname}-${pkgver}||" "${metadata_dir}/${pkgname}-${pkgver}/DIRS"

    sudo cp "$SOURCE_DIR/$pkgname/pkgbuild.kraken" "${metadata_dir}/${pkgname}-${pkgver}/pkgbuild.kraken"

    # Call dir_filtring to validate the directories
    source /home/pkg/kraken/scripts/dir_filtring.sh 
    if ! dir_filtring "$pkgname"; then
        echo "Please review and edit /var/lib/kraken/packages/$pkgname-$pkgver/DIRS before removing the package."
    else
        echo "Removing package $pkgname is fine if you want."
    fi

    echo "fake_inst executed successfully with fake installation."
    exit 0
}


#call the function 


fake_inst "$1"