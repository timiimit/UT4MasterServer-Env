#!/bin/sh

CloudflareDNSGetList() {
	API_KEY=$1
	ZONE_ID=$2

	curl -X GET "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records?type=A" \
		-H "Authorization: Bearer $API_KEY" \
		-H "Content-Type: application/json"

	return 0
}

CloudflareDNSSet()	{
	API_KEY=$1
	ZONE_ID=$2
	DNS_ID=$3
	DOMAIN_NAME=$4
	IP_ADDRESS=$5

	curl -X PUT "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records/$DNS_ID" \
		-H "Authorization: Bearer $API_KEY" \
		-H "Content-Type: application/json" \
		--data '{"type":"A","name":"'"$DOMAIN_NAME"'","content":"'"$IP_ADDRESS"'","proxied":true,"ttl":1}'

	return 0
}

# echo "Loaded cloudflare api."
