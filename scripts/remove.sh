#!/bin/bash

# Define the source directory
SOURCE_DIR="/sources"
REPO_URL="https://raw.githubusercontent.com/n1cef/kraken_repository"
metadata_dir="/var/lib/kraken/packages"
pkgname="$1"

if [ -z "$pkgname" ]; then
    echo "ERROR: No package name provided."
    exit 1
fi

# Check if the package build directory exists
if [ ! -d "$SOURCE_DIR/$pkgname" ]; then 
    echo "Build directory for package $pkgname does not exist. Don't panic, we will take care of it."
    source "/home/pkg/kraken_package_manager/scripts/prepare.sh"
    sudo kraken prepare "$pkgname"
fi

# Extract the package version
pkgver=$(awk -F '=' '/^pkgver=/ {print $2}' "$SOURCE_DIR/$pkgname/pkgbuild.kraken")

# Check if pkgver was found
if [ -z "$pkgver" ]; then
    echo "ERROR: Unable to determine package version for $pkgname."
    exit 1
fi

echo "Package version is: $pkgver"

# Check if the package is installed
package_path="$metadata_dir/$pkgname-$pkgver"
if [ ! -d "$package_path" ]; then
    echo "ERROR: Package $pkgname-$pkgver is not installed."
    exit 1
fi

# Extract the kraken_remove function content from pkgbuild.kraken
kraken_remove_content=$(awk '/^kraken_remove\(\) {/,/^}/' "$SOURCE_DIR/$pkgname/pkgbuild.kraken")

# Extract the function body and check if it contains only "return"
function_body=$(awk '/^kraken_remove\(\) {/,/^}/' "$SOURCE_DIR/$pkgname/pkgbuild.kraken" | sed '1d;$d' | tr -d '[:space:]')

if [ "$function_body" = "return" ]; then
    echo "kraken_remove is empty. Redirecting to manual_remove..."
    
    # Ensure manual_remove.sh exists
    if [ ! -f "/home/pkg/kraken_package_manager/scripts/manual_remove.sh" ]; then
        echo "ERROR: manual_remove.sh script not found."
        exit 1
    fi

    # Call manual_remove
    source "/home/pkg/kraken_package_manager/scripts/manual_remove.sh"
    manual_remove "$pkgname" "$pkgver"
    exit 0
fi

# Ensure the function is loaded in the shell
eval "$kraken_remove_content"
if ! declare -f kraken_remove > /dev/null; then
    echo "ERROR: Failed to load kraken_remove function."
    exit 1
fi

# Execute the kraken_remove function
if ! kraken_remove; then
    echo "ERROR: Failed to execute kraken_remove for package $pkgname."
    exit 1
fi

echo "kraken_remove executed successfully for package $pkgname."
exit 0
