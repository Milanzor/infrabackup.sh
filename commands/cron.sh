#!/usr/bin/env bash

cron() {

  local subCommand="${1}"
  local backupName="${2}"

  if [[ -z "${subCommand}" ]]; then
    error "Please pass enable|disable"
    exit 1
  fi

  if [[ -z "${backupName}" ]]; then
    error "Please provide a valid backupName"
    exit 1
  fi

  # Absolute path
  local absoluteConfigDir=$(getAbsoluteConfigDir "${backupName}")

  if [[ -z "${absoluteConfigDir}" ]]; then
    error "Couldnt find config directory with name '${backupName}'"
    exit 1
  fi

  # Enable
  if [[ "${subCommand}" = "enable" ]]; then
    cronEnable "${absoluteConfigDir}"
    exit $?
  fi

  # Disable
  if [[ "${subCommand}" = "disable" ]]; then
    cronDisable "${absoluteConfigDir}"
    exit $?
  fi

  exit 0

}

cronEnable() {
  local absoluteConfigDir="${1}"

  CRON_SCHEDULE=$(getConfigValue $absoluteConfigDir cron)

  if [[ -z "${CRON_SCHEDULE}" ]]; then
    error "No cron set in config.json"
    exit 1
  fi

  echo $CRON_SCHEDULE 
  local cronFilePath=$(getCronFilePath "${absoluteConfigDir}")
  local cronFile=$(getCronFileName "${absoluteConfigDir}")

  # Create the config/cron directory
  if [[ ! -d "${cronFilePath}" ]]; then
    mkdir -p "${cronFilePath}"
  fi

  CRON_COMMAND="${CRON_SCHEDULE}"
  echo $CRON_COMMAND
  CRON_COMMAND="${CRON_COMMAND} root"
  CRON_COMMAND="${CRON_COMMAND} ${INFRABACKUP_INSTALLATION_DIRECTORY}"
  CRON_COMMAND="${CRON_COMMAND} infrabackup backup ${backupName}"

  echo $CRON_COMMAND
}

cronDisable() {
  local absoluteConfigDir="${1}"
}

getCronFileName() {
  local absoluteConfigDir="${1}"
  local backupName=$(basename "${absoluteConfigDir}")
  echo "infrabackup-${backupName}"
}

getCronFilePath() {
  local absoluteConfigDir="${1}"
  echo "${absoluteConfigDir}crons/"
}
