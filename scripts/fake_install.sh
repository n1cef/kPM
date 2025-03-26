#!/bin/bash

SOURCE_DIR="/sources"
REPO_URL="https://raw.githubusercontent.com/n1cef/kraken_repository"

fake_inst() {
    # Color Definitions
    BOLD=$(tput bold)
    CYAN=$(tput setaf 6)
    GREEN=$(tput setaf 2)
    YELLOW=$(tput setaf 3)
    RED=$(tput setaf 1)
    MAGENTA=$(tput setaf 5)
    RESET=$(tput sgr0)

    pkgname="$1"
    echo "${BOLD}${CYAN}=== Fake Installation: ${YELLOW}${pkgname} ${CYAN}===${RESET}"

    # Get package version
    pkgver=$(awk -F '=' '/^pkgver=/ {print $2}' "$SOURCE_DIR/$pkgname/pkgbuild.kraken")
    echo "${BOLD}${CYAN}ℹ Package version: ${YELLOW}${pkgver}${RESET}"

    metadata_dir="/var/lib/kraken/packages"

    # Extract install function
    echo "${BOLD}${CYAN}⌛ Extracting installation logic...${RESET}"
    kraken_install_content=$(awk '/^kraken_install\(\) {/,/^}/' "$SOURCE_DIR/$pkgname/pkgbuild.kraken")
    
    # Show original content
    echo "${BOLD}${MAGENTA}Original installation commands:${RESET}"
    echo "${YELLOW}${kraken_install_content}${RESET}"

    # Modify install commands
    echo "${BOLD}${CYAN}⚙ Modifying installation paths...${RESET}"
    kraken_install_content=$(echo "$kraken_install_content" | sed -E \
        -e "s/\bmake install\b/make DESTDIR=\/tmp\/${pkgname}-${pkgver} install/" \
        -e "s/\bninja install\b/ninja install DESTDIR=\/tmp\/${pkgname}-${pkgver}/")
    
    # Show modified content
    echo "${BOLD}${MAGENTA}Modified installation commands:${RESET}"
    echo "${GREEN}${kraken_install_content}${RESET}"

    # Execute modified installation
    echo "${BOLD}${CYAN}🏗 Executing fake installation...${RESET}"
    eval "$kraken_install_content"
    
    if ! kraken_install; then
        echo "${BOLD}${RED}✗ ERROR: Fake installation failed for ${YELLOW}${pkgname}${RESET}"
        exit 1
    fi

    # Create metadata files
    echo "${BOLD}${CYAN}📦 Creating package metadata...${RESET}"
    [ ! -f "${metadata_dir}/${pkgname}-${pkgver}/FILES" ] && 
        sudo mkdir -p "${metadata_dir}/${pkgname}-${pkgver}" && 
        sudo touch "${metadata_dir}/${pkgname}-${pkgver}/FILES"

    [ ! -f "${metadata_dir}/${pkgname}-${pkgver}/DIRS" ] && 
        sudo mkdir -p "${metadata_dir}/${pkgname}-${pkgver}" && 
        sudo touch "${metadata_dir}/${pkgname}-${pkgver}/DIRS"

    # Set file permissions
    if ! sudo chmod 755 "${metadata_dir}/${pkgname}-${pkgver}/FILES" "${metadata_dir}/${pkgname}-${pkgver}/DIRS"; then
        echo "${BOLD}${RED}✗ ERROR: Failed to set metadata permissions${RESET}"
        exit 1
    fi

    # Generate file lists
    echo "${BOLD}${CYAN}📂 Generating file system records...${RESET}" 
    
    sudo find "/tmp/${pkgname}-${pkgver}" -type f > "${metadata_dir}/${pkgname}-${pkgver}/FILES"
    
    
    sudo find "/tmp/${pkgname}-${pkgver}" -type d > "${metadata_dir}/${pkgname}-${pkgver}/DIRS"
     
    # Clean paths
    echo "${BOLD}${CYAN}🧹 Cleaning path records...${RESET}"
    sudo sed -i "s|^/tmp/${pkgname}-${pkgver}||" "${metadata_dir}/${pkgname}-${pkgver}/FILES"
    sudo sed -i "s|^/tmp/${pkgname}-${pkgver}||" "${metadata_dir}/${pkgname}-${pkgver}/DIRS"

    # Copy build recipe
    echo "${BOLD}${CYAN}📋 Archiving package recipe...${RESET}"
    sudo cp "$SOURCE_DIR/$pkgname/pkgbuild.kraken" "${metadata_dir}/${pkgname}-${pkgver}/pkgbuild.kraken"

    # Validate directories
    echo "${BOLD}${CYAN}🔍 Validating installed directories...${RESET}"
    source "/usr/kraken/scripts/dir_filtring.sh"
    
    if ! dir_filtring "$pkgname" "$pkgver"; then
        echo "${BOLD}${RED}⚠ WARNING: Please review ${YELLOW}/var/lib/kraken/packages/$pkgname-$pkgver/DIRS${RED} before removal${RESET}"
    else
        echo "${GREEN}✓ Package directory structure validated${RESET}"
    fi

    echo "${BOLD}${GREEN}✅ Fake installation completed successfully for ${YELLOW}${pkgname}${RESET}"
    return 0
}

# Execute main function
fake_inst "$1"
