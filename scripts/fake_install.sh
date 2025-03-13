#!/bin/bash

SOURCE_DIR="/sources"
REPO_URL="https://raw.githubusercontent.com/n1cef/kraken_repository"
 pkgname="$1"

fake_inst() {
    pkgname="$1"
    echo "$pkgname"
    pkgver=$(awk -F '=' '/^pkgver=/ {print $2}' "$SOURCE_DIR/$pkgname/pkgbuild.kraken")
    echo "Package version is: $pkgver"

    metadata_dir="/var/lib/kraken/packages"

    
    kraken_install_content=$(awk '/^kraken_install\(\) {/,/^}/' "$SOURCE_DIR/$pkgname/pkgbuild.kraken")
    echo "Original kraken_install content:"
    echo "$kraken_install_content"

    
    kraken_install_content=$(echo "$kraken_install_content" | sed -E \
        -e "s/\bmake install\b/make DESTDIR=\/tmp\/${pkgname}-${pkgver} install/" \
        -e "s/\bninja install\b/ninja install DESTDIR=\/tmp\/${pkgname}-${pkgver}/")
    echo "Modified kraken_install content:"
    echo "$kraken_install_content"

    
    eval "$kraken_install_content"

    if ! kraken_install; then
        echo "ERROR: Failed to execute fake_kraken_install for package $pkgname."
        exit 1
    fi

    
    [ ! -f "${metadata_dir}/${pkgname}-${pkgver}/FILES" ] &&
     sudo mkdir -p "${metadata_dir}/${pkgname}-${pkgver}" && 
     sudo touch "${metadata_dir}/${pkgname}-${pkgver}/FILES"

    [ ! -f "${metadata_dir}/${pkgname}-${pkgver}/DIRS" ] && 
    sudo mkdir -p "${metadata_dir}/${pkgname}-${pkgver}" && 
    sudo touch "${metadata_dir}/${pkgname}-${pkgver}/DIRS"

    sudo chmod 755 "${metadata_dir}/${pkgname}-${pkgver}/FILES"

    #sudo chmod 755 "${metadata_dir}/${pkgname}-${pkgver}/DIRS"
    sudo chmod 755 "${metadata_dir}/${pkgname}-${pkgver}/DIRS" || {

    echo "Failed to change permissions for DIRS file."

    exit 1

}


    
    sudo find "/tmp/${pkgname}-${pkgver}" -type f > "${metadata_dir}/${pkgname}-${pkgver}/FILES"
    sudo find "/tmp/${pkgname}-${pkgver}" -type d > "${metadata_dir}/${pkgname}-${pkgver}/DIRS"

    
    sudo sed -i "s|^/tmp/${pkgname}-${pkgver}||" "${metadata_dir}/${pkgname}-${pkgver}/FILES"
    sudo sed -i "s|^/tmp/${pkgname}-${pkgver}||" "${metadata_dir}/${pkgname}-${pkgver}/DIRS"

    sudo cp "$SOURCE_DIR/$pkgname/pkgbuild.kraken" "${metadata_dir}/${pkgname}-${pkgver}/pkgbuild.kraken"

    # Call dir_filtring to validate the directories
    source "/usr/kraken/scripts/dir_filtring.sh"

if ! dir_filtring "$pkgname" "$pkgver"; then
   echo -e "\e[31mPlease review and edit /var/lib/kraken/packages/$pkgname-$pkgver/DIRS before removing the package.\e[0m"
else
    echo "Removing package $pkgname is fine if you want."
fi

echo "fake_inst executed successfully with fake installation."
return 0
}


#call the function 


fake_inst "$1"
