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
    export HAS_ANY_ERROR=true
    logError "before-purge give a non-zero exit code"
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
    logError "rdiff purge error"
  fi

  ## AFTER-PURGE HOOKS ##
  runHooks "${backupName}" "after-purge"

  if [[ $? -ne 0 ]]; then
    export HAS_ANY_ERROR=true
    logError "after-purge give a non-zero exit code"

  fi

  local MAIL_TO=$(getConfigValue $absoluteConfigDir "mail_to")

  ###########
  ## EMAIL ##
  ###########

  if [[ $(systemCanSendEmails) = "true" && ! -z "${MAIL_TO}" ]]; then

    local MAIL_CONTENTS=$(buildEmail "${backupName}" "Purge" "${HAS_ANY_ERROR}" )
    local MAIL_SUBJECT=$(buildSubject "${backupName}" "Purge" "${HAS_ANY_ERROR}" )

    log "Sending purge result email"

    echo -e "${MAIL_CONTENTS}" | mutt -e "set content_type=text/html" -s "${MAIL_SUBJECT}" -a "${LOGFILE}" -- "${MAIL_TO}"

  fi

  return 0
}
