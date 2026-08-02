#!/usr/bin/env bash


if [[ $EUID -ne 0 ]]; then
    echo "This script should be run with root/sudo privileges."
    exit 1
fi

SCRIPT_DIR="$(dirname "$0")"

DOMAIN="$1"

if [ -z "$DOMAIN" ]; then
    echo "Usage: $0 <domain>"
    exit 1
fi

if [[ ! $DOMAIN =~ ^([a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?\.)+[a-zA-Z]{2,63}$ ]]; then
    echo "Domain $DOMAIN is an invalid domain format. Please enter a valid domain."
    exit 1
fi

CA_PEM_FILE="/opt/certs/internalCA.crt"
CA_KEY_FILE="/opt/certs/internalCA.key"

if ! [ -f "$CA_PEM_FILE" ] || ! [ -f "$CA_KEY_FILE" ]; then
    echo "$CA_PEM_FILE or $CA_KEY_FILE not found."
    exit 1
fi

CNF_FILE="/opt/certs/$DOMAIN.cnf"
KEY_FILE="/opt/certs/$DOMAIN.key"
CRT_FILE="/opt/certs/$DOMAIN.crt"
CSR_FILE="/opt/certs/$DOMAIN.csr"

if [ -f "$CNF_FILE" ] || [ -f "$KEY_FILE" ] || [ -f "$CRT_FILE" ] || [ -f "$CSR_FILE" ]; then
    echo "$CNF_FILE, $KEY_FILE, $CRT_FILE, or $CSR_FILE already exists. Remove it to continue"
    exit 1
fi

CNF="[req]
default_bits = 2048
prompt = no
default_md = sha256
distinguished_name = dn
req_extensions = req_ext

[dn]
C = US
ST = State
L = City
O = $(uname -n) Internal
OU = Internal
CN = $DOMAIN

[req_ext]
subjectAltName = @alt_names

[alt_names]
DNS.1 = $DOMAIN
"

echo "$CNF" > "$CNF_FILE"


openssl genrsa -out "$KEY_FILE" 2048
openssl req -new -key "$KEY_FILE" -out "$CSR_FILE" -config "$CNF_FILE"

PASSWORD="" openssl x509 -req -in "$CSR_FILE" -CA "$CA_PEM_FILE" -CAkey "$CA_KEY_FILE" -passin env:PASSWORD -CAcreateserial -out "$CRT_FILE" -days 36500 -sha256 -extensions req_ext -extfile "$CNF_FILE"

cp "$CRT_FILE" "$SCRIPT_DIR/certs/$DOMAIN.crt"
cp "$KEY_FILE" "$SCRIPT_DIR/certs/$DOMAIN.key"