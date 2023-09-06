#!/bin/sh

ensure_mongo_only() {
	docker-compose -f docker-compose.yml up -d mongo 1>/dev/null
	return 0
}

remove_tmp_file() {
	docker exec -i mongo rm /data/dump.gz
	return 0
}

if [ "$1" == "dump" ]; then
	if [ ! -f "$2" ]; then
		# make output dir if it doesn't exist
		dir=$(dirname "$2")
		mkdir -p $dir

		ensure_mongo_only

		# dump database
		docker exec -i mongo mongodump --username=devroot --password=devroot --host=localhost --gzip --archive=/data/dump.gz
		docker cp mongo:/data/dump.gz "$2"

		remove_tmp_file

		echo ""
		echo "db has been dumped to \`""$2""\`."
		echo "Mongo container is the only container that is running."
	else
		echo "Description:"
		echo "Make a reliable database dump into specified file."
		echo "This is achieved in 3 steps:"
		echo " 1) Stop server to ensure that database doesn't change in the"
		echo "    process of dumping."
		echo " 2) Dump database into a file."
		echo " 3) Start server back up."
		echo ""
		echo "Syntax:"
		echo "	$SCRIPT_COMMAND db dump <file>"
		echo ""
		exit
	fi
elif [ "$1" == "restore" ]; then
	if [ -f "$2" ]; then
		ensure_mongo_only

		# restore database
		docker cp "$2" mongo:/data/dump.gz
		docker exec -it mongo mongorestore --username=devroot --password=devroot --host=localhost --gzip --drop --archive=/data/dump.gz

		remove_tmp_file
		#docker-compose -f docker-compose.yml down mongo

		echo ""
		echo "db has been restored from \`""$2""\`."
		echo "Mongo container is the only container that is running."
	else
		echo "Description:"
		echo "Restore a reliable database dump from specified file."
		echo "This is achieved in 2 steps:"
		echo " 1) Stop server to ensure that database doesn't change in the"
		echo "    process of restoration."
		echo " 2) Restore database from a file."
		echo ""
		echo "IMPORTANT NOTE:"
		echo "You need to manually start server after running this command."
		echo "This command will leave the server off. It leaves it off so that"
		echo "you can check the validity of restoration before it starts again."
		echo ""
		echo "Syntax:"
		echo "	$SCRIPT_COMMAND db dump <filename>"
		echo ""
		exit
	fi
else
	echo "Description:"
	echo "Perform an action upon the database."
	echo ""
	echo "Syntax:"
	echo "	$SCRIPT_COMMAND db <command> ..."
	echo ""
	echo "Commands:"
	echo "	dump"
	echo "	restore"
	exit
fi