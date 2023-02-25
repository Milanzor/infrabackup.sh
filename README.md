# Directories

configs/
configs/flow.infra.vastgoedflow.nl/include.list
configs/flow.infra.vastgoedflow.nl/exclude.list
configs/flow.infra.vastgoedflow.nl/config.json

# config.json

```json
{
  "schedule": "0 10 * * * *",
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
  },
  "webhook": {
    "before": "https://localhost",
    "after": "https://localhost"
  }
}


```

infra-backup schedule list
infra-backup schedule enable
infra-backup schedule disable

infra-backup validate
infra-backup backup milan.test
