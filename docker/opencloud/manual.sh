mkdir -p $HOME/opencloud/opencloud-config
mkdir -p $HOME/opencloud/opencloud-data

docker pull opencloudeu/opencloud-rolling:latest

# Initialize opencloud (first time setup)
docker run --rm -it \
    -v $HOME/opencloud/opencloud-config:/etc/opencloud \
    -v $HOME/opencloud/opencloud-data:/var/lib/opencloud \
    -e IDM_ADMIN_PASSWORD=admin \
    opencloudeu/opencloud-rolling:latest init


# start opencloud
docker run \
    --name opencloud \
    --rm \
    -p 0.0.0.0:9200:9200 \
    -v $HOME/opencloud/opencloud-config:/etc/opencloud \
    -v $HOME/opencloud/opencloud-data:/var/lib/opencloud \
    -e OC_INSECURE=true \
    -e PROXY_HTTP_ADDR=0.0.0.0:9200 \
    -e OC_URL=https://localhost:9200 \
    opencloudeu/opencloud-rolling:latest

docker run \
    --name opencloud \
    --rm \
    -p 0.0.0.0:9200:9200 \
    -v $HOME/opencloud/opencloud-config:/etc/opencloud \
    -v $HOME/opencloud/opencloud-data:/var/lib/opencloud \
    -e OC_INSECURE=true \
    -e PROXY_HTTP_ADDR=0.0.0.0:9200 \
    -e OC_URL=https://192.168.50.45:9200 \
    opencloudeu/opencloud-rolling:latest


# try
docker run \
    --name opencloud \
    --rm \
    -p 0.0.0.0:9200:9200 \
    -v $HOME/opencloud/opencloud-config:/etc/opencloud \
    -v $HOME/opencloud/opencloud-data:/var/lib/opencloud \
    -v $HOME/Pictures:/var/lib/opencloud/storage/users/projects/b9af3c0a-e04c-45c7-8f70-0e43eee96ee4:ro \
    -e OC_INSECURE=true \
    -e PROXY_HTTP_ADDR=0.0.0.0:9200 \
    -e OC_URL=https://192.168.50.45:9200 \
    --user root \
    opencloudeu/opencloud-rolling:latest


docker run \
    --name opencloud \
    --rm \
    -p 0.0.0.0:9200:9200 \
    -v $HOME/opencloud/opencloud-config:/etc/opencloud \
    -v $HOME/opencloud/opencloud-data:/var/lib/opencloud \
    -v $HOME/Pictures:/var/lib/opencloud/storage/users/projects/b9af3c0a-e04c-45c7-8f70-0e43eee96ee4:ro \
    -e OC_INSECURE=true \
    -e PROXY_HTTP_ADDR=0.0.0.0:9200 \
    -e OC_URL=https://192.168.50.45:9200 \
    opencloudeu/opencloud-rolling:latest

# try
docker run \
    --name opencloud-manual \
    --rm \
    -p 0.0.0.0:9201:9200 \
    -v $HOME/opencloud/opencloud-config:/etc/opencloud \
    -v $HOME/opencloud/opencloud-data:/var/lib/opencloud \
    -v $HOME/Pictures:/var/lib/opencloud/storage/users/projects/b9af3c0a-e04c-45c7-8f70-0e43eee96ee4/Pictures \
    -e OC_INSECURE=true \
    -e PROXY_HTTP_ADDR=0.0.0.0:9200 \
    -e OC_URL=https://192.168.50.45:9201 \
    --user root \
    opencloudeu/opencloud-rolling:latest

# OC_ADMIN_USER_ID

# OC_DISABLE_VERSIONING true


# OC_HTTP_TLS_CERTIFICATE
# OC_HTTP_TLS_ENABLED