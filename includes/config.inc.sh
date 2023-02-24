#!/usr/bin/env bash

getConfigValue() {
  local CFG="$(<$1)"
  echo "$CFG" | jq -r '.'$2
}

checkConfigExists() {

  configDir=$1

  if [[ -z "$configDir" ]]; then
    return 1
  fi

  if [[ ! -d "${INFRABACKUP_INSTALLATION_DIRECTORY}/configs/${configDir}" ]]; then
    return 1
  fi

  return 0

}
