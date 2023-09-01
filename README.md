# UT4MasterServer-Env
Helpful information and scripts for managing live UT4MasterServer.

## How to run commands
- It is assumed that you are logged in as root user. If you aren't then use command `su` and enter root's password.
- this repo is assumed to be located in `/app`

## Jobs
Directory `jobs` is meant to hold scripts for jobs that need to run on regular basis. The following jobs should be configured:
- Update DNS records to reflect current IP Address (happens on system boot)
- Start `/app/start.sh` script to start up the web server (happens on system boot)
- Certificate needs to be renewed because it normally expires after 90 days
- Regular database dumps to ensure reliable database backups
- Update UT4MasterServer when newer version is available
- Update system packages (and certbot, docker-compose which are manually installed)
- Remove old logs

To add, edit or remove timings and what jobs get executed use command `crontab -e` and edit the file. Use [crontab guru](https://crontab.guru/) to determine timings. Here is an example `crontab`:
```
@reboot /app/jobs/update_dns.sh
0 0 1 * * /app/jobs/cert_renew.sh
```

## Maintenance

### Manually start the server
```
start.sh
```
This will start the server.

### Manually stop the server
```
stop.sh
```
This will stop the server. If apache is properly configured, then users should see the "under maintenance" web page.
### Dump database to a file
```
db_dump.sh <output_file>
```
This will first stop the server if it is running. Then it will start just `mongo` container. Then it will initiate db dumping. Once it finishes it **WILL** start the server back up.

### Restore database from a file
```
db_restore.sh <input_file>
```
This will first stop the server if it is running. Then it will start just `mongo` container. Then it will initiate db restoration. Once it finishes it **WILL NOT** start the server back up for the purpose of allowing manual inspection of validity of restoration. Manually start the server afterwards.

### Inspecting log files
There are a couple different logs:
- Apache logs (location: `/var/log/httpd`)
- Linux system logs (command: `journalctl`)
- Individual docker container logs (command: `docker logs <container_name>`)
- UT4MasterServer logs (location: `/app/UT4MasterServer/logs`)