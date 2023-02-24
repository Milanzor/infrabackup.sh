#!/usr/bin/env bash

buildRsyncCommand() {

  local RSYNC_ARGS=$1
  local INCLUDE_LIST=$2
  local EXCLUDE_LIST=$3
  local HOST=$4
  local TARGET_DIRECTORY=$5

  # If the host is empty, we are backing up the current server
  # If it's not empty, append a : so rsync will go remote
  if [[ ! -z "${HOST}" ]]; then
    local HOST="${HOST}:"
  fi

  echo "rsync ${RSYNC_ARGS} --files-from='${INCLUDE_LIST}' --exclude-from='${EXCLUDE_LIST}' ${HOST}/ ${TARGET_DIRECTORY}"
}
