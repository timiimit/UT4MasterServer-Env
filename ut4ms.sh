#!/bin/sh

export SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
if [ -z "$SCRIPT_COMMAND" ]; then
	export SCRIPT_COMMAND="$0"

	if [ "$1" != "self" ]; then
		echo "Please use \`$SCRIPT_COMMAND self install\` before using this command."
		exit
	fi
fi

set -a # automatically export all variables
source $SCRIPT_DIR/config.cfg
set +a

cd $ROOT_DIR_APP

if [ ! -f "$SCRIPT_DIR/commands/$1.sh" ]; then
	echo "Syntax:"
	echo "	$SCRIPT_COMMAND <command> ..."
	echo ""
	echo "Commands:"
	for file in $SCRIPT_DIR/commands/*.sh; do
		filename="${file##*/}"
		echo "	${filename%.*}"
	done
	echo ""
	echo "For information about what a particular command does pass \`--help\` as the last argument."
	echo "Note that commands can have sub-commands which provide further detail with \`--help\` argument."
	echo ""
	exit
fi

"$SCRIPT_DIR/commands/$1.sh" ${@:2}