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

  _buildCronFile "${absoluteConfigDir}"

  if [[ $? -ne 0 ]]; then
    error "Couldnt build Cronlog file"
    exit 1
  fi

  local cronFilePath=$(getCronFilePath)
  local cronFile=$(getCronFileName "${absoluteConfigDir}")

  if [[ -L "/etc/cron.d/${cronFile}" ]]; then
    success "Cron ${cronFile} was already enabled, successfully refreshed"
    exit 0
  fi

  # Install the cron.d file (using a symlink)
  ln -s "${cronFilePath}${cronFile}" "/etc/cron.d/${cronFile}"

  if [[ $? -ne 0 ]]; then
    error "Couldnt install cron symlink"
    exit 1
  fi

  success "Cron ${cronFile} successfully enabled"
  exit 0

}

cronDisable() {
  local absoluteConfigDir="${1}"

  local cronFile=$(getCronFileName "${absoluteConfigDir}")

  if [[ ! -L "/etc/cron.d/${cronFile}" ]]; then
    error "Cron ${cronFile} was not enabled"
    exit 1
  fi

  rm "/etc/cron.d/${cronFile}"

  if [[ $? -ne 0 ]]; then
    error "Failed to remove symlink, cron remains installed (${cronFile})"
    exit 1
  fi

  success "Cron ${cronFile} successfully disabled"
  exit 0
}

_buildCronFile() {

  local absoluteConfigDir="${1}"

  CRON_SCHEDULE=$(getConfigValue $absoluteConfigDir "cron")

  if [[ -z "${CRON_SCHEDULE}" ]]; then
    error "No cron set in config.json"
    return 1
  fi

  local cronFilePath=$(getCronFilePath)
  local cronFile=$(getCronFileName "${absoluteConfigDir}")

  # Create the config/cron directory
  if [[ ! -d "${cronFilePath}" ]]; then
    mkdir -p "${cronFilePath}"
  fi

  CRON_COMMAND="# DO NOT MANUALLY EDIT THIS FILE\n"
  CRON_COMMAND="${CRON_COMMAND}# THIS FILE WAS CREATED WITH INFRABACKUP (${INFRABACKUP_INSTALLATION_DIRECTORY})\n"
  CRON_COMMAND="${CRON_COMMAND}${CRON_SCHEDULE}"
  #  CRON_COMMAND="${CRON_COMMAND}* * * * *"
  CRON_COMMAND="${CRON_COMMAND} root"
  CRON_COMMAND="${CRON_COMMAND} ${INFRABACKUP_INSTALLATION_DIRECTORY}/"
  CRON_COMMAND="${CRON_COMMAND}infrabackup \"backup\" \"${backupName}\""

  # End with a newline
  CRON_COMMAND="${CRON_COMMAND}\n"
  #  CRON_COMMAND="${CRON_COMMAND}0 * * * * root date >> /tmp/cron_tmp >/dev/null 2>&1"
  #  CRON_COMMAND="${CRON_COMMAND}\n"

  echo -e "$CRON_COMMAND" >"${cronFilePath}${cronFile}"
  chmod 644 "${cronFilePath}${cronFile}"

  if [[ -f "${cronFilePath}${cronFile}" ]]; then
    return 0
  fi

  error "Failed to _buildCronFile"
  return 1

}