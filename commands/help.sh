#!/usr/bin/env bash

help() {

  VERSION=$(cat "${INFRABACKUP_INSTALLATION_DIRECTORY}/version")
  echo "Version: ${VERSION}"
  echo "Website: https://github.com/Milanzor/infrabackup.sh"
  echo "Author:  Milan van As (milanvanas@gmail.com)"
  echo "About:   Infrabackup is a wrapper around rsync and rdiff-backup."
  echo "         It facilitates hooking scripts at certain parts of a backup process"
  echo "         Backups are made using rsync and rdiff-backup"
  echo
  echo "Usage:"
  echo "infrabackup show                                  - Shows all configs"
  echo "infrabackup backup <backupName>                   - Run the backup, replace <backupName> with the directory name as defined in ./configs"
  echo "infrabackup purge <backupName>                    - Run the purge, replace <backupName> with the directory name as defined in ./configs"
  echo "infrabackup cron <enable|disable> <backupName>    - Enable or disable the backup cron (uses /etc/cron.d/ symlinks)"
  echo "infrabackup create <backupName>                   - Initialize a new backup config directory in <infrabackup>/configs"
  echo "infrabackup validate-system                       - Validates the system, checks all required commands (rsync/rdiff-backup/etc)"
  echo
}
