#!/usr/bin/env bash

getConfigValue() {

  local absoluteConfigDir="${1}"
  local key="${2}"


  # Source the config
  source "${absoluteConfigDir}config"
  
  if [[ -v CONFIG ]]; then
    error "No config array set in ${absoluteConfigDir}config"
    exit 1
  fi

  echo -e "${CONFIG[${key}]}"
}

getAbsoluteConfigDir() {

  local configDir="${INFRABACKUP_INSTALLATION_DIRECTORY}/configs/${1}/"

  if [[ ! -d "${configDir}" ]]; then
    exit 1
  fi

  echo "${configDir}"
}
