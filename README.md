# config

```bash

declare -A CONFIG

## Rsync
CONFIG[rsync_args]="-arv --inplace --delete --stats"
CONFIG[rsync_target]="/home/milan/projects/infrabackup.sh/demo/milan.test/rsync/"

## Rdiff
CONFIG[rdiff_args]="-v5 --print-statistics --exclude-device-files --exclude-fifos --exclude-sockets --preserve-numerical-ids --exclude-other-filesystems"
CONFIG[rdiff_target]="/home/milan/projects/infrabackup.sh/demo/milan.test/rdiff/"

# Mail
CONFIG[mail_to]="webmaster@vastgoedflow.nl"


```

# TODO

- infrabackup show => Show more details
- infrabackup new => Build a new config
- infrabackup purge => Purge rdiff backups older than <config var> + log files too
- infrabackup restore => Restore stuff
- hooks => use EXPORT

# DONE

- infrabackup cron enable
- infrabackup cron disable
- infrabackup backup $backupName
- infrabackup show
