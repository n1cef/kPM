#!/bin/bash

SOURCE_DIR="/sources"
REPO_URL="https://raw.githubusercontent.com/n1cef/kraken_repository"

get_package() {

    BOLD=$(tput bold)
    CYAN=$(tput setaf 6)
    GREEN=$(tput setaf 2)
    YELLOW=$(tput setaf 3)
    RED=$(tput setaf 1)
    MAGENTA=$(tput setaf 5)
    RESET=$(tput sgr0)

    pkgname="$1"
    echo "${BOLD}${CYAN}=== Fetching Package: ${YELLOW}${pkgname} ${CYAN}===${RESET}"

 
    if [ -z "$pkgname" ]; then
        echo "${BOLD}${RED}✗ ERROR: Package name not specified${RESET}"
        exit 1
    fi




    echo "${BOLD}${CYAN}🔍 Checking installation status...${RESET}"
    if sudo kraken checkinstalled "$pkgname" >/dev/null 2>&1; then
        echo "${BOLD}${YELLOW}⚠ WARNING: ${YELLOW}${pkgname} is already installed!${RESET}"
        read -p "${BOLD}${CYAN}Do you want to download and reinstall it? [y/N] ${RESET}" response
        case "${response,,}" in  # Convert to lowercase
            y|yes)
                echo "${BOLD}${CYAN}▶ Proceeding with download...${RESET}"
                ;;
            *)
                echo "${BOLD}${GREEN}✅ Operation canceled by user.${RESET}"
                exit 0
                ;;
        esac
    else
        echo "${BOLD}${GREEN}✅ ${YELLOW}${pkgname}${GREEN} is not installed. Proceeding...${RESET}"
    fi

   
    if ! command -v curl &> /dev/null; then
        echo "${BOLD}${RED}✗ ERROR: curl is required but not installed${RESET}"
        exit 1
    fi

    echo "${BOLD}${CYAN}⌛ Preparing workspace...${RESET}"
    mkdir -p "$SOURCE_DIR/$pkgname" || {
        echo "${BOLD}${RED}✗ ERROR: Failed to create directory ${YELLOW}${SOURCE_DIR}/${pkgname}${RESET}"
        exit 1
    }

  
    pkgbuild_url="${REPO_URL}/refs/heads/main/pkgbuilds/$pkgname/pkgbuild.kraken"
    echo "${BOLD}${CYAN}🌐 Downloading package recipe...${RESET}"
    if ! curl -sSL -o "$SOURCE_DIR/$pkgname/pkgbuild.kraken" "$pkgbuild_url"; then
        echo "${BOLD}${RED}✗ ERROR: Failed to fetch PKGBUILD for ${YELLOW}${pkgname}${RESET}"
        exit 1
    fi

   
    echo "${BOLD}${CYAN}📦 Extracting package sources...${RESET}"
    source_urls=($(awk '/^sources=\(/,/\)/' "$SOURCE_DIR/$pkgname/pkgbuild.kraken" | 
                sed -e '1d;$d' -e 's/[",]//g' | xargs -n1))
    checksums=($(awk '/^md5sums=\(/,/\)/' "$SOURCE_DIR/$pkgname/pkgbuild.kraken" | 
               sed -e '1d;$d' -e 's/[",]//g' | xargs -n1))

    if [ ${#source_urls[@]} -ne ${#checksums[@]} ]; then
        echo "${BOLD}${RED}✗ ERROR: Mismatch between ${YELLOW}${#source_urls[@]}${RED} sources and ${YELLOW}${#checksums[@]}${RED} checksums${RESET}"
        exit 1
    fi

    
    echo "${BOLD}${CYAN}📥 Downloading ${YELLOW}${#source_urls[@]}${CYAN} source files...${RESET}"
    for ((i=0; i<${#source_urls[@]}; i++)); do
        url="${source_urls[$i]}"
        checksum="${checksums[$i]}"
        tarball_name=$(basename "$url")
        
        echo "${BOLD}${CYAN}  [$(($i+1))/${#source_urls[@]}] ${MAGENTA}${tarball_name}${RESET}"
        echo "   ${YELLOW}URL: ${url}${RESET}"
        echo "   ${MAGENTA}Expected MD5: ${checksum}${RESET}"

       
        if ! curl -L -# -o "$SOURCE_DIR/$pkgname/$tarball_name" "$url"; then
            echo "${BOLD}${RED}   ✗ Download failed${RESET}"
            exit 1
        fi

       
        downloaded_checksum=$(md5sum "$SOURCE_DIR/$pkgname/$tarball_name" | awk '{print $1}')
        if [ "$downloaded_checksum" != "$checksum" ]; then
            echo "${BOLD}${RED}   ✗ Checksum mismatch: ${YELLOW}${downloaded_checksum}${RED} ≠ ${YELLOW}${checksum}${RESET}"
            exit 1
        fi
        echo "${GREEN}   ✓ Verification successful${RESET}"
    done

    echo "${BOLD}${GREEN}✅ Successfully retrieved ${YELLOW}${pkgname}${GREEN} with ${YELLOW}${#source_urls[@]}${GREEN} verified sources${RESET}"
}


get_package "$1"
