#!/usr/bin/env bash

backup() {

  configId=$1

  if ! checkConfigExists $configId; then
    error "No configDir passed or the directory does not exist does not exist"
    exit 1
  fi

  setlogfile $1

  # Absolute path
  configDir="${INFRABACKUP_INSTALLATION_DIRECTORY}/configs/$1"

  HAS_ANY_ERROR=false

  # Fetch the target ssh host
  local TARGET_HOST=$(getConfigValue $configDir/config.json host)

  msg "Starting backup ${configDir}"

  ##################
  ## BEFORE RSYNC ##
  ##################

  local RUN_BEFORE_RSYNC=$(getConfigValue $configDir/config.json scripts.before_rsync[])

  echo "${RUN_BEFORE_RSYNC}" | while read i; do

    if [[ -z "${i}" ]]; then
      break
    fi

    msg "Running 'before_rsync' command '${i}'"

    eval "${i}"

    if [ $? -ne 0 ]; then
      HAS_ANY_ERROR=true
      msg "before_rsync command had an error"
    fi
  done

  ###########
  ## RSYNC ##
  ###########

  local RSYNC_ARGS=$(getConfigValue $configDir/config.json rsync.args)
  local RSYNC_TARGET_DIRECTORY=$(getConfigValue $configDir/config.json rsync.target)

  # If the rsync target does not exist, create it
  if [[ ! -d "${RSYNC_TARGET_DIRECTORY}" ]]; then
    mkdir -p "${RSYNC_TARGET_DIRECTORY}"
  fi

  local RSYNC_COMMAND=$(buildRsyncCommand "${RSYNC_ARGS}" "${configDir}/include.list" "${configDir}/exclude.list" "${RSYNC_HOST}" "${RSYNC_TARGET_DIRECTORY}")

  msg "Starting rsync"

  eval "${RSYNC_COMMAND}"

  if [ $? -ne 0 ]; then
    HAS_ANY_ERROR=true
    msg "Rsync command had an error"
  else
    msg "rsync success"
  fi

  #################
  ## AFTER RSYNC ##
  #################

  local RUN_AFTER_RSYNC=$(getConfigValue $configDir/config.json scripts.after_rsync[])

  echo "${RUN_AFTER_RSYNC}" | while read i; do

    if [[ -z "${i}" ]]; then
      break
    fi

    msg "Running 'after_rsync' command '${i}'"

    eval "${i}"

    if [ $? -ne 0 ]; then
      HAS_ANY_ERROR=true
      msg "after_rsync command had an error"
    fi
  done

  ###########
  ## RDIFF ##
  ###########

  local RDIFF_ARGS=$(getConfigValue $configDir/config.json rdiff.args)
  local RDIFF_TARGET_DIRECTORY=$(getConfigValue $configDir/config.json rdiff.target)

  # If the rsync target does not exist, create it
  if [[ ! -d "${RDIFF_TARGET_DIRECTORY}" ]]; then
    mkdir -p "${RDIFF_TARGET_DIRECTORY}"
  fi

  local RDIFF_COMMAND=$(buildRdiffCommand "${RDIFF_ARGS}" "${RSYNC_TARGET_DIRECTORY}" "${RDIFF_TARGET_DIRECTORY}")

  # If the diff target does not exist, create it
  if [[ ! -d "${RDIFF_TARGET_DIRECTORY}" ]]; then
    mkdir -p "${RDIFF_TARGET_DIRECTORY}"
  fi

  msg "Starting rdiff"

  eval "${RDIFF_COMMAND}"

  if [ $? -ne 0 ]; then
    HAS_ANY_ERROR=true
    msg "Rsync command had an error"
  else
    msg "rsync success"
  fi

  #################
  ## AFTER RDIFF ##
  #################

  local RUN_AFTER_RDIFF=$(getConfigValue $configDir/config.json scripts.after_rdiff[])

  echo "${RUN_AFTER_RDIFF}" | while read i; do

    if [[ -z "${i}" ]]; then
      break
    fi
    msg "Running 'after_rdiff' command '${i}'"

    eval "${i}"

    if [ $? -ne 0 ]; then
      HAS_ANY_ERROR=true

      echo $HAS_ANY_ERROR
      msg "after_rdiff command had an error"
    fi
  done

  local MAIL_SUBJECT=$(getConfigValue $configDir/config.json mail.subject)
  local MAIL_TO=$(getConfigValue $configDir/config.json mail.to)

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

    echo "echo -e "${MAIL_CONTENTS}" | mutt -s "${MAIL_SUBJECT}" -a "${LOGFILE}" -- "${MAIL_TO}""
  fi
  return 0
}
