#!/bin/bash


SCRIPTS_DIR="/home/pkg/kraken_package_manager/scripts"

get_package(){

 local pkgname="$1"
 bash "$SCRIPTS_DIR/get_package.sh" "$pkgname"



}

prepare (){

    local pkgname="$1"
 bash "$SCRIPTS_DIR/prepare.sh" "$pkgname"
}

build(){

 local pkgname="$1"
 bash "$SCRIPTS_DIR/build.sh" "$pkgname"



}

test(){

local pkgname="$1"
 bash "$SCRIPTS_DIR/test.sh" "$pkgname"

}

preinstall(){

 local pkgname="$1"
 bash "$SCRIPTS_DIR/preinstall.sh" "$pkgname"



}

install(){

   local pkgname="$1"
 bash "$SCRIPTS_DIR/install.sh" "$pkgname" 
}

postinstall(){

 local pkgname="$1"
 bash "$SCRIPTS_DIR/postinstall.sh" "$pkgname"



}






command="$1"
pkg_name="$2"
case "$command" in
 download)
    get_package "$pkg_name"
    ;;

    prepare)
    prepare "$pkg_name"
    ;;
    
    build)
    build "$pkg_name"
    ;;
    test)
    test "$pkg_name"
    ;;
    preinstall)
     preinstall "$pkg_name"
    ;;
    install)
    install "$pkg_name"
      ;;
    postinstall)
     postinstall "$pkg_name"
    ;;




*)
        echo "Usage: $0 {download|prepare|build|test|preinstall|install|postinstall} <package_name>"
        exit 1
        ;;
esac