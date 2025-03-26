#!/bin/bash

SOURCE_DIR="/sources"
REPO_URL="https://raw.githubusercontent.com/n1cef/kraken_repository"
metadata_dir="/var/lib/kraken/packages"

remove_package() {
    # Color Definitions
    BOLD=$(tput bold)
    CYAN=$(tput setaf 6)
    GREEN=$(tput setaf 2)
    YELLOW=$(tput setaf 3)
    RED=$(tput setaf 1)
    MAGENTA=$(tput setaf 5)
    RESET=$(tput sgr0)

    pkgname="$1"
    echo "${BOLD}${CYAN}=== Package Removal: ${YELLOW}${pkgname} ${CYAN}===${RESET}"

    # Validate package name
    if [ -z "$pkgname" ]; then
        echo "${BOLD}${RED}✗ ERROR: No package name specified${RESET}"
        exit 1
    fi

    # Check build directory
    if [ ! -d "$SOURCE_DIR/$pkgname" ]; then 
        echo "${BOLD}${YELLOW}⚠ Build directory not found - preparing package...${RESET}"
        source "/usr/kraken/scripts/prepare.sh"
        sudo kraken prepare "$pkgname"
    fi

    # Get package version
    pkgver=$(awk -F '=' '/^pkgver=/ {print $2}' "$SOURCE_DIR/$pkgname/pkgbuild.kraken")
    if [ -z "$pkgver" ]; then
        echo "${BOLD}${RED}✗ ERROR: Could not determine package version${RESET}"
        exit 1
    fi
    echo "${BOLD}${CYAN}ℹ Package version: ${YELLOW}${pkgver}${RESET}"

    # Verify installation
    package_path="$metadata_dir/$pkgname-$pkgver"
    if [ ! -d "$package_path" ]; then
        echo "${BOLD}${RED}✗ ERROR: Package ${YELLOW}${pkgname}-${pkgver} ${RED}not installed${RESET}"
        exit 1
    fi

    # Extract removal logic
    echo "${BOLD}${CYAN}🔍 Analyzing removal instructions...${RESET}"
    kraken_remove_content=$(awk '/^kraken_remove\(\) {/,/^}/' "$SOURCE_DIR/$pkgname/pkgbuild.kraken")
    
    # Check for custom removal script
    function_body=$(awk '/^kraken_remove\(\) {/,/^}/' "$SOURCE_DIR/$pkgname/pkgbuild.kraken" | 
                    sed '1d;$d' | tr -d '[:space:]')
    
    if [ "$function_body" = "return" ]; then
        echo "${BOLD}${CYAN}🔀 No custom removal found - using manual method${RESET}"
        
        if [ ! -f "/usr/kraken/scripts/manual_remove.sh" ]; then
            echo "${BOLD}${RED}✗ ERROR: Manual removal script missing${RESET}"
            exit 1
        fi

        source "/usr/kraken/scripts/manual_remove.sh"
        manual_remove "$pkgname" "$pkgver"
        exit 0
    fi

    # Execute custom removal
    echo "${BOLD}${MAGENTA}Custom removal commands:${RESET}"
    echo "${YELLOW}${kraken_remove_content}${RESET}"

    echo "${BOLD}${CYAN}⚙ Loading removal function...${RESET}"
    eval "$kraken_remove_content"

    if ! declare -f kraken_remove > /dev/null; then
        echo "${BOLD}${RED}✗ ERROR: Failed to load removal function${RESET}"
        exit 1
    fi

    echo "${BOLD}${CYAN}🗑 Executing removal tasks...${RESET}"
    if kraken_remove; then
        echo "${BOLD}${GREEN}✓ Successfully removed ${YELLOW}${pkgname}${RESET}"
    else
        echo "${BOLD}${RED}✗ ERROR: Removal failed for ${YELLOW}${pkgname}${RESET}"
        exit 1
    fi

    exit 0
}

# Execute main function
remove_package "$1"