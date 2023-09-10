#!/bin/sh

if [ "$2" == "--dry-run" ]; then
	opt_dryrun="--dry-run"
fi

if [ "$1" == "obtain" ]; then
	if [ -n "$2" ]; then
		if [ "$2" == "--dry-run" ]; then
			opt_dryrun="--dry-run"
		else
			echo "Description:"
			echo "Obtain new SSL certificate."
			echo ""
			echo "Syntax:"
			echo "	cert obtain [options]"
			echo ""
			echo "Options:"
			echo "	--dry-run	Just do a test run."
			exit
		fi
	fi

	# obtain certificates by letting certbot use apache's document root
	certbot certonly $opt_dryrun --email "$CERTIFICATE_REGISTRATION_EMAIL" --agree-tos --non-interactive -d "$DOMAIN_NAME_WEBSITE" -d "$DOMAIN_NAME_API" --webroot --webroot-path "/var/www/html"
elif [ "$1" == "renew" ]; then
	if [ -n "$2" ]; then
		if [ "$2" == "--dry-run" ]; then
			opt_dryrun="--dry-run"
		else
			echo "Description:"
			echo "Renew all old SSL certificates that are near expiry."
			echo ""
			echo "Syntax:"
			echo "	cert renew [options]"
			echo ""
			echo "Options:"
			echo "	--dry-run	Just do a test run."
			exit
		fi
	fi
	certbot renew $opt_dryrun
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
	echo "	cert <command> ..."
	echo ""
	echo "Commands:"
	echo "	obtain"
	echo "	renew"
	exit
fi
