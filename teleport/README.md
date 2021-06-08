1. Add Cloudflare API credentials to /etc/letsencrypt/cloudflare-creds. In the format dns_cloudflare_api_token = $API_KEY
2. Copy Github OAuth API key in github.yaml
3. Replace 'teleport.kubeshield.com' with your URL in teleport.yaml and github.yaml
3. Run script at ./teleport.sh create