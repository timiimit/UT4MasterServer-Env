#!/bin/sh

source /app/config.cfg

certbot -d $WEBSITE_DOMAIN_NAME -d $API_DOMAIN_NAME --email $CERTIFICATE_REGISTRATION_EMAIL --non-interactive --apache --agree-tos