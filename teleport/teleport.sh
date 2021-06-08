#!/usr/bin/env bash

# Globals
GREEN="\033[0;32m"
PURPLE="\033[0;35m"
BLUE="\033[0;34m"
NC="\033[0m" # No Color
OK="${GREEN}OK${NC}\r\n"
ROOT="$(readlink -f ./)"

case "$1" in
    up-dev|ud)
        if [ ! -d /etc/letsencrypt/live/teleport.kubeshield.com ]; then
            printf "${PURPLE}Getting staging cert from certbot..."
            # Get staging certificate from Lets Encrypt
            sudo docker run -it --rm --name certbot -v "/etc/letsencrypt:/etc/letsencrypt" \
            -v "/var/lib/letsencrypt:/var/lib/letsencrypt" \
            certbot/dns-cloudflare certonly \
            --dns-cloudflare \
            --dns-cloudflare-credentials /etc/letsencrypt/cloudflare-creds \
            --server https://acme-staging-v02.api.letsencrypt.org/directory \
            -d teleport.kubeshield.com
            printf "${OK}"

            # start teleport with mounted config and data directories, plus all ports
            docker run --hostname localhost --name teleport \
            -v $ROOT/config:/etc/teleport \
            -v $ROOT/data:/var/lib/teleport \
            -v /etc/letsencrypt/live/teleport.kubeshield.com:/etc/letsencrypt/live/teleport.kubeshield.com \
            -p 3023:3023 -p 3025:3025 -p 3080:3080 \
            quay.io/gravitational/teleport:6
        fi
    ;;
    up-prod|up)
        if [ ! -d /etc/letsencrypt/live/teleport.kubeshield.com ]; then
            printf "${PURPLE}Getting staging cert from certbot..."
            # Get production certificate from Lets Encrypt
            sudo docker run -it --rm --name certbot -v "/etc/letsencrypt:/etc/letsencrypt" \
            -v "/var/lib/letsencrypt:/var/lib/letsencrypt" \
            certbot/dns-cloudflare certonly \
            --dns-cloudflare \
            --dns-cloudflare-credentials /etc/letsencrypt/cloudflare-creds \
            -d teleport.kubeshield.com
            printf "${OK}"

            # start teleport with mounted config and data directories, plus all ports
            docker run --hostname localhost --name teleport \
            -v ./config:/etc/teleport \
            -v ./data:/var/lib/teleport \
            -v /etc/letsencrypt/live/teleport.kubeshield.com:/etc/letsencrypt/live/teleport.kubeshield.com \
            -p 3023:3023 -p 3025:3025 -p 3080:3080 \
            quay.io/gravitational/teleport:6
        fi
    ;;    
    destroy|d)
        docker rm -f teleport
    ;;
esac
