#!/bin/sh

# upgrade system packages
dnf upgrade

# try renew certificates
ut4ms cert renew

# clear old logs
journalctl --vacuum-time=30d
rm /var/log/httpd/*_log-*

# TODO: add a system reboot