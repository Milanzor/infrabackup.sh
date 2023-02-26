#!/usr/bin/env bash

backup() {

  backupName="${1}"

  if [[ -z "${backupName}" ]]; then
    logError "No name provided"
    exit 1
  fi

  # Absolute path
  absoluteConfigDir=$(getAbsoluteConfigDir "${backupName}")

  if [[ $? -ne 0 ]]; then
    logError "Couldnt find config directory with name '${backupName}'"
    exit 1
  fi

  setlogfile $absoluteConfigDir

  log "Starting backup ${backupName}"

  HAS_ANY_ERROR=false

  ## BEFORE-ALL HOOKS ##
  runHooks "${backupName}" "before-all"

  if [[ $? -ne 0 ]]; then
    logError "before-all give a non-zero exit code"
    exit $?
  fi

  # Fetch the target ssh host
  local TARGET_HOST=$(getConfigValue $absoluteConfigDir host)

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

  bash -c "${RSYNC_COMMAND}"

  if [ $? -ne 0 ]; then
    HAS_ANY_ERROR=true
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

  local RDIFF_TARGET_DIRECTORY=$(getConfigValue $absoluteConfigDir rdiff.target)
  local RDIFF_COMMAND=$(buildRdiffCommand "${absoluteConfigDir}")

  # If the diff target does not exist, create it
  if [[ ! -d "${RDIFF_TARGET_DIRECTORY}" ]]; then
    mkdir -p "${RDIFF_TARGET_DIRECTORY}"
  fi

  log "Starting rdiff"

  bash -c "${RDIFF_COMMAND}"

  if [ $? -ne 0 ]; then
    HAS_ANY_ERROR=true
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

  local MAIL_SUBJECT=$(getConfigValue $absoluteConfigDir mail.subject)
  local MAIL_TO=$(getConfigValue $absoluteConfigDir mail.to)

  ###########
  ## EMAIL ##
  ###########
  if [[ ! -z "${MAIL_TO}" ]]; then

    # TODO THIS DOESNT WORK
    if [[ "$HAS_ANY_ERROR" == true ]]; then
      local MAIL_SUBJECT="Infrabackup ${configId} finished with errors"
      local MAIL_CONTENTS="Please check the log."

    else
      local MAIL_SUBJECT="Infrabackup ${configId} finished successfully"
      local MAIL_CONTENTS="Nothing to see here!"
    fi

    echo $MAIL_SUBJECT
    #        echo -e "${MAIL_CONTENTS}" | mutt -s "${MAIL_SUBJECT}" -a "${LOGFILE}" -- "${MAIL_TO}"

  fi
  return 0
}
