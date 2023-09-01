#!/bin/sh

cd /app

source config.cfg

cd UT4MasterServer

cat << EOF > UT4MasterServer/appsettings.Production.json
{
	"ApplicationSettings": {
		"WebsiteDomain": "$DOMAIN_NAME_WEBSITE"
	},
	"ReCaptchaSettings": {
		"SiteKey": "$RECAPTCHA_CLIENT_KEY",
		"SecretKey": "$RECAPTCHA_CLIENT_SECRET"
	}
}
EOF

cat << EOF > UT4MasterServer.Web/.env.production
VITE_API_URL=https://$DOMAIN_NAME_API
VITE_BASIC_AUTH="basic MzRhMDJjZjhmNDQxNGUyOWIxNTkyMTg3NmRhMzZmOWE6ZGFhZmJjY2M3Mzc3NDUwMzlkZmZlNTNkOTRmYzc2Y2Y="
VITE_RECAPTCHA_SITE_KEY=$RECAPTCHA_CLIENT_KEY
EOF