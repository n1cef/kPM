#!/bin/bash

SOURCE_DIR="/sources"
DB_FILE="/var/lib/kraken/db/kraken.db"
CACHE_DIR="$HOME/.cache/krakenpm"

INDEX_CACHE="$CACHE_DIR/pkgindex.kraken"

postinstall() {
    
    BOLD=$(tput bold)
    CYAN=$(tput setaf 6)
    GREEN=$(tput setaf 2)
    YELLOW=$(tput setaf 3)
    RED=$(tput setaf 1)
    MAGENTA=$(tput setaf 5)
    RESET=$(tput sgr0)

    pkgname="$1"
    echo "${BOLD}${CYAN}=== Post-Installation: ${YELLOW}${pkgname} ${CYAN}===${RESET}"

    
    pkgver=$(awk -F '=' '/^pkgver=/ {print $2}' "$SOURCE_DIR/$pkgname/pkgbuild.kraken")
    echo "${BOLD}${CYAN}ℹ Package version: ${YELLOW}${pkgver}${RESET}"

    local version=$(yq eval ".packages.$pkgname.version" "$INDEX_CACHE") 

    [ -z "$version" ] && {
        printf "${BOLD}${RED}✗ Failed to detect package version${RESET}\n" >&2
        return 1
    }


source /var/lib/kraken/db/kraken_db.sh

pkg_id=$(get_pkg_id "$pkgname" "$version")
if [ -z "$pkg_id" ]; then  
    echo "${RED}Package not found in database${RESET}"
    exit 1
fi

installed_status=$(check_steps "$pkg_id" "installed")


if [ -z "$installed_status" ]; then
    echo "Package not found in database"
    exit 1
elif [ "$installed_status" -ne 1 ]; then
    echo "You must run kraken install $pkgname first"
    exit 1
fi








    echo "${BOLD}${CYAN}⌛ Extracting post-installation logic...${RESET}"
    kraken_postinstall_content=$(awk '/^kraken_postinstall\(\) {/,/^}/' "$SOURCE_DIR/$pkgname/pkgbuild.kraken")
    
    
    echo "${BOLD}${MAGENTA}Post-installation commands:${RESET}"
    echo "${YELLOW}${kraken_postinstall_content}${RESET}"

    
    echo "${BOLD}${CYAN}⚙ Loading post-installation function...${RESET}"
    eval "$kraken_postinstall_content"

    if ! declare -f kraken_postinstall > /dev/null; then
        echo "${BOLD}${RED}✗ ERROR: Failed to load post-installation function${RESET}"
        exit 1
    fi

    # Execute post-install
    echo "${BOLD}${CYAN}🚀 Running post-installation tasks...${RESET}"
    if kraken_postinstall; then
        echo "${BOLD}${GREEN}✓ Post-installation completed for ${YELLOW}${pkgname}${RESET}"
    else
        echo "${BOLD}${RED}✗ ERROR: Post-installation failed for ${YELLOW}${pkgname}${RESET}"
        exit 1
    fi

source /var/lib/kraken/db/kraken_db.sh

   if ! mark_postinstalled "$pkg_id"; then
    echo "${RED}Failed to update postinstalled status${RESET}"
    exit 1
fi

if verifyall_steps "$pkg_id"; then
    echo "${GREEN}Package fully installed!${RESET}"
else
    echo "${RED} Installation incomplete! you can check the installation_steps table with \n
     sqlitebrowser /var/lib/kraken/db/kraken.db and please report any bug in </github.com/n1cef/kraken_package_manager> ${RESET}"
    exit 1
fi




    exit 0
}

# Execute main function
postinstall "$1"