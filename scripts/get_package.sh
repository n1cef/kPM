#!/bin/bash

SOURCE_DIR="/sources"
REPO_URL="https://raw.githubusercontent.com/n1cef/kraken_repository"

get_package() {
    # Color Definitions
    BOLD=$(tput bold)
    CYAN=$(tput setaf 6)
    GREEN=$(tput setaf 2)
    YELLOW=$(tput setaf 3)
    RED=$(tput setaf 1)
    MAGENTA=$(tput setaf 5)
    RESET=$(tput sgr0)

    pkgname="$1"
    echo "${BOLD}${CYAN}=== Fetching Package: ${YELLOW}${pkgname} ${CYAN}===${RESET}"

    # Validate input
    if [ -z "$pkgname" ]; then
        echo "${BOLD}${RED}✗ ERROR: Package name not specified${RESET}"
        exit 1
    fi

    # Create directories
    echo "${BOLD}${CYAN}⌛ Preparing workspace...${RESET}"
    mkdir -p "$SOURCE_DIR/$pkgname" || {
        echo "${BOLD}${RED}✗ ERROR: Failed to create directory ${YELLOW}${SOURCE_DIR}/${pkgname}${RESET}"
        exit 1
    }

    # Fetch PKGBUILD
    pkgbuild_url="${REPO_URL}/refs/heads/main/pkgbuilds/$pkgname/pkgbuild.kraken"
    echo "${BOLD}${CYAN}🌐 Downloading package recipe...${RESET}"
    if ! wget -q -P "$SOURCE_DIR/$pkgname" "$pkgbuild_url"; then
        echo "${BOLD}${RED}✗ ERROR: Failed to fetch PKGBUILD for ${YELLOW}${pkgname}${RESET}"
        exit 1
    fi

    # Extract sources and checksums
    echo "${BOLD}${CYAN}📦 Extracting package sources...${RESET}"
    source_urls=($(awk '/^sources=\(/,/\)/' "$SOURCE_DIR/$pkgname/pkgbuild.kraken" | 
                sed -e '1d;$d' -e 's/[",]//g' | xargs -n1))
    checksums=($(awk '/^md5sums=\(/,/\)/' "$SOURCE_DIR/$pkgname/pkgbuild.kraken" | 
               sed -e '1d;$d' -e 's/[",]//g' | xargs -n1))

    # Validate sources/checksums match
    if [ ${#source_urls[@]} -ne ${#checksums[@]} ]; then
        echo "${BOLD}${RED}✗ ERROR: Mismatch between ${YELLOW}${#source_urls[@]}${RED} sources and ${YELLOW}${#checksums[@]}${RED} checksums${RESET}"
        exit 1
    fi

    # Download and verify sources
    echo "${BOLD}${CYAN}📥 Downloading ${YELLOW}${#source_urls[@]}${CYAN} source files...${RESET}"
    for ((i=0; i<${#source_urls[@]}; i++)); do
        url="${source_urls[$i]}"
        checksum="${checksums[$i]}"
        tarball_name=$(basename "$url")
        
        echo "${BOLD}${CYAN}  [$(($i+1))/${#source_urls[@]}] ${MAGENTA}${tarball_name}${RESET}"
        echo "   ${YELLOW}URL: ${GRAY}${url}${RESET}"
        echo "   ${MAGENTA}Expected MD5: ${checksum}${RESET}"

        # Download file
        if ! wget -q "$url" -P "$SOURCE_DIR/$pkgname"; then
            echo "${BOLD}${RED}   ✗ Download failed${RESET}"
            exit 1
        fi

        # Verify checksum
        downloaded_checksum=$(md5sum "$SOURCE_DIR/$pkgname/$tarball_name" | awk '{print $1}')
        if [ "$downloaded_checksum" != "$checksum" ]; then
            echo "${BOLD}${RED}   ✗ Checksum mismatch: ${YELLOW}${downloaded_checksum}${RED} ≠ ${YELLOW}${checksum}${RESET}"
            exit 1
        fi
        echo "${GREEN}   ✓ Verification successful${RESET}"
    done

    echo "${BOLD}${GREEN}✅ Successfully retrieved ${YELLOW}${pkgname}${GREEN} with ${YELLOW}${#source_urls[@]}${GREEN} verified sources${RESET}"
}

# Execute main function
get_package "$1"