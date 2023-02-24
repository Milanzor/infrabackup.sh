#!/usr/bin/env bash

buildRsyncCommand() {

  absoluteConfigDir="${1}"

  local RSYNC_ARGS=$(getConfigValue "${absoluteConfigDir}config.json" rsync.args)
  local RSYNC_TARGET_DIRECTORY=$(getConfigValue "${absoluteConfigDir}config.json" rsync.target)
  local HOST=$(getConfigValue "${absoluteConfigDir}config.json" host)

  if [[ -f "${absoluteConfigDir}include.list" ]]; then
    RSYNC_ARGS="${RSYNC_ARGS} --files-from='${absoluteConfigDir}include.list'"
  fi
  if [[ -f "${absoluteConfigDir}exclude.list" ]]; then
    RSYNC_ARGS="${RSYNC_ARGS} --exclude-from='${absoluteConfigDir}exclude.list'"
  fi

  # If the host is empty, we are backing up the current server
  # If it's not empty, append a : so rsync will go remote
  if [[ ! -z "${HOST}" ]]; then
    local HOST="${HOST}:"
  fi

  echo "rsync ${RSYNC_ARGS} ${HOST}/ ${RSYNC_TARGET_DIRECTORY}"
}
