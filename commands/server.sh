
if [ "$1" == "start" ]; then
	if [ -z "$IS_SERVICE" ]; then
		echo "Do not run this command manually. Please use \`systemctl start ut4ms\` instead."
		exit
	fi
	docker-compose -f docker-compose.yml up -d
elif [ "$1" == "stop" ]; then
	if [ -z "$IS_SERVICE" ]; then
		echo "Do not run this command manually. Please use \`systemctl stop ut4ms\` instead."
		exit
	fi
	docker-compose -f docker-compose.yml down
elif [ "$1" == "reload" ]; then

	available_mem=$(free -m | grep Mem | awk '{print $7}')
	if [ $available_mem -le 800 ]; then
		echo "Ignoring reload command. Less than 800MiB of memory is available."
		exit 1
	fi

	if [ -z "$IS_SERVICE" ]; then
		echo "Do not run this command manually. Please use \`systemctl reload ut4ms\` instead."
		exit
	fi

	# docker-compose -f docker-compose.yml down
	# docker system prune -af
	docker-compose -f docker-compose.yml up --build -d
	docker system prune -af
elif [ "$1" == "update" ]; then

	if [ -z "$IS_SERVICE" ]; then
		echo "Do not run this command manually. Please use \`systemctl start ut4ms_update\` instead."
		exit
	fi

	# in case repo is already there, just pull latest code, else clone fresh
	if [ "$(git remote get-url origin 2>/dev/null)" == "$REPO_URL_APP" ]; then

		# minimal fetch
		git remote update

		# compare local commit id and remote commit id
		COMMIT_UPSTREAM=$(git rev-parse @{u})
		COMMIT_LOCAL=$(git rev-parse @)

		if [ "$COMMIT_UPSTREAM" == "$COMMIT_LOCAL" ]; then
			echo "Already up to date."
			exit 1
		fi

		# pull all changes
		git pull

		# switch to desired branch
		if [ "$(git branch --show-current)" != "$REPO_BRANCH_ENV"]; then
			git checkout -f "$REPO_BRANCH_ENV" 1>/dev/null
		fi
	else
		# make sure that we are cloning into an empty directory
		if [ -z "$(\ls -A)" ]; then
			git clone -b "$REPO_BRANCH_APP" "$REPO_URL_APP" .
		else
			echo "\`$(pwd)\` is not empty and it doesn't contain the right"
			echo "repository. Unsure what to do."
			echo ""
			echo "Stopping."
			exit
		fi
	fi

cat << EOF > UT4MasterServer/appsettings.Production.json
{
	"ApplicationSettings": {
		"WebsiteDomain": "$DOMAIN_NAME_WEBSITE"
	},
	"ReCaptchaSettings": {
		"SiteKey": "$RECAPTCHA_SITE_KEY",
		"SecretKey": "$RECAPTCHA_SECRET_KEY"
	}
}
EOF

cat << EOF > UT4MasterServer.Web/.env.production
VITE_API_URL=https://$DOMAIN_NAME_API
VITE_BASIC_AUTH="basic MzRhMDJjZjhmNDQxNGUyOWIxNTkyMTg3NmRhMzZmOWE6ZGFhZmJjY2M3Mzc3NDUwMzlkZmZlNTNkOTRmYzc2Y2Y="
VITE_RECAPTCHA_SITE_KEY=$RECAPTCHA_SITE_KEY
EOF

	echo "Server successfully updated. Reload server to apply changes."
else
	echo "Description:"
	echo "Issue a command for UT4MasterServer."
	echo ""
	echo "Note:"
	echo "These commands will not work if executed normally."
	echo "Generally these commands are meant to be executed as a service."
	echo "When creating a service, define \`IS_SERVICE\` environment variable."
	echo ""
	echo "Syntax:"
	echo "	server <command>"
	echo ""
	echo "Commands:"
	echo "	start	Start all docker containers that run the server."
	echo "	stop	Stop all docker containers that run the server."
	echo "	reload	Stop server, rebuild the docker images and then"
	echo "          start the server back up."
	echo "	update	Pull latest UT4MasterServer code. Reload is"
	echo "          required to apply new changes."
	exit
fi