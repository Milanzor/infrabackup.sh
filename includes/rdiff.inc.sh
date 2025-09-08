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

buildRdiffListIncrementsCommand() {

  if [[ $(systemHasRdiffBackupInstalled) = "false" ]]; then
    exit 1
  fi

  local absoluteConfigDir="${1}"

  local RDIFF_ARGS="--list-increments"

  local RDIFF_TARGET_DIRECTORY=$(getConfigValue "${absoluteConfigDir}" "rdiff_target")

  echo "rdiff-backup ${RDIFF_ARGS} ${RDIFF_TARGET_DIRECTORY} 2>&1 | tee -a ${LOGFILE}"
}

buildRdiffPurgeCommand() {

  if [[ $(systemHasRdiffBackupInstalled) = "false" ]]; then
    exit 1
  fi

  local absoluteConfigDir="${1}"
  local REMOVE_OLDER_THAN=$(getConfigValue "${absoluteConfigDir}" "rdiff_remove_older_than")

  if [[ -z "${REMOVE_OLDER_THAN}" ]]; then
    exit 1
  fi

  # --force to tell rdiff we dont mind removing more than 1 increment
  local RDIFF_ARGS="-v5 --print-statistics --remove-older-than \"${REMOVE_OLDER_THAN}\" --force"

  local RDIFF_TARGET_DIRECTORY=$(getConfigValue "${absoluteConfigDir}" "rdiff_target")

  echo "rdiff-backup ${RDIFF_ARGS} ${RDIFF_TARGET_DIRECTORY} 2>&1 | tee -a ${LOGFILE}"
}

buildRdiffVerifyCommand() {

  if [[ $(systemHasRdiffBackupInstalled) = "false" ]]; then
    exit 1
  fi

  local absoluteConfigDir="${1}"

  local RDIFF_TARGET_DIRECTORY=$(getConfigValue "${absoluteConfigDir}" "rdiff_target")

  # Verify the integrity of the rdiff-backup repository
  local RDIFF_ARGS="-v5 --verify"

  echo "rdiff-backup ${RDIFF_ARGS} ${RDIFF_TARGET_DIRECTORY} 2>&1 | tee -a ${LOGFILE}"
}

buildRdiffRestoreCommand() {

  if [[ $(systemHasRdiffBackupInstalled) = "false" ]]; then
    exit 1
  fi

  local absoluteConfigDir="${1}"

  local RESTORE_TIMESTAMP="${2}"
  local RESTORE_WHAT_FILE_OR_DIRECTORY="${3}"
  local TARGET_DIRECTORY="${4}"

  local RDIFF_TARGET_DIRECTORY=$(getConfigValue "${absoluteConfigDir}" "rdiff_target")

  local RDIFF_ARGS="-v5 -r ${RESTORE_TIMESTAMP} ${RDIFF_TARGET_DIRECTORY}${RESTORE_WHAT_FILE_OR_DIRECTORY} ${TARGET_DIRECTORY}$(basename "${RESTORE_WHAT_FILE_OR_DIRECTORY}")"


  echo "rdiff-backup ${RDIFF_ARGS}"
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
