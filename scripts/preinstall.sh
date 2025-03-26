#!/bin/bash

SOURCE_DIR="/sources"
REPO_URL="https://raw.githubusercontent.com/n1cef/kraken_repository"

preinstall() {
    # Color Definitions
    BOLD=$(tput bold)
    CYAN=$(tput setaf 6)
    GREEN=$(tput setaf 2)
    YELLOW=$(tput setaf 3)
    RED=$(tput setaf 1)
    MAGENTA=$(tput setaf 5)
    RESET=$(tput sgr0)

    pkgname="$1"
    echo "${BOLD}${CYAN}=== Pre-Installation Checks: ${YELLOW}${pkgname} ${CYAN}===${RESET}"

    # Extract pre-install commands
    echo "${BOLD}${CYAN}⌛ Extracting pre-installation logic...${RESET}"
    kraken_preinstall_content=$(awk '/^kraken_preinstall\(\) {/,/^}/' "$SOURCE_DIR/$pkgname/pkgbuild.kraken")
    
    # Display extracted content
    echo "${BOLD}${MAGENTA}Pre-installation commands:${RESET}"
    echo "${YELLOW}${kraken_preinstall_content}${RESET}"

    # Evaluate function
    echo "${BOLD}${CYAN}⚙ Loading pre-installation function...${RESET}"
    eval "$kraken_preinstall_content"

    if ! declare -f kraken_preinstall > /dev/null; then
        echo "${BOLD}${RED}✗ ERROR: Failed to load pre-installation function${RESET}"
        exit 1
    fi

    # Execute pre-install
    echo "${BOLD}${CYAN}🛠️ Running pre-installation tasks...${RESET}"
    if kraken_preinstall; then
        echo "${BOLD}${GREEN}✓ Pre-installation completed for ${YELLOW}${pkgname}${RESET}"
    else
        echo "${BOLD}${RED}✗ ERROR: Pre-installation failed for ${YELLOW}${pkgname}${RESET}"
        exit 1
    fi

    exit 0
}

# Execute main function
preinstall "$1"