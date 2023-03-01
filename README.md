![Awesome tool](https://img.shields.io/badge/awesome-tool-green)

# Version 1.0 - TODO

- battle test

# Version 2.0 - TODO
- rethink the ./configs directory? Option to pass a directory so we can place configs in other directories?
- infrabackup health $backupName => Check the health of the backups, see some data, how long backups take etc
- expand infrabackup validate-system => Check for orphaned cron symlinks and orphaned cron files in ./crons
- expand mailing features (HTML?)
- revamp absoluteConfigDir (because its passed around everywhere)
- expand infrabackup create => Ask questions
- Specify user that should run the commands?

# DONE

- infrabackup cron enable $backupName
- infrabackup cron disable $backupName
- infrabackup backup $backupName
- infrabackup show
- infrabackup create => Build a new config
- infrabackup show => Show more details
- hooks => use EXPORT
- infrabackup install
- infrabackup uninstall
- infrabackup purge $backupName + cron
- infrabackup restore => Restore stuff
