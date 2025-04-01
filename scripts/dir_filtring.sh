#!/bin/sh

# Configuration
METADATA_DIR="/var/lib/kraken/packages"

# Color definitions
BOLD="\033[1m"
RED="\033[31m"
YELLOW="\033[33m"
RESET="\033[0m"

dir_filtring() {
    pkgname="$1"
    pkgver="$2"
    [ -z "$pkgname" ] || [ -z "$pkgver" ] && return 1

    dirs_file="$METADATA_DIR/$pkgname-$pkgver/DIRS"
    [ ! -f "$dirs_file" ] && return 1

    critical_dirs="/ /boot /dev /proc /sys /root /home"

    while IFS= read -r dir; do
        for critical in $critical_dirs; do
            if [ "$dir" = "$critical" ]; then
                printf "${BOLD}${RED}✗ Critical directory violation: ${YELLOW}%s${RED} in %s${RESET}\n" \
                    "$dir" "$pkgname" >&2
                return 1
            fi
        done
    done < "$dirs_file"

    return 0
}

# Main execution
[ $# -ne 2 ] && {
    printf "Usage: %s <package> <version>\n" "$0"
    exit 1
}

dir_filtring "$1" "$2"