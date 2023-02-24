#!/usr/bin/env bash

getConfigValue() {
  local CFG="$(<$1)"
  echo "$CFG" | jq -r '.'$2
}

getAbsoluteConfigDir() {

  configDir="${INFRABACKUP_INSTALLATION_DIRECTORY}/configs/${1}/"

  if [[ ! -d "${configDir}" ]]; then
    error "configDir '${configDir}' does not exist"
    exit 1
  fi

  echo "${configDir}"
}
