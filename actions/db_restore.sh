DB_FILE=$1

if [[ -z "$DB_FILE" ]]; then
	echo "Please specify file produced by \`db_dump.sh\` as first argument."
	exit
fi

# make sure only database container is running
docker-compose -f /app/UT4MasterServer/docker-compose.yml down
docker-compose -f /app/UT4MasterServer/docker-compose.yml up -d mongo

# restore database
docker cp $DB_FILE mongo:/data/dump.gz
docker exec -it mongo mongorestore --username=devroot --password=devroot --host=localhost --gzip --drop --archive=/data/dump.gz

# clean up after ourselves
docker exec -it mongo rm /data/dump.gz

echo "Once you are sure database has been put in desired state, please run \`start.sh\` to turn server back on"