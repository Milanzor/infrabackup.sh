#!/usr/bin/env bash

fiddle() {

  backupName="${1}"

  local absoluteConfigDir=$(getAbsoluteConfigDir "${backupName}")

  getConfigValue "${absoluteConfigDir}" cron

}
