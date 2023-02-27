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

  success "Backup config created at ${absoluteConfigDir}"
  echo 
  msg "Usage:"
  msg "./infrabackup backup ${backupName} # To run the backup"
  msg "./infrabackup cron enable ${backupName} # To install the cronjob"
  echo
  warn "#############################################################"
  warn "# Important! Fill the config, include.list and exclude.list #"
  warn "#############################################################"
  echo
  success "Good luck!"

  exit 0
}
