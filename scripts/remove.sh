#!/bin/bash


SOURCE_DIR="/sources"
REPO_URL="https://raw.githubusercontent.com/n1cef/kraken_repository"
metadata_dir="/var/lib/kraken/packages"
pkgname="$1"

if [ -z "$pkgname" ]; then
    echo "ERROR: No package name provided."
    exit 1
fi


if [ ! -d "$SOURCE_DIR/$pkgname" ]; then 
    echo "Build directory for package $pkgname does not exist. Don't panic, we will take care of it."
    source "/usr/kraken/scripts/prepare.sh"
    sudo kraken prepare "$pkgname"
fi


pkgver=$(awk -F '=' '/^pkgver=/ {print $2}' "$SOURCE_DIR/$pkgname/pkgbuild.kraken")


if [ -z "$pkgver" ]; then
    echo "ERROR: Unable to determine package version for $pkgname."
    exit 1
fi

echo "Package version is: $pkgver"


package_path="$metadata_dir/$pkgname-$pkgver"
if [ ! -d "$package_path" ]; then
    echo "ERROR: Package $pkgname-$pkgver is not installed."
    exit 1
fi


kraken_remove_content=$(awk '/^kraken_remove\(\) {/,/^}/' "$SOURCE_DIR/$pkgname/pkgbuild.kraken")
echo "kraken remove content is  $kraken_remove_content"
# Extract the function body and check if it contains only return 
function_body=$(awk '/^kraken_remove\(\) {/,/^}/' "$SOURCE_DIR/$pkgname/pkgbuild.kraken" | sed '1d;$d' | tr -d '[:space:]')
echo "function body is $function_body"
if [ "$function_body" = "return" ]; then
    echo "kraken_remove is empty. Redirecting to manual_remove..."
    
    
    if [ ! -f "/usr/kraken/scripts/manual_remove.sh" ]; then
        echo "ERROR: manual_remove.sh script not found."
        exit 1
    fi

    # Call manual_remove
    source "/usr/kraken/scripts/manual_remove.sh"
    manual_remove "$pkgname" "$pkgver"
    exit 0
fi


eval "$kraken_remove_content"
if ! declare -f kraken_remove > /dev/null; then
    echo "ERROR: Failed to load kraken_remove function."
    exit 1
fi


if ! kraken_remove; then
    echo "ERROR: Failed to execute kraken_remove for package $pkgname."
    exit 1
fi

echo "kraken_remove executed successfully for package $pkgname."
exit 0
