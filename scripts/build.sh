#!/bin/bash




SOURCE_DIR="/sources"
DB_FILE="/var/lib/kraken/db/kraken.db"
CACHE_DIR="$HOME/.cache/krakenpm"

INDEX_CACHE="$CACHE_DIR/pkgindex.kraken"

build_package() { 
BOLD=$(tput bold)
CYAN=$(tput setaf 6)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
RED=$(tput setaf 1)
RESET=$(tput sgr0)




pkgname="$1"
echo "${BOLD}${CYAN}=== Building Package: ${pkgname} ===${RESET}"




local version=$(yq eval ".packages.$pkgname.version" "$INDEX_CACHE") 

#pkgver=$(awk -F '=' '/^pkgver=/ {print $2}' "$SOURCE_DIR/$pkgname/pkgbuild.kraken")
#echo "${BOLD}${CYAN}ℹ Package version: ${YELLOW}${pkgver}${RESET}"



source /var/lib/kraken/db/kraken_db.sh

pkg_id=$(get_pkg_id "$pkgname" "$version")
if [ -z "$pkg_id" ]; then  # Check for empty
    echo "${RED}Package not found in database${RESET}"
    exit 1
fi

prepared_status=$(check_steps "$pkg_id" "prepared")


if [ -z "$prepared_status" ]; then
    echo "Package not found in database"
    exit 1
elif [ "$prepared_status" -ne 1 ]; then
    echo "You must run kraken prepare $pkgname first"
    exit 1
fi










echo "${BOLD}${CYAN}⌛ Extracting build function...${RESET}"
kraken_build_content=$(awk '/^kraken_build\(\) {/,/^}/' "$SOURCE_DIR/$pkgname/pkgbuild.kraken")


if [[ -z "$kraken_build_content" ]]; then
    echo "${BOLD}${RED}✗ ERROR: No build function found in pkgbuild.kraken${RESET}"
    exit 1
fi


echo "${BOLD}${CYAN}⚙ Loading build function...${RESET}"
eval "$kraken_build_content"

if ! declare -f kraken_build > /dev/null; then
    echo "${BOLD}${RED}✗ ERROR: Failed to load kraken_build function${RESET}"
    exit 1
fi


echo "${BOLD}${CYAN}🏗 Starting build process...${RESET}"
if kraken_build; then
    echo "${BOLD}${GREEN}✓ Success: kraken_build executed successfully for ${YELLOW}${pkgname}${RESET}"
else
    echo "${BOLD}${RED}✗ ERROR: Build failed for ${YELLOW}${pkgname}${RESET}"
    exit 1
fi



source /var/lib/kraken/db/kraken_db.sh

   if ! mark_builded "$pkg_id"; then
    echo "${RED}Failed to update build status${RESET}"
    exit 1
fi






exit 0

}

if [ -z "$1" ]; then
    echo "${RED}✗ Missing package name"
    exit 1
fi

build_package "$1"