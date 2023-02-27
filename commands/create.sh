#!/usr/bin/env bash

create() {

  local backupName="${1}"

  if [[ -z "${backupName}" ]]; then
    error "Please provide a backupName"
    exit 1
  fi

  # To verify it doesnt already exists
  absoluteConfigDir=$(getAbsoluteConfigDir "${backupName}")

  if [[ -d "${absoluteConfigDir}" ]]; then
    error "Backup already exists"
    exit 1
  fi

  # No trailing slash
  absoluteConfigDir="${INFRABACKUP_INSTALLATION_DIRECTORY}/configs/${backupName}"

  mkdir "${absoluteConfigDir}"

  if [[ ! -d "${absoluteConfigDir}" ]]; then
    error "Failed to create config directory"
    exit 1
  fi

  # Copy the skeleton to the new directory
  cp -a "${INFRABACKUP_INSTALLATION_DIRECTORY}/skel/." "${absoluteConfigDir}"

  success "Done!"
  success "Backup config created at ${absoluteConfigDir}"
  success "Please go and fill in the config include and exclude lists"
  success "After that, you can use ./infrabackup backup ${backupName} to run the backup"
  success "And ./infrabackup cron enable ${backupName} to install the cronjob"
  echo
  success "Good luck!"

  exit 0
}
