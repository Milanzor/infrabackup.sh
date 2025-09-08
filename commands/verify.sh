#!/usr/bin/env bash

verify() {

  $(validateSystem >/dev/null)
  validateSystemExitCode=$?

  if [[ "${validateSystemExitCode}" -ne 0 ]]; then
    error "System does not meet infrabackup requirements, run infrabackup validate-system for more information."
    exit 1
  fi

  local backupName="${1}"

  if [[ -z "${backupName}" ]]; then
    error "No backup name provided"
    exit 1
  fi

  # Absolute path
  local absoluteConfigDir=$(getAbsoluteConfigDir "${backupName}")

  if [[ -z "${absoluteConfigDir}" ]]; then
    error "Couldnt find config directory with name '${backupName}'"
    exit 1
  fi

  setlogfile "${absoluteConfigDir}" "verify"

  log "Verifying rdiff-backup repository integrity for ${backupName}"

  local RDIFF_VERIFY_COMMAND
  RDIFF_VERIFY_COMMAND=$(buildRdiffVerifyCommand "${absoluteConfigDir}")

  if [[ -z "${RDIFF_VERIFY_COMMAND}" ]]; then
    logError "Failed building the rdiff verify command. Please check your config (infrabackup show) and validate your system (infrabackup validate-system)"
    exit $?
  fi

  bash -c "${RDIFF_VERIFY_COMMAND}"

  if [ $? -ne 0 ]; then
    logError "rdiff verify error"
    return 1
  fi

  log "Verify finished successfully"
  return 0
}

