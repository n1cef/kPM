
#!/bin/bash
# Define the source directory
SOURCE_DIR="/sources"
REPO_URL="https://raw.githubusercontent.com/n1cef/kraken"
 pkgname="$1"
 
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