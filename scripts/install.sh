#!/bin/sh

# Configuration
SOURCE_DIR="/sources"
METADATA_DIR="/var/lib/kraken/packages"

# Color definitions
BOLD="\033[1m"
CYAN="\033[36m"
GREEN="\033[32m"
YELLOW="\033[33m"
RED="\033[31m"
RESET="\033[0m"

# Argument check
pkgname="$1"
[ -z "$pkgname" ] && {
    printf "${BOLD}${RED}✗ Package name not specified${RESET}\n"
    exit 1
}

# Load package metadata
pkgbuild="$SOURCE_DIR/$pkgname/pkgbuild.kraken"
[ ! -f "$pkgbuild" ] && {
    printf "${BOLD}${RED}✗ PKGBUILD not found: ${YELLOW}%s${RESET}\n" "$pkgbuild"
    exit 1
}

pkgver=$(awk -F= '/^pkgver=/ {print $2; exit}' "$pkgbuild")
sudo mkdir -pv "/tmp/$pkgname-$pkgver"
staging_dir="/tmp/$pkgname-$pkgver"

printf "${BOLD}${CYAN}==> Installing ${YELLOW}%s-%s${RESET}\n" "$pkgname" "$pkgver"

# Execute real installation
printf "${BOLD}${CYAN}==> Staging installation...${RESET}\n"
if ! . "$pkgbuild" || ! command -v kraken_install >/dev/null; then
    printf "${BOLD}${RED}✗ Invalid PKGBUILD: Missing install function${RESET}\n"
    exit 1
fi

# Copy staged files to root
printf "${BOLD}${CYAN}==> Deploying filesystem changes...${RESET}\n"
sudo rsync -a "$staging_dir/" / || {
    printf "${BOLD}${RED}✗ Filesystem deployment failed${RESET}\n"
    exit 1
}

# Register package
printf "${BOLD}${CYAN}==> Finalizing installation...${RESET}\n"
sudo mkdir -p "$METADATA_DIR/$pkgname-$pkgver" || exit 1
printf "%s\n" "$pkgver" | sudo tee "$METADATA_DIR/$pkgname-$pkgver" >/dev/null

printf "${BOLD}${GREEN}✓ Successfully installed ${YELLOW}%s-%s${RESET}\n" "$pkgname" "$pkgver"
exit 0
