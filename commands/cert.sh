#!/bin/sh

if [ $1 == "obtain" ]; then
	certbot -d $DOMAIN_NAME_WEBSITE -d $DOMAIN_NAME_API --email $CERTIFICATE_REGISTRATION_EMAIL --non-interactive --apache --agree-tos
elif [ $1 == "renew" ]; then
	certbot renew
else
	echo "Description:"
	echo "Work with certificate authority to handle/manipulate ssl certificates"
	echo "used for the website."
	echo ""
	echo "Based on your configuration you will be handling the following domains:"
	echo "	$DOMAIN_NAME_WEBSITE"
	echo "	$DOMAIN_NAME_API"
	echo ""
	echo "Syntax:"
	echo "	cert <command>"
	echo ""
	echo "Commands:"
	echo "	obtain	Obtain new certificates for configured domains."
	echo "	renew	Renew all previously obtained certificates."
	exit
fi
