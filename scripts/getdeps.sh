#!/bin/bash
pkgname="$1"
version="$2"

CACHE_DIR="$HOME/.cache/krakenpm"

INDEX_CACHE="$CACHE_DIR/pkgindex.kraken"
yq eval '.packages["'"$pkgname"'"] | select(.version == "'"$version"'") | .dependencies[]' "$INDEX_CACHE"