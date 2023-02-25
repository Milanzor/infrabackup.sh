#!/usr/bin/env bash

getConfigValue() {

  local absoluteConfigDir="${1}"
   configFile="${absoluteConfigDir}config.json"
  local CFG="$(<$configFile)"
  echo "$CFG" | jq -r '.'$2
}

getAbsoluteConfigDir() {

  local configDir="${INFRABACKUP_INSTALLATION_DIRECTORY}/configs/${1}/"

  if [[ ! -d "${configDir}" ]]; then
    error "configDir '${configDir}' does not exist"
    exit 1
  fi

  echo "${configDir}"
}
