#!/usr/bin/env bash

buildRdiffCommand() {

  local absoluteConfigDir="${1}"

  local RDIFF_ARGS=$(getConfigValue "${absoluteConfigDir}" rdiff.args)

  # Yes, RSYNC, that's where we get our rdiff source directory from
  local SOURCE_DIRECTORY=$(getConfigValue "${absoluteConfigDir}" rsync.target)

  local RDIFF_TARGET_DIRECTORY=$(getConfigValue "${absoluteConfigDir}" rdiff.target)

  echo "mkdir -p ${RDIFF_TARGET_DIRECTORY} && rdiff-backup ${RDIFF_ARGS} ${SOURCE_DIRECTORY} ${RDIFF_TARGET_DIRECTORY}"
}
