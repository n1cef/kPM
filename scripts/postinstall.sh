#!/bin/bash

SOURCE_DIR="/sources"
REPO_URL="https://raw.githubusercontent.com/n1cef/kraken_repository"

postinstall() {
    # Color Definitions
    BOLD=$(tput bold)
    CYAN=$(tput setaf 6)
    GREEN=$(tput setaf 2)
    YELLOW=$(tput setaf 3)
    RED=$(tput setaf 1)
    MAGENTA=$(tput setaf 5)
    RESET=$(tput sgr0)

    pkgname="$1"
    echo "${BOLD}${CYAN}=== Post-Installation: ${YELLOW}${pkgname} ${CYAN}===${RESET}"

    # Get package version
    pkgver=$(awk -F '=' '/^pkgver=/ {print $2}' "$SOURCE_DIR/$pkgname/pkgbuild.kraken")
    echo "${BOLD}${CYAN}ℹ Package version: ${YELLOW}${pkgver}${RESET}"

    # Extract post-install commands
    echo "${BOLD}${CYAN}⌛ Extracting post-installation logic...${RESET}"
    kraken_postinstall_content=$(awk '/^kraken_postinstall\(\) {/,/^}/' "$SOURCE_DIR/$pkgname/pkgbuild.kraken")
    
    # Display extracted content
    echo "${BOLD}${MAGENTA}Post-installation commands:${RESET}"
    echo "${YELLOW}${kraken_postinstall_content}${RESET}"

    # Evaluate function
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

    exit 0
}

# Execute main function
postinstall "$1"