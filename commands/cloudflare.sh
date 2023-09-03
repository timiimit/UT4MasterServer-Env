#!/bin/sh

dns_create() {
	DOMAIN_NAME="$1"
	IP_ADDRESS="$2"

	curl -X POST "https://api.cloudflare.com/client/v4/zones/$CLOUDFLARE_ZONE_ID/dns_records" \
		-H "Authorization: Bearer $CLOUDFLARE_API_KEY" \
		-H "Content-Type: application/json" \
		--data '{"type":"A","name":"'"$DOMAIN_NAME"'","content":"'"$IP_ADDRESS"'","proxied":true,"ttl":1}'

	return 0
}

dns_update() {
	DNS_ID="$1"
	DOMAIN_NAME="$2"
	IP_ADDRESS="$3"

	curl -X PUT "https://api.cloudflare.com/client/v4/zones/$CLOUDFLARE_ZONE_ID/dns_records/$DNS_ID" \
		-H "Authorization: Bearer $CLOUDFLARE_API_KEY" \
		-H "Content-Type: application/json" \
		--data '{"type":"A","name":"'"$DOMAIN_NAME"'","content":"'"$IP_ADDRESS"'","proxied":true,"ttl":1}'

	return 0
}

dns_get_list() {

	curl -X GET "https://api.cloudflare.com/client/v4/zones/$CLOUDFLARE_ZONE_ID/dns_records?type=A" \
		-H "Authorization: Bearer $CLOUDFLARE_API_KEY" \
		-H "Content-Type: application/json"

	return 0
}

if [ "$1" == "dns" ]; then
	if [ "$2" == "list" ]; then
		if [ -z "$3" ]; then
			dns_get_list
		else
			echo "Description:"
			echo "List all A records in the zone specified by the configuration file."
			echo ""
			echo "Syntax:"
			echo "	$SCRIPT_COMMAND cloudflare dns list"
		fi
	elif [ "$2" == "create" ]; then
		if [ -n "$3" ] && [ "$3" != "--help" ]; then
			dns_create "$DOMAIN_NAME_WEBSITE" "$3"
			dns_create "$DOMAIN_NAME_API" "$3"
		else
			echo "Description:"
			echo "Try to create new A records in the zone specified by the configuration file."
			echo ""
			echo "Syntax:"
			echo "	$SCRIPT_COMMAND cloudflare dns create <ip-address>"
			echo ""
			echo "Arguments:"
			echo "	ip-address	IP Address to make new records point to."
		fi
	elif [ "$2" == "set" ]; then
		if [ -n "$3" ]; then
			records=$(dns_get_list)

			dns_id=$(echo $records | jq '.result[] | select(.name == "'"$DOMAIN_NAME_WEBSITE"'") | .id')
			dns_update "$dns_id" "$DOMAIN_NAME_WEBSITE" "$3"

			dns_id=$(echo $records | jq '.result[] | select(.name == "'"$DOMAIN_NAME_API"'") | .id')
			dns_update "$dns_id" "$DOMAIN_NAME_API" "$3"
		else
			echo "Description:"
			echo "Query the list of all A records for the right domains to obtain their id."
			echo "Then try to change their IP Address."
			echo ""
			echo "Syntax:"
			echo "	$SCRIPT_COMMAND cloudflare dns set <ip-address>"
			echo ""
			echo "Arguments:"
			echo "	ip-address	IP Address to make existing records point to."
		fi
	else
		echo "Description:"
		echo "Query or Manipulate DNS records of domains specified in"
		echo "the configuration file."
		echo ""
		echo "Affected domains:"
		echo "	$DOMAIN_NAME_WEBSITE"
		echo "	$DOMAIN_NAME_API"
		echo ""
		echo "Syntax:"
		echo "	$SCRIPT_COMMAND cloudflare dns <command> ..."
		echo ""
		echo "Commands:"
		echo "	list"
		echo "	create"
		echo "	set"
	fi
else
	echo "Description:"
	echo "Use Cloudflare's api. Use \`jq\` command for further output processing"
	echo "due to all responses being in json format."
	echo ""
	echo "Syntax:"
	echo "	$SCRIPT_COMMAND cloudflare <command> ..."
	echo ""
	echo "Commands:"
	echo "	dns"
fi