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

## Jobs
Cron is meant to be used to run jobs/tasks on a regular basis.

To add, edit or remove jobs execute command `crontab -e` and edit the file. Use [crontab guru](https://crontab.guru/) to determine timings. Here is an example content:
```
@reboot /opt/ut4ms/jobs/on_boot.sh
* * * * * /opt/jobs/each_minute.sh
00 7 * * mon [ $(date +%d) -le 07 ] && /opt/ut4ms/jobs/monthly_on_first_monday.sh
00 7 * * tue /opt/ut4ms/jobs/weekly_on_tuesday.sh

```

The following jobs should be configured:
- Update DNS records to reflect current IP Address (happens on system boot)
- Start server (happens on system boot)
- Certificate needs to be renewed because it normally expires after 90 days
- Regular database dumps to ensure reliable database backups
- Update UT4MasterServer when newer version is available
- Update system packages (and certbot, docker-compose which are manually installed)
- Remove old logs


## Inspecting log files
There are a couple different logs:
- Apache logs (location: `/var/log/httpd`)
- Linux system logs (command: `journalctl`)
- Individual docker container logs (command: `docker logs <container_name>`)
- UT4MasterServer logs (location: `/app/UT4MasterServer/logs`)