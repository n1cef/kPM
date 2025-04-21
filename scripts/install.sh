#!/bin/sh


SOURCE_DIR="/sources"
METADATA_DIR="/var/lib/kraken/packages"

DB_FILE="/var/lib/kraken/db/kraken.db"
CACHE_DIR="$HOME/.cache/krakenpm"

INDEX_CACHE="$CACHE_DIR/pkgindex.kraken"

install (){
BOLD="\033[1m"
CYAN="\033[36m"
GREEN="\033[32m"
YELLOW="\033[33m"
RED="\033[31m"
RESET="\033[0m"


pkgname="$1"
[ -z "$pkgname" ] && {
    printf "${BOLD}${RED}✗ Package name not specified${RESET}\n"
    exit 1
}


pkgbuild="$SOURCE_DIR/$pkgname/pkgbuild.kraken"
[ ! -f "$pkgbuild" ] && {
    printf "${BOLD}${RED}✗ PKGBUILD not found: ${YELLOW}%s${RESET}\n" "$pkgbuild"
    exit 1
}
echo "pkgbuild is $pkgbuild"

local version=$(yq eval ".packages.$pkgname.version" "$INDEX_CACHE") 

    [ -z "$version" ] && {
        printf "${BOLD}${RED}✗ Failed to detect package version${RESET}\n" >&2
        return 1
    }


source /var/lib/kraken/db/kraken_db.sh

pkg_id=$(get_pkg_id "$pkgname" "$version")
if [ -z "$pkg_id" ]; then  
    echo "${RED}Package not found in database${RESET}"
    exit 1
fi

fakeinstalled_status=$(check_steps "$pkg_id" "fakeinstalled")


if [ -z "$fakeinstalled_status" ]; then
    echo "Package not found in database"
    exit 1
elif [ "$fakeinstalled_status" -ne 1 ]; then
    echo "You must run kraken fakeinstall $pkgname first"
    exit 1
fi




pkgver=$(awk -F= '/^pkgver=/ {print $2; exit}' "$pkgbuild")
sudo mkdir -pv "/tmp/$pkgname-$pkgver"
staging_dir="/tmp/$pkgname-$pkgver"

printf "${BOLD}${CYAN}==> Installing ${YELLOW}%s-%s${RESET}\n" "$pkgname" "$pkgver"


printf "${BOLD}${CYAN}==> Staging installation...${RESET}\n"
if ! . "$pkgbuild"; then
	   printf "${BOLD}${RED}✗ Failed to load PKGBUILD${RESET}\n"
	       exit 1
fi

if ! command -v kraken_install >/dev/null; then
	   printf "${BOLD}${RED}✗ Missing kraken_install() in PKGBUILD${RESET}\n"
	       exit 1
fi

#  RUN THE INSTALL FUNCTION 
 printf "${BOLD}${CYAN}==> Executing installation steps...${RESET}\n"
 kraken_install || {
     printf "${BOLD}${RED}✗ Installation failed${RESET}\n"
         exit 1
         }


printf "${BOLD}${CYAN}==> Deploying filesystem changes...${RESET}\n"
sudo rsync -a "$staging_dir/" / || {
    printf "${BOLD}${RED}✗ Filesystem deployment failed${RESET}\n"
    exit 1
}


source /var/lib/kraken/db/kraken_db.sh

   if ! mark_installed "$pkg_id"; then
    echo "${RED}Failed to update installed status${RESET}"
    exit 1
fi





printf "${BOLD}${CYAN}==> Finalizing installation...${RESET}\n"

printf "${BOLD}${GREEN}✓ Successfully installed ${YELLOW}%s-%s${RESET}\n" "$pkgname" "$pkgver"
exit 0

}


install "$1"