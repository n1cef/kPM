#!/bin/sh
set -e

# Safety checks
if [ "$(id -u)" -ne 0 ]; then
    echo "✗ This script must be run as root" >&2
    exit 1
fi

printf "This will PERMANENTLY remove Kraken. Continue? [y/N] "
read -r answer
case "$answer" in
    [yY][eE][sS]|[yY]) ;;
    *) exit 1 ;;
esac

# Meson-tracked files
if [ -d "build" ]; then
    ninja -C build uninstall
fi

# Package-specific directories
clean_dirs=(
    "/usr/kraken"
    "/var/lib/kraken"
    "/sources/kraken" 
    "/tmp/kraken_strace.log"
)

# Safer removal with explicit paths
for path in "${clean_dirs[@]}"; do
    if [ -e "$path" ]; then
        echo "Removing: $path"
        rm -rf "$path"
    fi
done

# Symlinks
clean_symlinks=(
    "/usr/bin/kraken"
    "/usr/bin/entropy"
)

for link in "${clean_symlinks[@]}"; do
    if [ -L "$link" ]; then
        echo "Removing symlink: $link"
        rm -f "$link"
    fi
done

echo "✓ Kraken fully uninstalled"