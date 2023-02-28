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
    error "Failed to install cron symlink"
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

  local CRON_SCHEDULE=$(getConfigValue $absoluteConfigDir "cron")

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

  local CRON_COMMAND="# DO NOT MANUALLY EDIT THIS FILE\n"
  local CRON_COMMAND="${CRON_COMMAND}# THIS FILE WAS CREATED WITH INFRABACKUP (${INFRABACKUP_INSTALLATION_DIRECTORY})\n"
  local CRON_COMMAND="${CRON_COMMAND}${CRON_SCHEDULE}"
  local CRON_COMMAND="${CRON_COMMAND} root"
  local CRON_COMMAND="${CRON_COMMAND} ${INFRABACKUP_INSTALLATION_DIRECTORY}/"
  local CRON_COMMAND="${CRON_COMMAND}infrabackup \"backup\" \"${backupName}\" >/dev/null 2>&1"

  # Rdiff purge cron

  local RDIFF_PURGE_CRON_SCHEDULE=$(getConfigValue $absoluteConfigDir "rdiff_purge_cron")
  if [[ ! -z "${RDIFF_PURGE_CRON_SCHEDULE}" ]]; then
    local CRON_COMMAND="${CRON_COMMAND}\n"
    local CRON_COMMAND="${CRON_COMMAND}${RDIFF_PURGE_CRON_SCHEDULE}"
    local CRON_COMMAND="${CRON_COMMAND} root"
    local CRON_COMMAND="${CRON_COMMAND} ${INFRABACKUP_INSTALLATION_DIRECTORY}/"
    local CRON_COMMAND="${CRON_COMMAND}infrabackup \"purge\" \"${backupName}\" >/dev/null 2>&1"

  fi

  # End with a newline
  local CRON_COMMAND="${CRON_COMMAND}\n"

  # Create the file with the cron contents
  echo -e "$CRON_COMMAND" >"${cronFilePath}${cronFile}"

  # 644 because cron.d requires files to be that
  chmod 644 "${cronFilePath}${cronFile}"

  if [[ -f "${cronFilePath}${cronFile}" ]]; then
    return 0
  fi

  error "Failed to _buildCronFile"
  return 1

}
