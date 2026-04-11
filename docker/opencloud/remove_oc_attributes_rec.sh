#!/usr/bin/env bash

if [ -z "$1" ]; then 
	echo "Requires single argument: <file|directory>"
	exit 1
fi

if ! [ "$EUID" -ne 0 ]; then
  echo "Please DO NOT run as root"
  exit 1
fi


target="$1"


if [ -e "$target" ]; then
  find "$target" -print0 | while IFS= read -r -d '' path; do
    getfattr --absolute-names -d "$path" 2>/dev/null \
      | grep "^user\.oc\." \
      | cut -d= -f1 \
      | xargs -r -I {} setfattr -x {} "$path"
  done
fi
