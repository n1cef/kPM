#!/bin/bash


BOLD=$(tput bold)
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
CYAN=$(tput setaf 6)
MAGENTA=$(tput setaf 5)
RESET=$(tput sgr0)


SCRIPTS_DIR="/usr/kraken/scripts"

print_help() {
    clear
    # Custom "KRAKEN" ASCII Art with Package Manager Theme
    echo "${BOLD}${CYAN}"
    echo '  ██   ██ ██████   █████  ██   ██ ███████ ███    ██ '
    echo '  ██  ██  ██   ██ ██   ██ ██  ██  ██      ████   ██ '
    echo '  █████   ██████  ███████ █████   █████   ██ ██  ██ '
    echo '  ██  ██  ██   ██ ██   ██ ██  ██  ██      ██  ██ ██ '
    echo '  ██   ██ ██   ██ ██   ██ ██   ██ ███████ ██   ████ '
    echo "${BOLD}${BLUE}"
    echo '  ┌───────────────────────────────────────────────┐'
    echo '  │  ░▒▓█████▓▒░ ░▒▓██████▓▒  ░▒▓█▓▒░ ░▒▓████▓▒░  │'
    echo '  └───────────────────────────────────────────────┘'
    echo "${BOLD}${GREEN}         Modular Dependency Resolving Package System${RESET}"
    echo ""
    
    echo "${BOLD}${CYAN}═════════════════════════════════════════════════════════════════════════${RESET}"
   
   
    echo "${BOLD}${GREEN}${BOLD}🌀 Usage:${RESET}"
    echo "  ${BOLD}kraken ${YELLOW}<command>${RESET} ${BLUE}[package_name]${RESET}\n"
    
   echo ""
   echo ""
   echo ""
    echo "${BOLD}${GREEN}${BOLD}🐙 Available Commands:${RESET}"
    printf "  ${YELLOW}%-12s${RESET} %s ${BOLD}${MAGENTA}➤${RESET} %s\n" \
      "download"    "📥" "Download package sources" \
      "prepare"     "🛠 " "Prepare build environment" \
      "build"       "🔨" "Compile the package" \
      "test"        "🧪" "Run package tests" \
      "preinstall"  "🔍" "Pre-installation checks" \
      "fakeinstall" "👻" "Detect package files/directories" \
      "install"     "📦" "Install the package" \
      "postinstall" "✅" "Post-installation tasks" \
      "remove"      "🗑 " "Uninstall the package" \
      "getdeps"     "🌳" "Display dependency tree (name+version)" \
      "checkinstalled" "🔎" "Verify installation (1=installed, 0=not)" \
      "getversion"  "🏷 " "Return package version" \
      "entropy"     "🌊" "Resolve Dependencies & Build from Source"

   
   echo ""
   echo ""
    echo "${BOLD}${GREEN}${BOLD}🌐 Examples:${RESET}"
    echo "${CYAN}${BOLD}⚓ Install a package:${RESET}"
    echo "  kraken ${YELLOW}install${RESET} ${BLUE}my-awesome-app${RESET}\n"
    
    echo "${CYAN}${BOLD}⚡ Build and test:${RESET}"
    echo "  kraken ${YELLOW}build${RESET} ${BLUE}my-library${RESET} && kraken ${YELLOW}test${RESET} ${BLUE}my-library${RESET}\n"
    
echo ""
echo ""
echo "${CYAN}${BOLD}🚀 Full Workflow (Manual):${RESET}"
echo "${BOLD}${BLUE}"
echo '  ┌───⋄──────────────────────────────────────────⋄───┐'
echo -e "  │  ${BLUE}sudo ${CYAN}kraken ${YELLOW}download ${MAGENTA}cool-package${BLUE}               │"
echo -e "  │  ${BLUE}sudo ${CYAN}kraken ${YELLOW}prepare ${MAGENTA}cool-package${BLUE}                │"
echo -e "  │  ${BLUE}sudo ${CYAN}kraken ${YELLOW}build ${MAGENTA}cool-package${BLUE}                  │"
echo -e "  │  ${BLUE}sudo ${CYAN}kraken ${YELLOW}test ${MAGENTA}cool-package${BLUE}                   │"
echo -e "  │  ${BLUE}sudo ${CYAN}kraken ${YELLOW}preinstall ${MAGENTA}cool-package${BLUE}             │"
echo -e "  │  ${BLUE}sudo ${CYAN}kraken ${YELLOW}fakeinstall ${MAGENTA}cool-package${BLUE}            │"
echo -e "  │  ${BLUE}sudo ${CYAN}kraken ${YELLOW}install ${MAGENTA}cool-package${BLUE}                │"
echo -e "  │  ${BLUE}sudo ${CYAN}kraken ${YELLOW}postinstall ${MAGENTA}cool-package${BLUE}            │"  
echo '  └───⋄──────────────────────────────────────────⋄───┘'
echo "${RESET}"

echo ""

echo "${CYAN}${BOLD}🚀 Full Workflow (Automatic):${RESET}"
echo "${BOLD}${BLUE}"
echo '  ┌───⋄──────────────────────────────────────────⋄───┐'
echo -e "  │  ${BLUE}sudo ${CYAN}kraken ${YELLOW}entropy ${MAGENTA}cool-package${BLUE}                │"
echo '  └───⋄──────────────────────────────────────────⋄───┘'
echo "${RESET}"










}

get_package(){

 local pkgname="$1"
 bash "$SCRIPTS_DIR/get_package.sh" "$pkgname"



}

checkinstalled (){

    local pkgname="$1"
    local pkgver="$2"
   /usr/bin/checkinstalled "$pkgname" "$pkgver"
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

getversion(){

 local pkgname="$1"
 bash "$SCRIPTS_DIR/getversion.sh" "$pkgname"



}

getdeps(){

 local pkgname="$1"
 local version="$2"
 bash "$SCRIPTS_DIR/getdeps.sh" "$pkgname" "$version"



}




command="$1"
pkg_name="$2"
pkg_ver="$3"
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
    checkinstalled "$pkg_name" "$pkg_ver"
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
      getdeps)
     getdeps "$pkg_name" "$pkg_ver"
     ;;
      getversion)
     getversion "$pkg_name"
     ;;



*)
        print_help
        exit 1
        ;;
esac
