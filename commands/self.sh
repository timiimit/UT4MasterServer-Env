#!/bin/sh

if [ "$1" == "update" ]; then
	if [ -z "$2" ]; then
		git -C $ROOT_DIR_ENV pull
	else
		echo "Description:"
		echo "Update \`$SCRIPT_COMMAND\` command."
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
fi