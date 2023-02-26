#!/usr/bin/env bash

getConfigValue() {

  local absoluteConfigDir="${1}"
  local configKey="${2}"
  local configFile="${absoluteConfigDir}config.json"
  local CFG="$(cat $configFile)"
  echo $CFG
  configValue=$(cat "$configFile" | jq -r '.'${configKey})

  if [[ "${configValue}" = "null" ]]; then
    configValue=""
  fi

  echo "${configValue}"
}

hasConfigKey() {

  local configFile="${absoluteConfigDir}config.json"
  local CFG="$(<$configFile)"
  echo "has(\"${2}\")"
  echo "$CFG"
  echo "$CFG" | jq -r $(echo "has(\"${2}\")")
}

getAbsoluteConfigDir() {

  local configDir="${INFRABACKUP_INSTALLATION_DIRECTORY}/configs/${1}/"

  if [[ ! -d "${configDir}" ]]; then
    exit 1
  fi

  echo "${configDir}"
}
