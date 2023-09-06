#!/bin/sh

export SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
export ROOT_DIR_ENV="$SCRIPT_DIR"
if [ -z "$SCRIPT_COMMAND" ]; then
	export SCRIPT_COMMAND="$0"

	if [ "$1" != "self" ]; then
		echo "Please use \`$SCRIPT_COMMAND self install\` before using this command."
		exit
	fi
fi

set -a # automatically export all variables
source $ROOT_DIR_ENV/config.cfg
set +a

cd $ROOT_DIR_APP

if [ ! -f "$ROOT_DIR_ENV/commands/$1.sh" ]; then
	echo "Syntax:"
	echo "	$SCRIPT_COMMAND <command> ..."
	echo ""
	echo "Commands:"
	for file in $ROOT_DIR_ENV/commands/*.sh; do
		filename="${file##*/}"
		echo "	${filename%.*}"
	done
	echo ""
	echo "For information about what a particular command does pass \`--help\` as the last argument."
	echo "Note that commands can have sub-commands which provide further detail with \`--help\` argument."
	echo ""
	exit
fi

"$ROOT_DIR_ENV/commands/$1.sh" ${@:2}