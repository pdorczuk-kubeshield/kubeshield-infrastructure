#!/usr/bin/env bash

# Globals
GREEN="\033[0;32m"
PURPLE="\033[0;35m"
BLUE="\033[0;34m"
NC="\033[0m" # No Color
OK="${GREEN}OK${NC}\r\n"

case "$1" in
    up-dev|ud)
        if [ ! -d /etc/letsencrypt/live/teleport* ]; then
            printf "${PURPLE}Getting staging cert from certbot..."
            # Get certificate from Lets Encrypt
            sudo docker run -it --rm --name certbot -v "/etc/letsencrypt:/etc/letsencrypt" \
            -v "/var/lib/letsencrypt:/var/lib/letsencrypt" \
            certbot/dns-cloudflare certonly \
            --dns-cloudflare \
            --dns-cloudflare-credentials /etc/letsencrypt/cloudflare-creds \
            --server https://acme-staging-v02.api.letsencrypt.org/directory \
            -d teleport.kubeshield.com
            printf "${OK}"
    ;;
    up-prod|up)
        if [ ! -d /etc/letsencrypt/live/teleport* ]; then
            printf "${PURPLE}Getting staging cert from certbot..."
            # Get certificate from Lets Encrypt
            sudo docker run -it --rm --name certbot -v "/etc/letsencrypt:/etc/letsencrypt" \
            -v "/var/lib/letsencrypt:/var/lib/letsencrypt" \
            certbot/dns-cloudflare certonly \
            --dns-cloudflare \
            --dns-cloudflare-credentials /etc/letsencrypt/cloudflare-creds \
            -d teleport.kubeshield.com
            printf "${OK}"
    ;;    
    destroy|d)
    ;;
esac


# 