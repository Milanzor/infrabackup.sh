#!/usr/bin/env bash

help() {

  VERSION=$(cat "${INFRABACKUP_INSTALLATION_DIRECTORY}/version")
  echo "# INFRABACKUP"
  echo "Version ${VERSION}"
  echo "By Milan van As"
  echo
  echo "# USAGE"
  echo "infrabackup show  - Shows all configs"
  echo "infrabackup backup <backupName> - Run the backup, replace <backupName> with the directory name as defined in ./configs"

  echo
}
