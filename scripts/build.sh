#!/bin/bash


BOLD=$(tput bold)
CYAN=$(tput setaf 6)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
RED=$(tput setaf 1)
RESET=$(tput sgr0)

SOURCE_DIR="/sources"
DB_FILE="/var/lib/kraken/kraken.db"
CACHE_DIR="$HOME/.cache/krakenpm"

INDEX_CACHE="$CACHE_DIR/pkgindex.kraken"


pkgname="$1"
echo "${BOLD}${CYAN}=== Building Package: ${pkgname} ===${RESET}"


pkgver=$(awk -F '=' '/^pkgver=/ {print $2}' "$SOURCE_DIR/$pkgname/pkgbuild.kraken")
echo "${BOLD}${CYAN}ℹ Package version: ${YELLOW}${pkgver}${RESET}"


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

exit 0