dir_filtring() {
    # Color Definitions
    BOLD=$(tput bold)
    CYAN=$(tput setaf 6)
    GREEN=$(tput setaf 2)
    YELLOW=$(tput setaf 3)
    RED=$(tput setaf 1)
    GRAY=$(tput setaf 8)
    RESET=$(tput sgr0)

    pkgname="$1"
    pkgver="$2"

    metadata_dir="/var/lib/kraken/packages"
    input_file="${metadata_dir}/${pkgname}-${pkgver}/DIRS"
    
    echo "${BOLD}${CYAN}=== Directory Filtering: ${YELLOW}${pkgname}-${pkgver} ${CYAN}===${RESET}"

    # File permission handling
    echo "${BOLD}${CYAN}⌛ Setting file permissions...${RESET}"
    if ! sudo chmod a=rwx "$input_file" 2>/dev/null; then
        echo "${BOLD}${RED}✗ ERROR: Permission denied for ${YELLOW}${input_file}${RESET}"
        return 1
    fi

    # Input file validation
    if [ ! -f "$input_file" ]; then
        echo "${BOLD}${RED}✗ ERROR: Missing directory list at ${YELLOW}${input_file}${RESET}"
        return 1
    fi

    # Create temporary file
    echo "${BOLD}${CYAN}⌛ Creating temporary workspace...${RESET}"
    temp_file=$(mktemp) || {
        echo "${BOLD}${RED}✗ ERROR: Failed to create temporary file${RESET}"
        return 1
    }

    protected_paths=(
    "/"
    "/dev"
    "/dev/block"
    "/dev/disk"
    "/dev/input"
    "/dev/shm"
    "/dev/bsg"
    "/dev/dma_heap"
    "/dev/mapper"
    "/dev/snd"
    "/dev/bus"
    "/dev/dri"
    "/dev/mqueue"
    "/dev/vfio"
    "/dev/char"
    "/dev/fd"
    "/dev/net"
    "/dev/cpu"
    "/dev/hugepages"
    "/dev/pts"
    "/bin"
    "/boot"
    "/boot/grub"
    "/lib"
    "/home"
    "/etc"
    "/mnt"
    "/opt"
    "/proc"
    "/root"
    "/run"
    "/sbin"
    "/sources"
    "/srv"
    "/sys"
    "/sys/block"
    "/sys/dev"
    "/sys/fs"
    "/sys/module"
    "/sys/bus"
    "/sys/devices"
    "/sys/hypervisor"
    "/sys/power"
    "/sys/class"
    "/sys/firmware"
    "/sys/kernel"
    "/tmp"
    "/var"
    "/var/cache"
    "/var/games"
    "/var/lock"
    "/var/opt"
    "/var/tmp"
    "/var/db"
    "/var/lib"
    "/var/log"
    "/var/run"
    "/var/empty"
    "/var/local"
    "/var/mail"
    "/var/spool"
    "/usr"
    "/usr/bin"
    "/usr/include"
    "/usr/lib"
    "/usr/lib32"
    "/usr/lib64"
    "/usr/local"
    "/usr/local/bin"
    "/usr/local/games"
    "/usr/local/lib"
    "/usr/local/sbin"
    "/usr/local/src"
    "/usr/local/etc"
    "/usr/local/include"
    "/usr/local/man"
    "/usr/local/share"
    "/usr/sbin"
    "/usr/share"
    "/usr/src"
)

    echo "${BOLD}${CYAN}🔍 Scanning directories (${YELLOW}${protected_paths[@]:0:3}...${RESET})"
    echo "${GRAY}ℹ Protected paths list contains ${#protected_paths[@]} entries${RESET}"

    # Processing loop
    while IFS= read -r line; do
        line=$(echo "$line" | xargs)
        [ -z "$line" ] && continue

        match=0
        for protected_path in "${protected_paths[@]}"; do
            if [ "$line" == "$protected_path" ]; then
                match=1
                break
            fi
        done

        if [ $match -eq 0 ]; then
            echo "${GREEN}✓ Allowed: ${YELLOW}${line}${RESET}"
            echo "$line" >> "$temp_file"
        else
            echo "${RED}✗ Blocked: ${GRAY}${line}${RESET}"
        fi
    done < "$input_file"

    # Final output handling
    echo "${BOLD}${CYAN}\n📋 Filtered directory list:${RESET}"
    sudo cat "$temp_file" | sed "s/^/  ${GRAY}│ ${RESET}/"

    if [ $? -eq 0 ]; then
        echo "${BOLD}${CYAN}\n⌛ Saving filtered results...${RESET}"
        sudo mv "$temp_file" "$input_file"
        echo "${GREEN}✓ Successfully filtered ${YELLOW}$(wc -l < "$input_file") ${GREEN}directories${RESET}"
    else
        echo "${BOLD}${RED}\n✗ ERROR: Failed to filter directory list${RESET}"
        sudo rm -f "$temp_file"
        return 1
    fi
}