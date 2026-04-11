#!/usr/bin/env bash

# Array to store relative paths
declare -a install_files=()

# Recursively find all install.yml files in subdirectories and add to array
while IFS= read -r -d '' file; do
    # Get relative path from current directory
    relative_path="${file#./}"
    install_files+=("$relative_path")
done < <(find . -type f -name "install.yml" -print0)

# Array to store file/name pairs
declare -a options=()

# Iterate over the array and parse each install.yml file for the name field
for install_file in "${install_files[@]}"; do
    if [ -f "$install_file" ]; then
        name=$(yq -r '.install.name' "$install_file" 2>/dev/null)
        if [ -n "$name" ] && [ "$name" != "null" ]; then
            # Store as "name | file_path" for fzf display
            options+=("$name | $install_file")
        fi
    fi
done

# Present options in fzf with multi-select
selected=$(printf '%s\n' "${options[@]}" | fzf --multi --prompt="Select installs: " --header="Press TAB to select multiple, ENTER to confirm")

# Check if user made selections
if [ -z "$selected" ]; then
    echo "No selections made."
    exit 0
fi

# Array to store selected install files
declare -a selected_files=()

# Process selected items and extract file paths
while IFS= read -r line; do
    # Extract file path (everything after " | ")
    file_path="${line##* | }"
    selected_files+=("$file_path")
done <<< "$selected"

# Check if docker-install exists in PATH, otherwise use the one from script directory
if command -v docker-install >/dev/null 2>&1; then
    docker_install_cmd="docker-install"
else
    # Get the directory where this script is located
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    docker_install_cmd="$script_dir/docker-install.sh"
fi

# Iterate over selected files and call docker-install script
for install_file in "${selected_files[@]}"; do
    echo "Installing $install_file"
    "$docker_install_cmd" "$install_file"
done
