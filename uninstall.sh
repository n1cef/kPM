#!/bin/sh
set -e


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


if [ -d "build" ]; then
    ninja -C build uninstall
fi


clean_dirs=(
    "/usr/kraken/include"
    "/usr/kraken/scripts"
    "/usr/kraken"
    "/var/lib/kraken/db"
    "/var/lib/kraken/packages"
    "/var/lib/kraken"
    "/sources/kraken" 
    "/tmp/kraken_strace.log"
    "/root/.cache/krakenpm"
    "/usr/bin/kraken"
    "/usr/bin/entropy"
    "/usr/bin/kraken-uninstall"
    "/usr/bin/checkinstalled"
)


for path in "${clean_dirs[@]}"; do
    if [ -e "$path" ]; then
        echo "Removing: $path"
        rm -Rf "$path"
    fi
done



# TBD: WE NEED TO HANDLE THIS SHIT LATER  SYMILINKSPROBLEM (he cant detect entropy and kraken and kraken uninstall ) 
#clean_symlinks=(
 #   "/usr/bin/kraken"
  #  "/usr/bin/entropy"
   # "/usr/bin/kraken-uninstall"
   # "/usr/bin/checkinstalled"
#)

#for link in "${clean_symlinks[@]}"; do
 #   if [ -L "$link" ]; then
  #      echo "Removing symlink: $link"
   #     rm -Rf "$link"
    
   # else
#	rm -Rf "$link"
 #   fi
#done

echo "✓ Kraken fully uninstalled"
