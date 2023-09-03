#!/bin/sh

export SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
export SCRIPT_COMMAND=$0

set -a # automatically export all variables
source $SCRIPT_DIR/config.cfg
set +a

cd $APP_ROOT_DIR

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
	exit
fi

"$SCRIPT_DIR/commands/$1.sh" ${@:2}