#!/bin/bash


BOLD=$(tput bold)
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
CYAN=$(tput setaf 6)
RESET=$(tput sgr0)


SCRIPTS_DIR="/usr/kraken/scripts"

print_help() {
    echo "${BOLD}${CYAN}Kraken Package Manager - Usage Guide${RESET}"
    echo "=============================================="
    
    echo "${BOLD}${GREEN}Usage:${RESET}"
    echo "  kraken ${YELLOW}<command>${RESET} ${BLUE}[package_name]${RESET}"
    echo ""
    
    echo "${BOLD}${GREEN}Available Commands:${RESET}"
    echo "  ${YELLOW}download${RESET}    - Download package sources"
    echo "  ${YELLOW}prepare${RESET}     - Prepare build environment"
    echo "  ${YELLOW}build${RESET}       - Compile the package"
    echo "  ${YELLOW}test${RESET}        - Run package tests"
    echo "  ${YELLOW}preinstall${RESET}  - Pre-installation checks"
    echo "  ${YELLOW}fakeinstall${RESET}  - Detect package files and directories "
    echo "  ${YELLOW}install${RESET}     - Install the package"
    echo "  ${YELLOW}postinstall${RESET} - Post-installation tasks"
    echo "  ${YELLOW}remove${RESET}      - Uninstall the package"
    
    echo "  ${YELLOW}entropy${RESET}     - Dependeny Resolution"
    echo ""
    
    echo "${BOLD}${GREEN}Examples:${RESET}"
    echo "  ${CYAN}Install a package:${RESET}"
    echo "  kraken ${YELLOW}install${RESET} ${BLUE}my-awesome-app${RESET}"
    echo ""
    echo "  ${CYAN}Build and test:${RESET}"
    echo "  kraken ${YELLOW}build${RESET} ${BLUE}my-library${RESET} && kraken ${YELLOW}test${RESET} ${BLUE}my-library${RESET}"
    echo ""
    echo "  ${CYAN}Full workflow:${RESET}"
    echo "  kraken ${YELLOW}download${RESET} ${BLUE}cool-package${RESET} && "
    echo "  kraken ${YELLOW}prepare${RESET} ${BLUE}cool-package${RESET} && "
    echo "  kraken ${YELLOW}build${RESET} ${BLUE}cool-package${RESET} && "
    echo "  kraken ${YELLOW}test${RESET} ${BLUE}cool-package${RESET} && "
    echo "  kraken ${YELLOW}preinstall${RESET} ${BLUE}cool-package${RESET} && "
    echo "  kraken ${YELLOW}faceinstall${RESET} ${BLUE}cool-package${RESET}"
    echo "  kraken ${YELLOW}install${RESET} ${BLUE}cool-package${RESET}"
    echo "  kraken ${YELLOW}postinstall${RESET} ${BLUE}cool-package${RESET}&& "

    echo ""
}

get_package(){

 local pkgname="$1"
 bash "$SCRIPTS_DIR/get_package.sh" "$pkgname"



}

checkinstalled (){

    local pkgname="$1"
 bash "$SCRIPTS_DIR/checkinstalled" "$pkgname"
}


listdependency (){

local pkgname="$1"
 bash "$SCRIPTS_DIR/extract_dep_with_awk.sh" "$pkgname" "/sources"

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
fakeinstall(){
local pkgname="$1"
 bash "$SCRIPTS_DIR/fake_install.sh" "$pkgname"


}
install(){

   local pkgname="$1"
 bash "$SCRIPTS_DIR/install.sh" "$pkgname" 
}

postinstall(){

 local pkgname="$1"
 bash "$SCRIPTS_DIR/postinstall.sh" "$pkgname"



}
remove(){
  local pkgname="$1"
 bash "$SCRIPTS_DIR/remove.sh" "$pkgname"

}



entropy(){
  local pkgname="$1"
  /usr/bin/entropy "$pkgname"
}





command="$1"
pkg_name="$2"
case "$command" in
 download)
    get_package "$pkg_name"
    ;;
listdependency)
    listdependency "$pkg_name"
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
    checkinstalled)
    checkinstalled "$pkg_name"
    ;;

    preinstall)
     preinstall "$pkg_name"
    ;;
    fakeinstall)
      fakeinstall "$pkg_name"
      ;;
    install)
    install "$pkg_name"
      ;;
    postinstall)
     postinstall "$pkg_name"
    ;;
    entropy)
    entropy "$pkg_name"
     ;;
     remove)
     remove "$pkg_name"
     ;;



*)
        print_help
        exit 1
        ;;
esac
