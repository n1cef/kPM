
#!/bin/bash

# Define the source directory
SOURCE_DIR="/sources"
REPO_URL="https://raw.githubusercontent.com/n1cef/kraken_repository"
 pkgname="$1"

dir_filtring() {
    pkgname="$1"
    pkgver=$(awk -F '=' '/^pkgver=/ {print $2}' "$SOURCE_DIR/$pkgname/pkgbuild.kraken")
    echo "Package version is: $pkgver"

    metadata_dir="/var/lib/kraken/packages"

    # Input metadata file
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
    "/bin"
    "/boot"
    "/boot/grub"
    "/boot/fonts"
    "/boot/i386-pc"
    "/boot/locale"
    "/boot/themes"
    "/dev"
    "/dev/block"
    "/dev/bsg"
    "/dev/bus"
    "/dev/char"
    "/dev/cpu"
    "/dev/disk"
    "/dev/dma_heap"
    "/dev/dri"
    "/dev/fd"
    "/dev/hugepages"
    "/dev/input"
    "/dev/mapper"
    "/dev/mqueue"
    "/dev/net"
    "/dev/pts"
    "/dev/shm"
    "/dev/snd"
    "/dev/vfio"
    "/etc"
    "/dev/NetworkManager"
    "/dev/conf.d"
    "/dev/depmod.d"
    "/dev/initcpio"
    "/dev/libnl"
    "/dev/openldap"
    "/dev/rc_keymaps"
    "/dev/sudoers.d"
    "/dev/xdg"
    "/dev/X11"
    "/dev/credstore.encrypted"
    "/dev/fonts"
    "/dev/iptables"
    "/dev/makepkg.conf.d"
    "/dev/pacman.d"
    "/dev/request-key.d"
    "/dev/sysctl.d"
    "/dev/audisp"
    "/dev/credstore"
    "/dev/gdb"
    "/dev/jack"
    "/dev/mkinitcpio.conf.d"
    "/dev/pam.d"
    "/dev/security"
    "/dev/systemd"
    "/dev/audit"
    "/dev/cryptsetup-keys.d"
    "/dev/gnutls"
    "/dev/kernel"
    "/dev/mkinitcpio.d"
    "/dev/pkcs11"
    "/dev/sensors.d"
    "/dev/tmpfiles.d"
    "/dev/avahi"
    "/dev/dconf"
    "/dev/grub.d"
    "/dev/keyutils"
    "/dev/modprobe.d"
    "/dev/polkit-1"
    "/dev/skel"
    "/dev/tpm2-tss"
    "/dev/binfmt.d"
    "/dev/debuginfod"
    "/dev/gtk-3.0"
    "/dev/ld.so.conf.d"
    "/dev/modules-load.d"
    "/dev/profile.d"
    "/dev/ssh"
    "/dev/udev"
    "/dev/ca-certificates"
    "/dev/default"
    "/dev/i3"
    "/dev/libinput"
    "/dev/nginx"
    "/dev/pulse"
    "/dev/ssl"
    "/dev/wpa_supplicant"
    "/home"
    "/lib"
    "/lib64"
    "/mnt"
    "/opt"
    "/proc"
    "/root"
    "/run"
    "/sbin"
    "/sources"
    "/srv"
    "/sys"
    "/tmp"
    "/var"
    "/usr"
    "/usr/bin"
    "/usr/include"
    "/usr/lib"
    "/usr/lib32"
    "/usr/lib64"
    "/usr/local"
    "/usr/local/bin"
    "/usr/local/etc"
    "/usr/local/games"
    "/usr/local/include"
    "/usr/local/lib"
    "/usr/local/man"
    "/usr/local/sbin"
    "/usr/local/share"
    "/usr/local/src"
    "/usr/sbin"
    "/usr/share"
    "/usr/src"     


        
    )

# Loop through each line in the input file
    while IFS= read -r line; do
        # Check if the line matches any protected path
        match=0
        for protected_path in "${protected_paths[@]}"; do
            if [ "$line" == "$protected_path" ]; then
                match=1
                break
            fi
        done

        # If no match, write the line to the temporary file
        if [ $match -eq 0 ]; then
        echo "$line is fine "
            echo "$line" >> "$temp_file"
        fi
    done < "$input_file"
      echo "temp file is "
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

dir_filtring "$1"