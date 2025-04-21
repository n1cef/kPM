#!/bin/bash

[ $# -eq 0 ] && exit 1

DB_FILE="/var/lib/kraken/db/kraken.db"
PKG_NAME="$1"
version="$2"

sqlite3 "$DB_FILE" <<EOF

exists=$(sqlite3 "$DB_FILE" "SELECT id FROM packages WHERE ((name ='$PKG_NAME') AND 
(installed='1')  (version='$version');")




if [ -n "$exists" ]; then 
    exit 1 
fi  


else 

exit 0

EOF








#command -v "$PKG_NAME" >/dev/null 2>&1 && exit 0


#if command -v which >/dev/null 2>&1; then
#    which "$PKG_NAME" >/dev/null 2>&1 && exit 0
#fi

#if command -v pkg-config >/dev/null 2>&1; then
#    pkg-config --exists "$PKG_NAME" >/dev/null 2>&1 && exit 0
#fi

#for pkg_dir in /var/lib/kraken/"$PKG_NAME"-*; do
 #   if [ -d "$pkg_dir" ]; then
 #       exit 0
 #   fi
#done 2>/dev/null

#if all checks are failed as expected
#exit 1 