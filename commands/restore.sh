#!/usr/bin/env bash

restore() {

  $(validateSystem >/dev/null)
  validateSystemExitCode=$?

  if [[ "${validateSystemExitCode}" -ne 0 ]]; then
    error "System does not meet infrabackup requirements, run infrabackup validate-system for more information."
    exit 1
  fi

  backupName="${1}"

  if [[ -z "${backupName}" ]]; then
    error "No backup name provided"
    exit 1
  fi

  # Absolute path
  absoluteConfigDir=$(getAbsoluteConfigDir "${backupName}")

  if [[ -z "${absoluteConfigDir}" ]]; then
    error "Couldnt find config directory with name '${backupName}'"
    exit 1
  fi

  RESTORE_TIMESTAMP="${2}"

  if [[ -z "${RESTORE_TIMESTAMP}" ]]; then
    error "Please pass a restore timestamp in rdiff-backup format"
    exit 1
  fi

  RESTORE_WHAT_FILE_OR_DIRECTORY="${3}"

  if [[ -z "${RESTORE_WHAT_FILE_OR_DIRECTORY}" ]]; then
    error "Please pass a file or directory to restore from the rdiff backup"
    exit 1
  fi

  TARGET_DIRECTORY="${4}"

  if [[ -z "${TARGET_DIRECTORY}" ]]; then
    error "Please pass a target directory to restore your file or directory to"
    exit 1
  fi

  if [[ ! -d "${TARGET_DIRECTORY}" ]]; then

    read -p "${TARGET_DIRECTORY} does not exists, would you like to create it? [y/N]" -n 1 -r
    echo

    if [[ $REPLY =~ ^[Yy]$ ]]; then

      mkdir -p "${TARGET_DIRECTORY}"

      if [[ $? -ne 0 ]]; then
        error "Failed to create directory ${TARGET_DIRECTORY}"
        exit 1
      fi

    else
      error "No confirmation received, aborting."
      exit 1
    fi

  fi

  RDIFF_RESTORE_COMMAND=$(buildRdiffRestoreCommand "${absoluteConfigDir}" "${RESTORE_TIMESTAMP}" "${RESTORE_WHAT_FILE_OR_DIRECTORY}" ${TARGET_DIRECTORY})

  if [[ -z "${RDIFF_RESTORE_COMMAND}" ]]; then
    error "Failed building the rdiff restore command. Please check your config (infrabackup show) and validate your system (infrabackup validate-system)"
    exit $?
  fi
  
  bash -c "${RDIFF_RESTORE_COMMAND}"

  if [ $? -ne 0 ]; then
    error "Restore command had an error"
    return 1
  fi
  
  return 0
}
