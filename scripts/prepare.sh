#!/bin/bash

SOURCE_DIR="/sources"
DB_FILE="/var/lib/kraken/db/kraken.db"
CACHE_DIR="$HOME/.cache/krakenpm"

INDEX_CACHE="$CACHE_DIR/pkgindex.kraken"

prepare_package() {
  
    BOLD=$(tput bold)
    CYAN=$(tput setaf 6)
    GREEN=$(tput setaf 2)
    YELLOW=$(tput setaf 3)
    RED=$(tput setaf 1)
    MAGENTA=$(tput setaf 5)
    RESET=$(tput sgr0)

    pkgname="$1"
    echo "${BOLD}${CYAN}=== Preparation Stage: ${YELLOW}${pkgname} ${CYAN}===${RESET}"

local version=$(yq eval ".packages.$pkgname.version" "$INDEX_CACHE") 


source /var/lib/kraken/db/kraken_db.sh

pkg_id=$(get_pkg_id "$pkgname" "$version")
if [ -z "$pkg_id" ]; then  # Check for empty
    echo "${RED}Package not found in database${RESET}"
    exit 1
fi

downloaded_status=$(check_steps "$pkg_id" "downloaded")


if [ -z "$downloaded_status" ]; then
    echo "Package not found in database"
    exit 1
elif [ "$downloaded_status" -ne 1 ]; then
    echo "You must run kraken download $pkgname first"
    exit 1
fi


    if [[ ! -f "$SOURCE_DIR/$pkgname/pkgbuild.kraken" ]]; then
        echo "${BOLD}${RED}✗ ERROR: PKGBUILD not found${RESET}"
        exit 1
    fi

  
    pkgver=$(awk -F '=' '/^pkgver=/ {print $2}' "$SOURCE_DIR/$pkgname/pkgbuild.kraken")
    echo "${BOLD}${CYAN}ℹ Package version: ${YELLOW}${pkgver}${RESET}"

  
    echo "${BOLD}${CYAN}🔍 Extracting preparation logic...${RESET}"
    if ! source "$SOURCE_DIR/$pkgname/pkgbuild.kraken"; then
        echo "${BOLD}${RED}✗ ERROR: Failed to load PKGBUILD${RESET}"
        exit 1
    fi

    if ! declare -f kraken_prepare >/dev/null; then
        echo "${BOLD}${RED}✗ ERROR: Missing kraken_prepare() function${RESET}"
        exit 1
    fi

   
    echo "${BOLD}${CYAN}🛠️ Running preparation tasks...${RESET}"
    if kraken_prepare; then
        echo "${BOLD}${GREEN}✓ Preparation completed for ${YELLOW}${pkgname}${RESET}"
    else
        echo "${BOLD}${RED}✗ ERROR: Preparation failed${RESET}"
        exit 1
    fi

    
    echo "${BOLD}${CYAN}🔗 Checking package dependencies...${RESET}"
    deps=($(sudo kraken listdependency "$pkgname"))

    if [ ${#deps[@]} -gt 0 ]; then
        echo "${BOLD}${YELLOW}⚠ WARNING: Unmet dependencies detected:${RESET}"
        printf "  ${MAGENTA}• %s${RESET}\n" "${deps[@]}"
        echo "${CYAN}These dependencies must be resolved before building."
        
       # read -p "${BOLD}${CYAN}Do you want to: 
#1) Install dependencies automatically (requires entropy)
#2) Continue anyway
#3) Abort preparation
#Choice [1/2/3]: ${RESET}" response
        
    #    case $response in
      #      1)
       #         echo "${CYAN}Attempting automatic dependency resolution..."
        #        if ! sudo kraken entropy "$pkgname"; then
         #           echo "${RED}✗ Failed to resolve dependencies"
          #          exit 1
           #     fi
            #    ;;
           # 2)
            #    echo "${YELLOW}⚠ Proceeding with unmet dependencies - build may fail!"
             #   sleep 2
              #  ;;
            #3)
             #   echo "${GREEN}✅ Preparation aborted by user"
              #  exit 0
               # ;;
            #*)
             #   echo "${RED}✗ Invalid choice"
              #  exit 1
               # ;;
        #esac
    else
        echo "${GREEN}✅ No dependencies required - safe to build"
    fi

source /var/lib/kraken/db/kraken_db.sh

   if ! mark_prepared "$pkg_id"; then
    echo "${RED}Failed to update preparation status${RESET}"
    exit 1
fi







}


if [ -z "$1" ]; then
    echo "${RED}✗ Missing package name"
    exit 1
fi

prepare_package "$1"