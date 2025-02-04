dir_filtring() {
    pkgname="$1"
    pkgver="$2"

    metadata_dir="/var/lib/kraken/packages"
    input_file="${metadata_dir}/${pkgname}-${pkgver}/DIRS"
     sudo chmod a=rwx "$input_file"
    # Ensure input file exists
    if [ ! -f "$input_file" ]; then
        echo "Error: $input_file does not exist."
        return 1
    fi

    # Temporary file to store filtered output
    temp_file=$(mktemp) || { echo "Error: Unable to create temporary file."; return 1; }

    # Define protected paths
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


    # Loop through each line in the input file
    while IFS= read -r line; do
        # Trim whitespace from the line
        line=$(echo "$line" | xargs)

        # Check if the line matches any protected path
        match=0
        for protected_path in "${protected_paths[@]}"; do
            # Debugging output
            echo "Comparing: '$line' with protected path: '$protected_path'"
            if [ "$line" == "$protected_path" ]; then
                match=1
                break
            fi
        done

        # If no match, write the line to the temporary file
        if [ $match -eq 0 ]; then
            echo "$line is fine"
            echo "$line" >> "$temp_file"
        else
            echo "$line is protected and will be filtered out."
        fi
    done < "$input_file"

    echo "Filtered output:"
    sudo cat "$temp_file"

    # If the filtering was successful, replace the original file
    if [ $? -eq 0 ]; then
        sudo mv "$temp_file" "$input_file"
        echo "Filtered metadata saved to $input_file"
    else
        echo "Error: Failed to filter the directory list."
        sudo rm -f "$temp_file"
    fi
}