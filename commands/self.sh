#!/bin/sh

command_location="/usr/local/bin/ut4ms"
systemd_dir="/etc/systemd/system"

if [ "$EUID" != "0" ]; then
	echo "\`$SCRIPT_COMMAND self\` commands must only be run as root."
	exit
fi

if [ "$1" == "update" ]; then
	if [ -z "$2" ]; then

		# navigate into env repo for easier operation
		cd "$ROOT_DIR_ENV"

		# minimal fetch
		git remote update

		# compare branch name and commit id
		BRANCH_NAME="$(git branch --show-current)"
		COMMIT_UPSTREAM="$(git rev-parse @{u})"
		COMMIT_LOCAL="$(git rev-parse @)"

		if [ "$BRANCH_NAME" == "$REPO_BRANCH_ENV" ] && [ "$COMMIT_UPSTREAM" == "$COMMIT_LOCAL" ]; then
			echo "Already up to date."
			exit
		fi

		# uninstall because new version might install in a different way
		"./ut4ms.sh" self uninstall

		# stash `config.cfg` as it is set-up to contain production environment variables
		git stash push config.cfg 1>/dev/null

		# discard any local changes in working directory
		git reset --hard HEAD 1>/dev/null

		# pull all changes
		git pull

		# switch to desired branch
		if [ "$BRANCH_NAME" != "$REPO_BRANCH_ENV" ]; then
			git checkout -f "$REPO_BRANCH_ENV" 1>/dev/null
		fi

		# unstash previously stashed config.cfg
		git stash pop 1>/dev/null

		# install newly downloaded version
		"./ut4ms.sh" self install
	else
		echo "Description:"
		echo "Update global \`ut4ms\` command and services."
		echo ""
		echo "Syntax:"
		echo "	$SCRIPT_COMMAND self update"
	fi
elif [ "$1" == "install" ]; then
	if [ -z "$2" ]; then
		# install global ut4ms command
cat >"$command_location" << EOF
#!/bin/bash
export SCRIPT_COMMAND="ut4ms"
"$ROOT_DIR_ENV/ut4ms.sh" "\$@"
EOF
		chmod 755 "$command_location"

		# install systemd unit files
		for systemd_file in $ROOT_DIR_ENV/systemd/*; do
			systemd_filename="${systemd_file##*/}"
			ln -s "$systemd_file" "$systemd_dir/$systemd_filename"
		done

		for systemd_timer_file in $ROOT_DIR_ENV/systemd/*.timer; do
			systemd_timer_filename="${systemd_timer_file##*/}"
			systemctl --now enable "$systemd_timer_filename"
		done

		# ensure that systemd sees the changes
		systemctl daemon-reload
	elif [ "$2" == "--deps" ]; then

		install_dir="/usr/local/bin"

		# install apache, docker, certbot deps
		dnf -q -y install httpd mod_ssl docker python3 augeas-libs

		# install update-certbot
		certbot_dir="/opt/certbot"
		python3 -m venv "$certbot_dir"
		cat >"$install_dir/update-certbot" << EOF
#!/bin/bash
"$certbot_dir/bin/pip" install --upgrade pip
"$certbot_dir/bin/pip" install --upgrade certbot certbot-apache
EOF
		chmod 755 "$install_dir/update-certbot"

		update-certbot

		ln -s "$certbot_dir/bin/certbot" "$install_dir/certbot"

		# install update-docker-compose

		cat >"$install_dir/update-docker-compose" << EOF
#!/bin/bash
curl -SL -o "$install_dir/docker-compose" https://github.com/docker/compose/releases/latest/download/docker-compose-linux-$(uname -m)
chmod 755 "$install_dir/docker-compose"
EOF
		chmod 755 "$install_dir/update-docker-compose"

		update-docker-compose

	else
		echo "Description:"
		echo "Install global \`ut4ms\` command and services."
		echo ""
		echo "Syntax:"
		echo "	$SCRIPT_COMMAND self install [--deps]"
		echo ""
		echo "Options:"
		echo "	--deps	Install only dependency packages that are"
		echo "          required by this command."
	fi
elif [ "$1" == "uninstall" ]; then
	if [ -z "$2" ]; then

		for systemd_timer_file in $ROOT_DIR_ENV/systemd/*.timer; do
			systemd_timer_filename="${systemd_timer_file##*/}"
			systemctl --now disable "$systemd_timer_filename"
		done

		# uninstall systemd unit files
		for systemd_file in $ROOT_DIR_ENV/systemd/*; do
			systemd_filename="${systemd_file##*/}"
			rm "$systemd_dir/$systemd_filename"
		done

		# ensure that systemd sees the changes
		systemctl daemon-reload

		# uninstall global ut4ms command
		rm "$command_location"
	else
		echo "Description:"
		echo "Uninstall global \`ut4ms\` command and services."
		echo ""
		echo "Syntax:"
		echo "	$SCRIPT_COMMAND self uninstall"
	fi
elif [ "$1" == "config" ]; then
	if [ -z "$2" ]; then

		"$SCRIPT_COMMAND" apache config
		systemctl reload httpd

		"$SCRIPT_COMMAND" server config
		systemctl reload ut4ms

		"$SCRIPT_COMMAND" cloudflare dns set $("$SCRIPT_COMMAND" ip)

	else
		echo "Description:"
		echo "Re/configure most things to reflect an updated \`config.cfg\` file and"
		echo "apply all changes, by reloading services."
		echo ""
		echo "Important Note:"
		echo "If domains were changed then make sure to manually obtain new certificate"
		echo "with \`ut4ms cert obtain\` before executing this command."
		echo ""
		echo "Syntax:"
		echo "	$SCRIPT_COMMAND self config"
	fi
else
	echo "Description:"
	echo "Perform operation which handles the \`$SCRIPT_COMMAND\` command itself."
	echo ""
	echo "Syntax:"
	echo "	$SCRIPT_COMMAND self <command> ..."
	echo ""
	echo "Commands:"
	echo "	update"
	echo "	install"
	echo "	uninstall"
	echo "	config"
fi