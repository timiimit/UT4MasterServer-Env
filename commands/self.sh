#!/bin/sh

command_location="/usr/local/bin/ut4ms"
systemd_dir="/etc/systemd/system"

if [ "$1" == "update" ]; then
	if [ -z "$2" ]; then

		# navigate into env repo for easier operation
		cd "$ROOT_DIR_ENV"

		# capture output while also displaying it to console
		exec 5>&1
		fetch_output="$(git fetch | tee /dev/fd/5)"
		exec 5<&-

		if [ -z "$fetch_output" ]; then
			echo "Already up to date."
			exit
		fi

		"./ut4ms.sh" self uninstall
		git stash push config.cfg 1>/dev/null
		git checkout -f HEAD 1>/dev/null
		git pull
		git stash pop 1>/dev/null
		"./ut4ms.sh" self install
	else
		echo "Description:"
		echo "Update \`$SCRIPT_COMMAND\` command."
		echo ""
		echo "Syntax:"
		echo "	$SCRIPT_COMMAND self update"
	fi
elif [ "$1" == "install" ]; then
	if [ -z "$2" ]; then
		# install global ut4ms command
cat >"$command_location" << EOF
#!/bin/bash
export SCRIPT_COMMAND="\$0"
"$ROOT_DIR_ENV/ut4ms.sh" "\$@"
EOF
		chmod 755 "$command_location"

		# install systemd unit files
		for systemd_file in $ROOT_DIR_ENV/systemd/*; do
			systemd_filename="${systemd_file##*/}"
			ln -s "$systemd_file" "$systemd_dir/$systemd_filename"
		done

		# ensure that systemd sees the changes
		systemctl daemon-reload
	else
		echo "Description:"
		echo "Install global \`ut4ms\` command and services."
		echo ""
		echo "Syntax:"
		echo "	$SCRIPT_COMMAND self update"
	fi
elif [ "$1" == "uninstall" ]; then
	if [ -z "$2" ]; then

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
		echo "Uninstall \`$SCRIPT_COMMAND\` command."
		echo ""
		echo "Syntax:"
		echo "	$SCRIPT_COMMAND self update"
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
fi