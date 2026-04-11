#!/usr/bin/env bash

if ! [[ $EUID -ne 0 ]]; then
	echo "This script should not be run with root/sudo privileges."
	exit 1
fi

if ! [ -f "docker-autostart.sh" ]; then
    echo "File docker-autostart.sh doesn't exist."
    exit 1
fi

mkdir -p "$HOME/.local/bin"

cp docker-autostart.sh "$HOME/.local/bin/docker-autostart"
chmod 755 "$HOME/.local/bin/docker-autostart"


if ! ( cat "$HOME/.bashrc" | grep -q "docker-autostart" ); then
echo "docker-autostart" >> "$HOME/.bashrc"
fi