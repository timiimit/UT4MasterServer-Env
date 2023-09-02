
if [ $1 -eq "start" ]; then
	docker-compose -f docker-compose.yml up -d
elif [ $1 -eq "stop" ]; then
	docker-compose -f docker-compose.yml down
elif [ $1 -eq "restart" ]; then
	docker-compose -f docker-compose.yml down
	docker-compose -f docker-compose.yml up -d
elif [ $1 -eq "rebuild" ]; then
	docker-compose -f docker-compose.yml down
	docker system prune -af
	docker-compose -f docker-compose.yml up --build -d
elif [ $1 -eq "config" ]; then

cat << EOF > UT4MasterServer/appsettings.Production.json
{
	"ApplicationSettings": {
		"WebsiteDomain": "$DOMAIN_NAME_WEBSITE"
	},
	"ReCaptchaSettings": {
		"SiteKey": "$RECAPTCHA_CLIENT_ID",
		"SecretKey": "$RECAPTCHA_CLIENT_SECRET"
	}
}
EOF

cat << EOF > UT4MasterServer.Web/.env.production
VITE_API_URL=https://$DOMAIN_NAME_API
VITE_BASIC_AUTH="basic MzRhMDJjZjhmNDQxNGUyOWIxNTkyMTg3NmRhMzZmOWE6ZGFhZmJjY2M3Mzc3NDUwMzlkZmZlNTNkOTRmYzc2Y2Y="
VITE_RECAPTCHA_SITE_KEY=$RECAPTCHA_CLIENT_ID
EOF

elif [ $1 -eq "update" ]; then

	# in case repo is already there, just pull latest code, else clone fresh
	if [ "$(git remote get-url origin)" == "$UT4MS_REPO_URL" ]; then
		git fetch
		# TODO: switch to `production` branch
		git checkout master
		git pull
	else
		# make sure that we are cloning into an empty directory
		if [ -z "$(\ls -A)" ]; then
			git clone $UT4MS_REPO_URL .
		else
			echo "\`$(pwd)\` is not empty and it doesn't contain the right"
			echo "repository. Unsure what to do."
			echo ""
			echo "Stopping."
			exit
		fi
	fi
else
	echo "Description:"
	echo "Issue a command for UT4MasterServer."
	echo ""
	echo "Syntax:"
	echo "	server <command>"
	echo ""
	echo "Commands:"
	echo "	start	Start all docker containers that run the server."
	echo "	stop	Stop all docker containers that run the server."
	echo "	restart	The same as running start and stop commands one"
	echo "          after the other."
	echo "	rebuild	Stop server, rebuild the docker images and then"
	echo "          start the server back up."
	echo "	config	Configure or reconfigure the server by updating its"
	echo "          configuration files. Rebuild the server to apply"
	echo "          the changes."
	echo "	update	Pull latest UT4MasterServer code. Rebuild is"
	echo "          required to apply new changes."
	exit
fi