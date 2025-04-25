
#!/bin/bash
DB_FILE="/var/lib/kraken/db/kraken.db"
SOURCE_DIR="/sources"
REPO_URL="https://raw.githubusercontent.com/n1cef/KUR/main"

INDEX_URL="$REPO_URL/pkgindex.kraken"
CACHE_DIR="$HOME/.cache/krakenpm"

INDEX_CACHE="$CACHE_DIR/pkgindex.kraken"
CACHE_TTL=3600 


BOLD=$(tput bold)
CYAN=$(tput setaf 6)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
RED=$(tput setaf 1)
MAGENTA=$(tput setaf 5)
RESET=$(tput sgr0)


get_package() {

   

    pkgname="$1"
    echo "${BOLD}${CYAN}=== Fetching Package: ${YELLOW}${pkgname} ${CYAN}===${RESET}"

 
    if [ -z "$pkgname" ]; then
        echo "${BOLD}${RED}✗ ERROR: Package name not specified${RESET}"
        exit 1
    fi




   



    if ! command -v curl &> /dev/null; then
        echo "${BOLD}${RED}✗ ERROR: curl is required but not installed${RESET}"
        exit 1
    fi

  
  

    echo "${CYAN}🌐 Updating package index...${RESET}"
    mkdir -p "$CACHE_DIR"
    if ! find "$CACHE_DIR" -name "$(basename "$INDEX_CACHE")" -mmin -60 | grep -q .; then
        curl -sSL -o "$INDEX_CACHE" "$INDEX_URL" || {
            echo "${RED}✗ Failed to fetch index${RESET}"; exit 1
        }
    fi
  


    echo "${CYAN}🔍 Looking up package metadata...${RESET}"
    local metadata=$(yq eval ".packages.$pkgname" "$INDEX_CACHE")
    [ -z "$metadata" ] && {
        echo "${RED}✗ Package $pkgname not found in repository${RESET}"; exit 1
    }

    
    local version=$(yq eval ".packages.$pkgname.version" "$INDEX_CACHE") 
    local category=$(yq eval ".packages.$pkgname.category" "$INDEX_CACHE")
    local pkgbuild_path=$(yq eval ".packages.$pkgname.path" "$INDEX_CACHE")

    local pkgbuild_url="${REPO_URL}/${pkgbuild_path}"

 [ -z "$version" ] && { echo "Missing version"; exit 1; }
[ -z "$category" ] && { echo "Missing category"; exit 1; }





echo "${BOLD}${CYAN}🔍 Checking installation status...${RESET}"


sudo kraken checkinstalled "$pkgname"  "$version"
status =$?

case (status) in
   
      1)
        echo "${BOLD}${YELLOW}⚠ WARNING: ${YELLOW}${pkgname} is alreadny istalled!${RESET}"
        echo "${BOLD}${YELLOW}⚠ HINT: \n
        you  can update the pacakge with sudo kraken update ${YELLOW}${pkgname} \n
                 or remove and then reinstall her with \n
                 sudo kraken remove ${YELLOW}${pkgname}\n
                 sudo kraken entoropy ${YELLOW}${pkgname}                 
        
        "
	
        exit 1
	;;
          0)
            echo "${BOLD}${GREEN}✅ ${YELLOW}${pkgname}${GREEN} is not installed. Proceeding...${RESET}"

     	  ;;             

          2)
              echo "Error: Invalid usage (e.g., missing arguments). please report to kaddechinn@gmai.com "

	       exit 1
        ;;
	  
        3)
            echo "Error: Database file not found. please report to kaddechinn@gmai.com "
	     exit 1
        ;;
        4)
	    
            echo "Error: SQL query failure or runtime error.  please report to kaddechinn@gmai.com"
	     exit 1
        ;;

      *)
          echo "Unknown error (exit code $status)."
	  exit 1
        ;;
 esac




	  
    

      echo "${BOLD}${CYAN}⌛ Preparing workspace...${RESET}"
    mkdir -p "$SOURCE_DIR/$pkgname" || {
        echo "${BOLD}${RED}✗ ERROR: Failed to create directory ${YELLOW}${SOURCE_DIR}/${pkgname}${RESET}"
        exit 1
    }


    echo "${CYAN}📦 Downloading recipe from ${YELLOW}${pkgbuild_url}${RESET}"
    curl -sSL -o "$SOURCE_DIR/$pkgname/pkgbuild.kraken" "$pkgbuild_url" || {
        echo "${RED}✗ Failed to fetch PKGBUILD${RESET}"; exit 1
    }


     #expected_checksum=$(yq eval ".packages.$pkgname.checksum" "$INDEX_CACHE" | out -d: -f2)
   local expected_checksum=$(yq eval ".packages.$pkgname.checksum | split(\":\") | .[1]" "$INDEX_CACHE")


    local actual_checksum=$(sha256sum "$SOURCE_DIR/$pkgname/pkgbuild.kraken" | cut -d' ' -f1)

     [ "$actual_checksum" != "$expected_checksum" ] && {
        echo "${RED}✗ Checksum mismatch for PKGBUILD${RESET}"
        echo "${YELLOW}Expected: $expected_checksum"
        echo "Actual:   $actual_checksum${RESET}"
        exit 1
    }


    

   
    echo "${BOLD}${CYAN}📦 Extracting package sources...${RESET}"
    source_urls=($(awk '/^sources=\(/,/\)/' "$SOURCE_DIR/$pkgname/pkgbuild.kraken" | 
                sed -e '1d;$d' -e 's/[",]//g' | xargs -n1))
    checksums=($(awk '/^md5sums=\(/,/\)/' "$SOURCE_DIR/$pkgname/pkgbuild.kraken" | 
               sed -e '1d;$d' -e 's/[",]//g' | xargs -n1))

    if [ ${#source_urls[@]} -ne ${#checksums[@]} ]; then
        echo "${BOLD}${RED}✗ ERROR: Mismatch between ${YELLOW}${#source_urls[@]}${RED} sources and ${YELLOW}${#checksums[@]}${RED} checksums${RESET}"
        exit 1
    fi

    
    echo "${BOLD}${CYAN}📥 Downloading ${YELLOW}${#source_urls[@]}${CYAN} source files...${RESET}"
    for ((i=0; i<${#source_urls[@]}; i++)); do
        url="${source_urls[$i]}"
        checksum="${checksums[$i]}"
        tarball_name=$(basename "$url")
        
        echo "${BOLD}${CYAN}  [$(($i+1))/${#source_urls[@]}] ${MAGENTA}${tarball_name}${RESET}"
        echo "   ${YELLOW}URL: ${url}${RESET}"
        echo "   ${MAGENTA}Expected MD5: ${checksum}${RESET}"

       
        if ! curl -L -# -o "$SOURCE_DIR/$pkgname/$tarball_name" "$url"; then
            echo "${BOLD}${RED}   ✗ Download failed${RESET}"
            exit 1
        fi

       
        downloaded_checksum=$(md5sum "$SOURCE_DIR/$pkgname/$tarball_name" | awk '{print $1}')
        if [ "$downloaded_checksum" != "$checksum" ]; then
            echo "${BOLD}${RED}   ✗ Checksum mismatch: ${YELLOW}${downloaded_checksum}${RED} ≠ ${YELLOW}${checksum}${RESET}"
            exit 1
        fi
        echo "${GREEN}   ✓ Verification successful${RESET}"
    done

 
 
 
    echo "${BOLD}${GREEN}✅ Successfully retrieved ${YELLOW}${pkgname}${GREEN} with ${YELLOW}${#source_urls[@]}${GREEN} verified sources${RESET}"

source /var/lib/kraken/db/kraken_db.sh
  if mark_downloaded "$pkgname" "$version" "$category"; then
    echo "Database updated"
else
    echo "Database error: $?" >&2
    exit 1
fi



}


get_package "$1"
