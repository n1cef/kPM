#!/bin/bash


SCRIPTS_DIR="../scripts"

get_package(){

 local pkgname="$1"
 bash "$SCRIPTS_DIR/get_package.sh" "$pkg_name"



}

prepare (){

    local pkgname="$1"
 bash "$SCRIPTS_DIR/prepare.sh" "$pkg_name"
}

build(){

 local pkgname="$1"
 bash "$SCRIPTS_DIR/build.sh" "$pkg_name"



}

preinstall(){

 local pkgname="$1"
 bash "$SCRIPTS_DIR/preinstall.sh" "$pkg_name"



}

install(){

   local pkgname="$1"
 bash "$SCRIPTS_DIR/install.sh" "$pkg_name" 
}

postinstall(){

 local pkgname="$1"
 bash "$SCRIPTS_DIR/postinstall.sh" "$pkg_name"



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
        echo "Usage: $0 {download|prepare|build|preinstall|install|postinstall} <package_name>"
        exit 1
        ;;
esac