#!/bin/bash

SOURCE_DIR="/sources"
REPO_URL="https://raw.githubusercontent.com/n1cef/kraken_repository"

test_package() {
    # Color Definitions
    BOLD=$(tput bold)
    CYAN=$(tput setaf 6)
    GREEN=$(tput setaf 2)
    YELLOW=$(tput setaf 3)
    RED=$(tput setaf 1)
    MAGENTA=$(tput setaf 5)
    RESET=$(tput sgr0)

    pkgname="$1"
    echo "${BOLD}${CYAN}=== Testing Package: ${YELLOW}${pkgname} ${CYAN}===${RESET}"

    # Get package version
    pkgver=$(awk -F '=' '/^pkgver=/ {print $2}' "$SOURCE_DIR/$pkgname/pkgbuild.kraken")
    echo "${BOLD}${CYAN}ℹ Package version: ${YELLOW}${pkgver}${RESET}"

    # Extract test commands
    echo "${BOLD}${CYAN}🔍 Extracting test suite...${RESET}"
    kraken_test_content=$(awk '/^kraken_test\(\) {/,/^}/' "$SOURCE_DIR/$pkgname/pkgbuild.kraken")
    
    # Display test commands
    echo "${BOLD}${MAGENTA}Test commands:${RESET}"
    echo "${YELLOW}${kraken_test_content}${RESET}"

    # Evaluate test function
    echo "${BOLD}${CYAN}⚙ Loading test environment...${RESET}"
    eval "$kraken_test_content"

    if ! declare -f kraken_test > /dev/null; then
        echo "${BOLD}${RED}✗ ERROR: Test suite not found for ${YELLOW}${pkgname}${RESET}"
        exit 1
    fi

    # Execute tests
    echo "${BOLD}${CYAN}🧪 Running test suite...${RESET}"
    if kraken_test; then
        echo "${BOLD}${GREEN}✓ All tests passed for ${YELLOW}${pkgname}${RESET}"
    else
        echo "${BOLD}${RED}✗ ERROR: Tests failed for ${YELLOW}${pkgname}${RESET}"
        exit 1
    fi

    exit 0
}

# Execute main function
test_package "$1"