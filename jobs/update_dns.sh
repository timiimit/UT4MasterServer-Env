#!/bin/sh

# load config
source /app/config.cfg

# load cloudflare api
source /app/cloudflare_api.sh

if [ -n $1 ]; then
	IP_ADDRESS=$1
else
	IP_ADDRESS=$(curl -s https://api/ipify.org)
fi

# get IP address of this machine

if [ -z "$IP_ADDRESS" ]; then
	echo "Failed to retrieve IP Address of this machine!"
	echo "DNS records will not be updated."
	echo "You may try to manually specify IP Address as first argument of this script."
else
	echo "Detected IP Address of this machine as: $IP_ADDRESS"

	# get a list of DNS records
	TMP=$(CloudflareDNSGetList $CLOUDFLARE_API_KEY $CLOUDFLARE_ZONE_ID)

	# set DNS records
	DNS_ID_WEBSITE=$(echo $TMP | jq '.result[] | select(.name == "'$DOMAIN_NAME_WEBSITE'") | .id')
	CloudflareDNSSet $CLOUDFLARE_API_KEY $CLOUDFLARE_ZONE_ID $DNS_ID_WEBSITE $DOMAIN_NAME_WEBSITE $IP_ADDRESS

	DNS_ID_API=$(echo $TMP | jq '.result[] | select(.name == "'$DOMAIN_NAME_API'") | .id')
	CloudflareDNSSet $CLOUDFLARE_API_KEY $CLOUDFLARE_ZONE_ID $DNS_ID_API $DOMAIN_NAME_API $IP_ADDRESS
fi
