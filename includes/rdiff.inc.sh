#!/usr/bin/env bash

buildRdiffCommand() {

  local absoluteConfigDir="${1}"

  local RDIFF_ARGS=$(getConfigValue "${absoluteConfigDir}config.json" rdiff.args)

  # Yes, RSYNC, that's where we get our rdiff source directory from
  local SOURCE_DIRECTORY=$(getConfigValue "${absoluteConfigDir}config.json" rsync.target)

  local RDIFF_TARGET_DIRECTORY=$(getConfigValue "${absoluteConfigDir}config.json" rdiff.target)

  echo "rdiff-backup ${RDIFF_ARGS} ${SOURCE_DIRECTORY} ${RDIFF_TARGET_DIRECTORY}"
}
