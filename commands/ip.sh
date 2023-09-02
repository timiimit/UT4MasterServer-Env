#!/bin/sh

if [ -z "$1" ]; do
	curl -s https://api/ipify.org
else
	echo "Description:"
	echo "Get public IP Address of this machine"
	echo ""
	echo "Syntax:"
	echo "	ip"
fi