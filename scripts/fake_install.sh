#!/bin/sh




SOURCE_DIR="/sources"
METADATA_DIR="/var/lib/kraken/packages"
TRACE_LOG="/tmp/kraken_strace.log"
FAKEROOT_CMD="fakeroot"


export SOURCE_DIR
export METADATA_DIR
export FAKEROOT_CMD



DB_FILE="/var/lib/kraken/db/kraken.db"
CACHE_DIR="$HOME/.cache/krakenpm"

INDEX_CACHE="$CACHE_DIR/pkgindex.kraken"


BOLD="\033[1m"
CYAN="\033[36m"
GREEN="\033[32m"
YELLOW="\033[33m"
RED="\033[31m"
RESET="\033[0m"

fake_inst() {
    
    pkgname="$1"
    [ -z "$pkgname" ] && {
        printf "${BOLD}${RED}✗ Package name not specified${RESET}\n" >&2
        return 1
    }

    pkgbuild="${SOURCE_DIR}/${pkgname}/pkgbuild.kraken"
    [ ! -f "$pkgbuild" ] && {
        printf "${BOLD}${RED}✗ PKGBUILD not found: ${YELLOW}%s${RESET}\n" "$pkgbuild" >&2
        return 1
    }

   pkgver=$(awk -F= '/^pkgver=/ {print $2; exit}' "$pkgbuild")
   [ -z "$pkgver" ] && {
        printf "${BOLD}${RED}✗ Failed to detect package version${RESET}\n" >&2
        return 1
    }
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

builded_status=$(check_steps "$pkg_id" "builded")


if [ -z "$builded_status" ]; then
    echo "Package not found in database"
    exit 1
elif [ "$builded_status" -ne 1 ]; then
    echo "You must run kraken build $pkgname first"
    exit 1
fi













    staging_dir="/tmp/${pkgname}-${pkgver}"
    metadata_dir="${METADATA_DIR}/${pkgname}-${pkgver}"

    printf "${BOLD}${CYAN}==> Fake installing ${YELLOW}%s-%s${RESET}\n" "$pkgname" "$pkgver"

    
    sudo rm -rf "$staging_dir" 2>/dev/null
    mkdir -p "$staging_dir" || return 1

   
    export DESTDIR="$staging_dir"
    export FAKED_MODE="isolated"
    export TMPDIR="${staging_dir}/tmp"
    mkdir -p "$TMPDIR" || return 1

   
    if ! . "$pkgbuild"; then
        printf "${BOLD}${RED}✗ Failed to load PKGBUILD${RESET}\n" >&2
        return 1
    fi

   
    if ! command -v kraken_install >/dev/null; then
        printf "${BOLD}${RED}✗ Missing kraken_install() in PKGBUILD${RESET}\n" >&2
        return 1
    fi

   
    printf "${BOLD}${CYAN}==> Tracing installation...${RESET}\n"
    [ -f "$TRACE_LOG" ] && sudo rm -f "$TRACE_LOG"

    if ! $FAKEROOT_CMD strace -f -D \
        -e trace=openat,creat,open,mkdir,rename,link,symlink,unlink,execve \
        -o "$TRACE_LOG" \
        sh -c "
            set -eo pipefail
            . '$pkgbuild' || exit 1
            kraken_install || exit 1
        "; then
        printf "${BOLD}${RED}✗ Installation tracing failed${RESET}\n" >&2
        return 1
    fi

   
    [ ! -s "$TRACE_LOG" ] && {
        printf "${BOLD}${RED}✗ Empty strace log generated${RESET}\n" >&2
        return 1
    }

   
    sudo mkdir -p "$metadata_dir" || {
        printf "${BOLD}${RED}✗ Failed to create metadata directory${RESET}\n" >&2
        return 1
    }

   
    printf "${BOLD}${CYAN}==> Generating file manifests...${RESET}\n"
    files_list="${metadata_dir}/FILES"
    dirs_list="${metadata_dir}/DIRS"

    
    sudo rm -rf "$files_list" "$dirs_list" 2>/dev/null
    sudo touch "$files_list" "$dirs_list" || return 1

    
    if ! awk -v staging="$staging_dir" '
        BEGIN { FS = "[\"]" }
        /openat.*O_CREAT/ || /creat\(/ || /mkdir\(/ || /rename\(/ {
            if ($0 ~ staging) {
                gsub(/"/, "", $0)
                split($0, parts, staging)
                path = parts[2]
                if (path != "") print path
            }
        }
        /execve/ && /\/bin\/install/ {
            for (i=3; i<=NF; i++) {
                if ($i ~ staging) {
                    gsub(/"/, "", $i)
                    split($i, parts, staging)
                    print parts[2]
                }
            }
        }
    ' "$TRACE_LOG" | sort -u | sudo tee "$files_list" >/dev/null; then
        printf "${BOLD}${RED}✗ Failed to process trace log${RESET}\n" >&2
        return 1
    fi

   
    [ ! -s "$files_list" ] && {
        printf "${BOLD}${RED}✗ No files recorded in manifest${RESET}\n" >&2
        return 1
    }

    
    if ! sudo awk '!/-/ {print $0}' "$files_list" | \
        xargs -r -n1 dirname | \
        sort -u | \
        sudo tee "$dirs_list" >/dev/null; then
        printf "${BOLD}${RED}✗ Failed to generate directory list${RESET}\n" >&2
        return 1
    fi

   
    printf "${BOLD}${CYAN}==> Validating directories...${RESET}\n"
    critical_dirs="^/$\|^/boot\|^/dev\|^/proc\|^/sys\|^/root\|^/home"
    if [ -s "$dirs_list" ] && grep -q "$critical_dirs" "$dirs_list"; then
        printf "${BOLD}${RED}⚠ Dangerous directories detected in:${RESET}\n"
        grep "$critical_dirs" "$dirs_list" | sed "s/^/  ${YELLOW}➜${RESET} /"
        return 1
    fi

   
    sudo cp "$pkgbuild" "${metadata_dir}/pkgbuild.kraken" || {
        printf "${BOLD}${RED}✗ Failed to archive PKGBUILD${RESET}\n" >&2
        return 1
    }

    
    sudo chmod 0644 "$files_list" "$dirs_list" || {
        printf "${BOLD}${RED}✗ Failed to set file permissions${RESET}\n" >&2
        return 1
    }



source /var/lib/kraken/db/kraken_db.sh

   if ! mark_fake_installed "$pkg_id"; then
    echo "${RED}Failed to update fakeinstalld status${RESET}"
    exit 1
fi








    printf "${BOLD}${GREEN}✓ Fake install completed for ${YELLOW}%s-%s${RESET}\n" "$pkgname" "$pkgver"
    return 0
}

# Main execution
fake_inst "$@"
