
#!/bin/bash

# Define the source directory
SOURCE_DIR="/sources"
REPO_URL="https://raw.githubusercontent.com/n1cef/kraken_repository"
 pkgname="$1"

dir_filtring() {
    pkgname="$1"
    pkgver=$(awk -F '=' '/^pkgver=/ {print $2}' "$SOURCE_DIR/$pkgname/pkgbuild.kraken")
    echo "Package version is: $pkgver"

    metadata_dir="/var/lib/kraken/packages"

    # Input metadata file
    input_file="${metadata_dir}/${pkgname}-${pkgver}/DIRS"

    # Ensure input file exists
    if [ ! -f "$input_file" ]; then
        echo "Error: $input_file does not exist."
        return 1
    fi

    # Temporary file to store filtered output
    temp_file=$(mktemp) || { echo "Error: Unable to create temporary file."; return 1; }

    # Define protected paths
    protected_paths=(
        "/usr/bin"
        "/usr/lib"
        "/usr/share"
        "/usr/share/doc"
        "/usr/share/info"
        "/usr/share/man"
        "/usr/share/locale"
    )

# Loop through each line in the input file
    while IFS= read -r line; do
        # Check if the line matches any protected path
        match=0
        for protected_path in "${protected_paths[@]}"; do
            if [ "$line" == "$protected_path" ]; then
                match=1
                break
            fi
        done

        # If no match, write the line to the temporary file
        if [ $match -eq 0 ]; then
        echo "$line is fine "
            echo "$line" >> "$temp_file"
        fi
    done < "$input_file"
      echo "temp file is "
      sudo cat "$temp_file"
    # If the filtering was successful, replace the original file
    if [ $? -eq 0 ]; then
        sudo mv "$temp_file" "$input_file"
        echo "Filtered metadata saved to $input_file"
        
    else
        echo "Error: Failed to filter the directory list."
        sudo rm -f "$temp_file"
        
    fi



}

dir_filtring "$1"