#!/usr/bin/env bash

fiddle() {

  # Absolute path
  absoluteConfigDir=$(getAbsoluteConfigDir "milan.test")
  LOG_DIRECTORY=$(getConfigValue $absoluteConfigDir "log_directory")

  backupName="milan.test"
  HAS_ANY_ERRORS=true

  local MAIL_CONTENTS=$(buildEmail "${HAS_ANY_ERRORS}" "${backupName}")

  echo -e "${MAIL_CONTENTS}"

}
