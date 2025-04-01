manual_remove() {
    # Color Definitions
    BOLD=$(tput bold)
    CYAN=$(tput setaf 6)
    GREEN=$(tput setaf 2)
    YELLOW=$(tput setaf 3)
    RED=$(tput setaf 1)
    MAGENTA=$(tput setaf 5)
    RESET=$(tput sgr0)

    pkgname="$1"
    pkgver="$2"

    echo "${BOLD}${CYAN}=== Manual Removal: ${YELLOW}${pkgname}-${pkgver} ${CYAN}===${RESET}"

    # Validate arguments
    if [ -z "$pkgname" ] || [ -z "$pkgver" ]; then
        echo "${BOLD}${RED}✗ ERROR: Missing arguments. Usage: manual_remove <pkgname> <pkgver>${RESET}"
        exit 1
    fi

    local package_path="/var/lib/kraken/packages/${pkgname}-${pkgver}"
    local files_list="${package_path}/FILES"

    # Validate files list
    if [ ! -f "$files_list" ]; then
        echo "${BOLD}${RED}✗ ERROR: FILES list not found at ${YELLOW}${files_list}${RESET}"
        exit 1
    fi

    echo "${BOLD}${CYAN}🗑 Beginning removal process for ${YELLOW}${pkgname}-${pkgver}${RESET}"

    # File removal process
    local removed_count=0
    local skipped_count=0
    local warning_count=0

    while IFS= read -r file; do
        if [ -f "$file" ]; then
            echo "${GREEN}✓ Removing file: ${YELLOW}${file}${RESET}"
            sudo rm -f "$file" && ((removed_count++))
        elif [ -d "$file" ]; then
            echo "${YELLOW}⚠ Skipping directory: ${MAGENTA}${file}${RESET}"
            ((skipped_count++))
        else
            echo "${RED}✗ WARNING: Not found ${GRAY}${file}${RESET}"
            ((warning_count++))
        fi
    done < "$files_list"

    # Clean up metadata
    echo "${BOLD}${CYAN}🧹 Cleaning package metadata...${RESET}"
    if sudo rm -rf "$package_path"; then
        echo "${GREEN}✓ Removed metadata from ${YELLOW}${package_path}${RESET}"
    else
        echo "${RED}✗ ERROR: Failed to remove metadata directory${RESET}"
        exit 1
    fi

    # Summary report
    echo "${BOLD}${CYAN}📝 Removal Summary:${RESET}"
    echo "${GREEN}  Files removed:   ${removed_count}${RESET}"
    echo "${YELLOW}  Directories skipped: ${skipped_count}${RESET}"
    echo "${RED}  Warnings:        ${warning_count}${RESET}"
    echo "${BOLD}${GREEN}✅ Successfully removed ${YELLOW}${pkgname}-${pkgver}${RESET}"
}