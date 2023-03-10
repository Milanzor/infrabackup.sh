#!/usr/bin/env bash

buildRsyncCommand() {

  absoluteConfigDir="${1}"

  local RSYNC_ARGS=$(getConfigValue "${absoluteConfigDir}" "rsync_args")
  local RSYNC_TARGET_DIRECTORY=$(getConfigValue "${absoluteConfigDir}" "rsync_target")
  local HOST=$(getConfigValue "${absoluteConfigDir}" "host")

  # Append the include list arg
  if [[ -f "${absoluteConfigDir}include.list" ]]; then
    RSYNC_ARGS="${RSYNC_ARGS} --files-from='${absoluteConfigDir}include.list'"
  fi

  # Append the exclude list arg
  if [[ -f "${absoluteConfigDir}exclude.list" ]]; then
    RSYNC_ARGS="${RSYNC_ARGS} --exclude-from='${absoluteConfigDir}exclude.list'"
  fi

  # If the host is empty, we are backing up the current server
  # If it's not empty, append a : so rsync will go remote
  if [[ ! -z "${HOST}" ]]; then
    local HOST="${HOST}:"
  fi

  echo "mkdir -p ${RSYNC_TARGET_DIRECTORY} && rsync ${RSYNC_ARGS} ${HOST}/ ${RSYNC_TARGET_DIRECTORY} 2>&1 | tee -a ${LOGFILE}"
}

systemHasRsyncInstalled() {

  # Test if the system has rsync installed
  rsync --version >/dev/null 2>&1
  HAS_RSYNC=$?

  if [[ $HAS_RSYNC -ne 0 ]]; then
    echo "false"
    exit 1
  fi

  echo "true"
  exit 0
}
