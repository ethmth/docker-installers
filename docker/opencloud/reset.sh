#!/bin/bash

if ! [ -f "compose.yml" ]; then
    echo "Run this script in the same directory as compose.yml"
    exit 1
fi

docker compose down

bash remove_oc_attributes_rec.sh $HOME/Pictures

sudo rm -rf opencloud

mkdir -p opencloud/opencloud-config
mkdir -p opencloud/opencloud-data

chmod -R 777 opencloud/opencloud-config


docker compose --profile init run --rm opencloud-init