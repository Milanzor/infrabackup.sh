# config.json

```json
{
  "cron": "*/5 * * * *",
  "host": "",
  "rsync": {
    "args": "-arv --inplace --delete --stats",
    "target": "/home/milan/projects/infrabackup.sh/demo/milan.test/rsync/"
  },
  "rdiff": {
    "args": "-v5 --print-statistics --exclude-device-files --exclude-fifos --exclude-sockets --preserve-numerical-ids --exclude-other-filesystems",
    "target": "/home/milan/projects/infrabackup.sh/demo/milan.test/rdiff/"
  },
  "mail": {
    "to": "webmaster@vastgoedflow.nl"
  }
}


```

# TODO

- infrabackup install
- infrabackup validate
- Fix mail

# DONE

- infrabackup cron enable
- infrabackup cron disable
- infrabackup backup $backupName
- infrabackup show
