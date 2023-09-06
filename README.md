# UT4MasterServer-Env
Helpful information and scripts for managing live UT4MasterServer.

## Installation
When setting up the environment for running UT4MasterServer for the first time you should do the following:
```
cd /opt/ut4ms # or any other directory
git clone https://github.com/timiimit/UT4MasterServer-Env.git .
./ut4ms self install --deps-only
./ut4ms self install
```

## How to run operations
- Nearly all actions that can be performed require root privileges
- Command `ut4ms` can be used to perform any action available
- `ut4ms` command has sub-commands which may in turn have more sub-commands
- To get a list of all information about a command add `--help` argument

## Hardcoded directories
- `/etc/letsencrypt` contains ssl certificate information
- `/opt/certbot` contains certbot installation
- `/usr/local/bin` contains manually installed programs

## Jobs
Systemd timers can be used to run services at specific times. All services and their timers are in [systemd](systemd) directory.

## Inspecting log files
There are a couple different logs:
- Apache logs (location: `/var/log/httpd`)
- Linux system logs (command: `journalctl`)
- Individual docker container logs (command: `docker logs <container_name>`)
- UT4MasterServer logs (location: `/app/UT4MasterServer/logs`)