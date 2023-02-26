#!/usr/bin/env bash

fiddle() {
  backupName="${1}"

  local absoluteConfigDir=$(getAbsoluteConfigDir "${backupName}")
  cron=$(getConfigValue "${absoluteConfigDir}" "cron")
  if [[ -z "${cron}" ]]; then
    echo empty
  fi
echo $cron
}
