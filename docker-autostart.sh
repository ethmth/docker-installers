#!/usr/bin/env bash

if ! [[ $EUID -ne 0 ]]; then
	echo "This script should not be run with root/sudo privileges."
	exit 1
fi

TIME_RESET=86400 # One Day

# The location where docker programs get installed for this user
# (the location to check for compose projects)
LOC="$HOME/docker"

# The name of the autostart flag file
AUTOSTART_FLAG_FILE_NAME=".autostart"

# Compose file names to search for
COMPOSE_FILES=("docker-compose.yml" "compose.yml")

# Recursively find all compose files and add their directories to a list
COMPOSE_DIRS=()
find_args=()
for file in "${COMPOSE_FILES[@]}"; do
    if [ ${#find_args[@]} -eq 0 ]; then
        find_args+=(-name "$file")
    else
        find_args+=(-o -name "$file")
    fi
done

if ! [ -d "$LOC" ]; then
    echo "Location $LOC does not exist"
    exit 1
fi

while IFS= read -r file; do
    dir=$(dirname "$file")
    # Add directory if not already in the list
    if [[ ! " ${COMPOSE_DIRS[@]} " =~ " ${dir} " ]]; then
        COMPOSE_DIRS+=("$dir")
    fi
done < <(find "$LOC" -type f \( "${find_args[@]}" \) 2>/dev/null)

# Get boot time in Unix timestamp
BOOT_TIME=$(who -b | tr -s ' ' | cut -d' ' -f4,5)
BOOT_TIME_UNIX=$(date -d "$BOOT_TIME" +%s 2>/dev/null || echo 0)
CURRENT_TIME_UNIX=$(date +%s)
TWENTY_FOUR_HOURS_AGO=$((CURRENT_TIME_UNIX - TIME_RESET))

# Iterate over each directory in the list and echo it
for dir in "${COMPOSE_DIRS[@]}"; do
    autostart_flag="$dir/$AUTOSTART_FLAG_FILE_NAME"
    start_flag=0
    if [ -f "$autostart_flag" ]; then
        # touch_date=$(stat -c %y "$autostart_flag" 2>/dev/null || stat -f "%Sm" "$autostart_flag" 2>/dev/null)
        file_time_unix=$(stat -c %Y "$autostart_flag" 2>/dev/null || stat -f %m "$autostart_flag" 2>/dev/null)
        
        if [ -n "$file_time_unix" ]; then
            # Check if file was touched after boot and within last 24 hours
            if [ "$file_time_unix" -gt "$BOOT_TIME_UNIX" ] && [ "$file_time_unix" -gt "$TWENTY_FOUR_HOURS_AGO" ]; then
                start_flag=0
            else
                start_flag=1
            fi
        fi
    fi

    if [ "$start_flag" -eq 1 ]; then
        echo "$dir"
        cd "$dir"
        docker compose up -d
        touch "$autostart_flag"
    fi
done

