#!/bin/sh

if [ "$1" == "config" ]; then
	if [ -z "$2" ]; then
		# generate file with list of cloudflare proxy IPs
		curl -s https://www.cloudflare.com/ips-v4 > /etc/httpd/proxy_list.txt
		echo >> /etc/httpd/proxy_list.txt
		curl -s https://www.cloudflare.com/ips-v6 >> /etc/httpd/proxy_list.txt

# now create ut4master.conf in /etc/httpd/conf.d/ and put in the following:
cat >/etc/httpd/conf.d/ut4master.conf << EOF

# Number of httpd processes that are handling requests simultaneously
MaxRequestWorkers 32

# Use Cloudflare's header to obtain client's IPs
RemoteIPHeader CF-Connecting-IP
RemoteIPTrustedProxyList proxy_list.txt

# We need some document root to be able to use certbot
DocumentRoot "/var/www/html"

# Always redirect domains to https
RewriteEngine on
RewriteCond %{SERVER_NAME} =$DOMAIN_NAME_WEBSITE [OR]
RewriteCond %{SERVER_NAME} =$DOMAIN_NAME_API
RewriteRule ^ https://%{SERVER_NAME}%{REQUEST_URI} [END,NE,R=permanent]
EOF

if [ -f "/etc/letsencrypt/live/$DOMAIN_NAME_WEBSITE/fullchain.pem" ]; then
	IFS='' read -r -d '' ssl_options <<EOF
	SSLCertificateFile /etc/letsencrypt/live/$DOMAIN_NAME_WEBSITE/fullchain.pem
	SSLCertificateKeyFile /etc/letsencrypt/live/$DOMAIN_NAME_WEBSITE/privkey.pem
EOF
fi

# create configuration for https
cat >/etc/httpd/conf.d/ut4master-ssl.conf << EOF

<VirtualHost *:443>
	ServerName "$DOMAIN_NAME_WEBSITE"
	ProxyPreserveHost On
	ProxyPass / http://127.0.0.1:5001/
	ProxyPassReverse / http://127.0.0.1:5001/
	$ssl_options
</VirtualHost>
<VirtualHost *:443>
	ServerName "$DOMAIN_NAME_API"
	ProxyPreserveHost On
	ProxyPass / http://127.0.0.1:5000/
	ProxyPassReverse / http://127.0.0.1:5000/
	$ssl_options
</VirtualHost>
EOF
	else
		echo "Description:"
		echo "Re/configure apache. This should generally be used to configure"
		echo "apache for the first time, or if server's domain has changed."
		echo "Use \`systemctl reload httpd\` to apply changes."
		echo ""
		echo "Syntax:"
		echo "	$SCRIPT_COMMAND apache config"
	fi
else
	echo "Description:"
	echo "Perform operations upon apache (httpd)."
	echo ""
	echo "Syntax:"
	echo "	$SCRIPT_COMMAND apache <command>"
	echo ""
	echo "Commands:"
	echo "	config"
fi