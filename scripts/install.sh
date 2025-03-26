#!/bin/bash

SOURCE_DIR="/sources"
REPO_URL="https://raw.githubusercontent.com/n1cef/kraken_repository"

# Color Definitions
BOLD=$(tput bold)
CYAN=$(tput setaf 6)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
RED=$(tput setaf 1)
MAGENTA=$(tput setaf 5)
RESET=$(tput sgr0)

pkgname="$1"
echo "${BOLD}${CYAN}=== Package Installation: ${YELLOW}${pkgname} ${CYAN}===${RESET}"

# Get package version
pkgver=$(awk -F '=' '/^pkgver=/ {print $2}' "$SOURCE_DIR/$pkgname/pkgbuild.kraken")
echo "${BOLD}${CYAN}ℹ Package version: ${YELLOW}${pkgver}${RESET}"

metadata_dir="/var/lib/kraken/packages"

# Create metadata directory
echo "${BOLD}${CYAN}⌛ Preparing package database...${RESET}"
if [ ! -d "$metadata_dir" ]; then
    mkdir -pv "/var/lib/kraken/" "$metadata_dir" || {
        echo "${BOLD}${RED}✗ ERROR: Failed to create metadata directory${RESET}"
        exit 1
    }
fi

# Fake installation stage
echo "${BOLD}${CYAN}🏗 Beginning installation process...${RESET}"
source "/usr/kraken/scripts/fake_install.sh"

if ! fake_inst "$pkgname"; then
    echo "${BOLD}${RED}✗ ERROR: Fake installation failed for ${YELLOW}${pkgname}${RESET}"
    exit 1
else
    echo "${GREEN}✓ Fake installation completed successfully${RESET}"
fi

# Extract and execute real installation
echo "${BOLD}${CYAN}⚙ Extracting installation commands...${RESET}"
kraken_install_content=$(awk '/^kraken_install\(\) {/,/^}/' "$SOURCE_DIR/$pkgname/pkgbuild.kraken")

echo "${BOLD}${MAGENTA}Installation commands:${RESET}"
echo "${YELLOW}${kraken_install_content}${RESET}"

eval "$kraken_install_content"

if ! declare -f kraken_install > /dev/null; then
    echo "${BOLD}${RED}✗ ERROR: Failed to load installation function${RESET}"
    exit 1
fi

echo "${BOLD}${CYAN}🚀 Executing real installation...${RESET}"
if kraken_install; then
    echo "${BOLD}${GREEN}✓ Successfully installed ${YELLOW}${pkgname}${RESET}"
else
    echo "${BOLD}${RED}✗ ERROR: Installation failed for ${YELLOW}${pkgname}${RESET}"
    exit 1
fi

echo "${BOLD}${CYAN}🔍 Finalizing installation records...${RESET}"
echo "${GREEN}✓ Package ${YELLOW}${pkgname} ${GREEN}installed successfully${RESET}"
exit 0