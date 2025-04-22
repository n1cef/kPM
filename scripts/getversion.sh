#!/bin/bash
pkgname="$1"
CACHE_DIR="$HOME/.cache/krakenpm"

INDEX_CACHE="$CACHE_DIR/pkgindex.kraken"
yq eval ".packages.$pkgname.version" "$INDEX_CACHE"