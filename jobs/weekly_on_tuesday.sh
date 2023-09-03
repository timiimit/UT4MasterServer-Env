#!/bin/sh

# do weekly db dump
ut4ms db dump /app/db_dumps/$(date --rfc-3339=date).gz

# try to update server and if new version is installed, rebuild the server
ut4ms server update && ut4ms server rebuild

