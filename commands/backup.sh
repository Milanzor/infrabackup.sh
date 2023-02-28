#!/usr/bin/env bash

backup() {

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

  setlogfile "${absoluteConfigDir}" "backup"

  log "Starting backup ${backupName}"

  export HAS_ANY_ERROR=false

  ## BEFORE-ALL HOOKS ##
  runHooks "${backupName}" "before-all"

  if [[ $? -ne 0 ]]; then
    logError "before-all give a non-zero exit code"
    exit $?
  fi

  # Fetch the target ssh host
  local TARGET_HOST=$(getConfigValue $absoluteConfigDir "host")

  ## BEFORE-RSYNC HOOKS ##
  runHooks $backupName "before-rsync"

  if [[ $? -ne 0 ]]; then
    logError "before-rsync give a non-zero exit code"
    exit $?
  fi

  ###########
  ## RSYNC ##
  ###########

  log "Starting rsync"

  local RSYNC_COMMAND=$(buildRsyncCommand "${absoluteConfigDir}")

  if [[ -z "${RSYNC_COMMAND}" ]]; then
    logError "Failed building the rsync command. Please check your config (infrabackup show) and validate your system (infrabackup validate-system)"
    exit $?
  fi

  bash -c "${RSYNC_COMMAND}"

  if [ $? -ne 0 ]; then
    export HAS_ANY_ERROR=true
    log "rsync command had an error"
  else
    log "rsync success"
  fi

  ## AFTER-RSYNC HOOKS ##
  runHooks $backupName "after-rsync"

  if [[ $? -ne 0 ]]; then
    logError "after-rsync give a non-zero exit code"
    exit $?
  fi

  ###########
  ## RDIFF ##
  ###########

  local RDIFF_TARGET_DIRECTORY=$(getConfigValue $absoluteConfigDir "rdiff_target")
  local RDIFF_COMMAND=$(buildRdiffCommand "${absoluteConfigDir}")

  if [[ -z "${RDIFF_COMMAND}" ]]; then
    logError "Failed building the rdiff-backup command. Please check your config (infrabackup show) and validate your system (infrabackup validate-system)"
    exit $?
  fi

  # If the diff target does not exist, create it
  if [[ ! -d "${RDIFF_TARGET_DIRECTORY}" ]]; then
    mkdir -p "${RDIFF_TARGET_DIRECTORY}"
  fi

  log "Starting rdiff"

  bash -c "${RDIFF_COMMAND}"

  if [ $? -ne 0 ]; then
    export HAS_ANY_ERROR=true
    log "rdiff command had an error"
  else
    log "rdiff success"
  fi

  ## AFTER-RDIFF HOOKS ##
  runHooks $backupName "after-rdiff"

  if [[ $? -ne 0 ]]; then
    logError "after-rdiff hook give a non-zero exit code"
    exit $?
  fi

  local MAIL_TO=$(getConfigValue $absoluteConfigDir "mail_to")

  ###########
  ## EMAIL ##
  ###########

  if [[ $(systemCanSendEmails) = "true" && ! -z "${MAIL_TO}" ]]; then

    if [[ "$HAS_ANY_ERROR" == true ]]; then
      local MAIL_SUBJECT="Infrabackup ${backupName} finished with errors"
      local MAIL_CONTENTS="Please check the log."
    else
      local MAIL_SUBJECT="Infrabackup ${backupName} finished successfully"
      local MAIL_CONTENTS="Nothing to see here!"
    fi

    ## BEFORE-MAIL HOOKS ##
    runHooks "${backupName}" "before-mail"

    if [[ $? -ne 0 ]]; then
      logError "before-mail give a non-zero exit code"
      exit $?
    fi

    log "Sending result email"

    echo -e "${MAIL_CONTENTS}" | mutt -s "${MAIL_SUBJECT}" -a "${LOGFILE}" -- "${MAIL_TO}"

    ## AFTER-MAIL HOOKS ##
    runHooks "${backupName}" "after-mail"

    if [[ $? -ne 0 ]]; then
      logError "after-mail give a non-zero exit code"
      exit $?
    fi
  fi

  ## AFTER-ALL HOOKS ##
  runHooks "${backupName}" "after-all"

  if [[ $? -ne 0 ]]; then
    logError "after-all give a non-zero exit code"
    exit $?
  fi

  return 0
}
