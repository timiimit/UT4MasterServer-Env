DB_FILE=$1

if [[ -z "$DB_FILE" ]]; then
	echo "Please specify dump file as first argument."
	exit
fi

# make sure only database container is running
docker-compose -f /app/UT4MasterServer/docker-compose.yml down
docker-compose -f /app/UT4MasterServer/docker-compose.yml up -d mongo

# dump database to /app/dump.gz
docker exec -it mongo mongodump --username=devroot --password=devroot --host=localhost --gzip --archive=/data/dump.gz
docker cp mongo:/data/dump.gz $DB_FILE

# clean up after ourselves
docker exec -it mongo rm /data/dump.gz

# start all containers back up
docker-compose -f UT4MasterServer/docker-compose.yml up -d