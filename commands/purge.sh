#!/usr/bin/env bash

purge() {

  $(validateSystem >/dev/null)
  validateSystemExitCode=$?

  if [[ "${validateSystemExitCode}" -ne 0 ]]; then
    error "System does not meet infrabackup requirements, run infrabackup validate-system for more information."
    exit 1
  fi

  backupName="${1}"

  if [[ -z "${backupName}" ]]; then
    error "No name provided"
    exit 1
  fi

  # Absolute path
  absoluteConfigDir=$(getAbsoluteConfigDir "${backupName}")

  if [[ -z "${absoluteConfigDir}" ]]; then
    error "Couldnt find config directory with name '${backupName}'"
    exit 1
  fi

  setlogfile "${absoluteConfigDir}" "purge"

  log "Starting purge for ${backupName}"

  export HAS_ANY_ERROR=false

  ## BEFORE-PURGE HOOKS ##
  runHooks "${backupName}" "before-purge"

  if [[ $? -ne 0 ]]; then
    logError "before-purge give a non-zero exit code"
    exit $?
  fi

  log "Listing rdiff increments"

  local RDIFF_LIST_INCREMENTS_COMMAND=$(buildRdiffListIncrementsCommand "${absoluteConfigDir}")

  if [[ -z "${RDIFF_LIST_INCREMENTS_COMMAND}" ]]; then
    logError "Failed building the rdiff list increment command. Please check your config (infrabackup show) and validate your system (infrabackup validate-system)"
    exit $?
  fi

  bash -c "${RDIFF_LIST_INCREMENTS_COMMAND}"

  if [ $? -ne 0 ]; then
    export HAS_ANY_ERROR=true
    logError "rdiff list increments command had an error"
  fi

  log "Purging"

  local RDIFF_PURGE_COMMAND=$(buildRdiffPurgeCommand "${absoluteConfigDir}")

  if [[ -z "${RDIFF_PURGE_COMMAND}" ]]; then
    logError "Failed building the rdiff purge command. Please check your config (infrabackup show) and validate your system (infrabackup validate-system)"
    exit $?
  fi

  bash -c "${RDIFF_PURGE_COMMAND}"

  if [ $? -ne 0 ]; then
    export HAS_ANY_ERROR=true
    log "rdiff purge error"
  fi

  local MAIL_TO=$(getConfigValue $absoluteConfigDir "mail_to")

  ###########
  ## EMAIL ##
  ###########

  # Test if the system has MUTT
  # TODO MAKE FUNCTION
  mutt -h >/dev/null 2>&1
  HAS_MUTT=$?

  if [[ $HAS_MUTT -eq 0 && ! -z "${MAIL_TO}" ]]; then

    if [[ "$HAS_ANY_ERROR" == true ]]; then
      local MAIL_SUBJECT="Infrabackup purge ${backupName} finished with errors"
      local MAIL_CONTENTS="Please check the log."
    else
      local MAIL_SUBJECT="Infrabackup purge ${backupName} finished successfully"
      local MAIL_CONTENTS="Nothing to see here!"
    fi

    log "Sending purge result email"

    echo -e "${MAIL_CONTENTS}" | mutt -s "${MAIL_SUBJECT}" -a "${LOGFILE}" -- "${MAIL_TO}"

  fi

  ## AFTER-PURGE HOOKS ##
  runHooks "${backupName}" "after-purge"

  if [[ $? -ne 0 ]]; then
    logError "after-purge give a non-zero exit code"
    exit $?
  fi

  return 0
}
