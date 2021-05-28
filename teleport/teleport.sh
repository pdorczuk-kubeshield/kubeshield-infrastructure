#!/bin/bash

docker run -it --rm --name certbot -v "/etc/letsencrypt:/etc/letsencrypt" \
-v "/var/lib/letsencrypt:/var/lib/letsencrypt" \
certbot/dns-cloudflare certonly \
--dns-cloudflare \
--dns-cloudflare-credentials /etc/letsencrypt/cloudflare-creds \
-d teleport.kubeshield.com