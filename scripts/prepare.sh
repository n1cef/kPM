#!/bin/bash

SOURCE_DIR="/sources"
REPO_URL="https://raw.githubusercontent.com/n1cef/kraken_repository"

prepare_package() {
    # Color Definitions
    BOLD=$(tput bold)
    CYAN=$(tput setaf 6)
    GREEN=$(tput setaf 2)
    YELLOW=$(tput setaf 3)
    RED=$(tput setaf 1)
    MAGENTA=$(tput setaf 5)
    RESET=$(tput sgr0)

    pkgname="$1"
    echo "${BOLD}${CYAN}=== Preparation Stage: ${YELLOW}${pkgname} ${CYAN}===${RESET}"

    # Get package version
    pkgver=$(awk -F '=' '/^pkgver=/ {print $2}' "$SOURCE_DIR/$pkgname/pkgbuild.kraken")
    echo "${BOLD}${CYAN}ℹ Package version: ${YELLOW}${pkgver}${RESET}"

    # Extract preparation commands
    echo "${BOLD}${CYAN}🔍 Extracting preparation logic...${RESET}"
    kraken_prepare_content=$(awk '/^kraken_prepare\(\) {/,/^}/' "$SOURCE_DIR/$pkgname/pkgbuild.kraken")
    
    # Display extracted content
    echo "${BOLD}${MAGENTA}Preparation commands:${RESET}"
    echo "${YELLOW}${kraken_prepare_content}${RESET}"

    # Evaluate function
    echo "${BOLD}${CYAN}⚙ Loading preparation function...${RESET}"
    eval "$kraken_prepare_content"

    if ! declare -f kraken_prepare > /dev/null; then
        echo "${BOLD}${RED}✗ ERROR: Failed to load preparation function${RESET}"
        exit 1
    fi

    # Execute preparation
    echo "${BOLD}${CYAN}🛠️ Running preparation tasks...${RESET}"
    if kraken_prepare; then
        echo "${BOLD}${GREEN}✓ Preparation completed for ${YELLOW}${pkgname}${RESET}"
    else
        echo "${BOLD}${RED}✗ ERROR: Preparation failed for ${YELLOW}${pkgname}${RESET}"
        exit 1
    fi

    exit 0
}

# Execute main function
prepare_package "$1"