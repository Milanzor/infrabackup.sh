#!/usr/bin/env bash

buildRdiffCommand() {

  if [[ $(systemHasRdiffBackupInstalled) = "false" ]]; then
    exit 1
  fi

  local absoluteConfigDir="${1}"

  local RDIFF_ARGS=$(getConfigValue "${absoluteConfigDir}" "rdiff_args")

  # Yes, RSYNC, that's where we get our rdiff source directory from
  local SOURCE_DIRECTORY=$(getConfigValue "${absoluteConfigDir}" "rsync_target")

  local RDIFF_TARGET_DIRECTORY=$(getConfigValue "${absoluteConfigDir}" "rdiff_target")

  echo "mkdir -p ${RDIFF_TARGET_DIRECTORY} && rdiff-backup ${RDIFF_ARGS} ${SOURCE_DIRECTORY} ${RDIFF_TARGET_DIRECTORY} 2>&1 | tee -a ${LOGFILE}"
}

systemHasRdiffBackupInstalled() {

  # Test if the system has rdiff-backup installed
  rdiff-backup --version >/dev/null 2>&1
  HAS_RDIFF=$?

  if [[ $HAS_RDIFF -ne 0 ]]; then
    echo "false"
    exit 1
  fi

  echo "true"
  exit 0
}
