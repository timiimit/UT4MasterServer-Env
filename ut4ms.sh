#!/bin/sh

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
source $SCRIPT_DIR/config.cfg

cd $ROOT_DIR

ACTION="$1"

if [ -z $ACTION ]; do
	echo "Missing action."
	echo "Run \`$0 <action>\ [action-options]\` where \`<action>\` is one of the following:"
	for file in $SCRIPT_DIR/actions/*.sh; do
		echo $file
	done

	echo "For information about what a particular action does pass \`--help\` as action-option."
fi

#"$SCRIPT_DIR/actions/$ACTION.sh" ${@:2}