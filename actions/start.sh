#!/bin/sh

if [ $1 -eq "--help" ]; do
	echo ""
	exit
fi

docker-compose -f UT4MasterServer/docker-compose.yml up -d