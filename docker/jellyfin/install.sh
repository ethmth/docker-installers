#!/bin/bash

# install NAME LOC VOLUMES FILES
# Custom installation function called by docker-install.sh
# Arguments:
#   $1 - NAME:    The container/service name
#   $2 - LOC:     The installation location path
#   $3 - VOLUMES: Newline-separated list of volume names
#   $4 - FILES:   Newline-separated list of file/directory names
install() {
    local NAME="$1"
    local LOC="$2"
    local VOLUMES="$3"
    local FILES="$4"

    GROUP_ID=$(id -g)
    USER_ID=$(id -u)

    VIDEO_ID=$(getent group video | awk -F: '{for(i=1; i<=NF; i++) if($i ~ /^[0-9]+$/) print $i}')
    RENDER_ID=$(getent group render | awk -F: '{for(i=1; i<=NF; i++) if($i ~ /^[0-9]+$/) print $i}')

    
    VIDEO_DEVICES=$(
    shopt -s nullglob
    for g in $(find /sys/kernel/iommu_groups/* -maxdepth 0 -type d | sort -V); do
        echo "IOMMU Group ${g##*/}:"
        for d in $g/devices/*; do
            echo -e "\t$(lspci -nns ${d##*/})"
        done;
    done;
    )

    VIDEO_DEVICES=$(echo "$VIDEO_DEVICES" | grep "VGA")

    VIDEO_NAMES=$(echo "$VIDEO_DEVICES" | awk -F ":" '{print $3}' | awk '{$NF=""; print $0}')

    selected_device=$(echo "$VIDEO_NAMES" | fzf --prompt="Select the video device to use. Select none for no GPU Acceleration")

    GPU_ACCEL=1
    NVIDIA=0
    if [ "$selected_device" == "" ]; then
        echo "No device selected, proceeding without GPU Acceleration"
        GPU_ACCEL=0
    fi

    DEVICE="Nothing"
    if (( GPU_ACCEL )); then
        NVIDIA=$(echo "$selected_device" | grep "NVIDIA" | wc -l)

        pci_value=$(echo "$VIDEO_DEVICES" | grep -F "$selected_device")
        pci_value=$(echo "$pci_value" | cut -d ' ' -f 1)
        pci_value="${pci_value#"${pci_value%%[![:space:]]*}"}"
        pci_value="${pci_value%"${pci_value##*[![:space:]]}"}"

        DEVICE="/dev/dri/by-path/pci-0000:$pci_value-render"
        if ! [ -e "$DEVICE" ]; then
            echo "The selected device ($DEVICE) doesn't exist. Exiting."
            exit 1
        fi
    fi

    sed -i "s/USER_ID_HERE/$USER_ID/g" $LOC/compose.yml
    sed -i "s/GROUP_ID_HERE/$GROUP_ID/g" $LOC/compose.yml
    sed -i "s/RENDER_ID_HERE/$RENDER_ID/g" $LOC/compose.yml
    sed -i "s/VIDEO_ID_HERE/$VIDEO_ID/g" $LOC/compose.yml

    if (( GPU_ACCEL )); then
string_to_echo=""
        if (( NVIDIA )); then
string_to_echo=$(echo "    deploy:
      resources:
        reservations:
          devices:
            - capabilities: [gpu]")
        else
string_to_echo=$(echo "      - ROC_ENABLE_PRE_VEGA=1  
    devices:
      - $(realpath "$DEVICE"):/dev/dri/renderD128")
        fi
        echo "$string_to_echo" >> $LOC/compose.yml
    fi

}