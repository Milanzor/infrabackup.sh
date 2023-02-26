#!/usr/bin/env bash

getCronFileName() {
  local absoluteConfigDir="${1}"
  local backupName=$(basename "${absoluteConfigDir}")
  local cleanedBackupname=$(echo "${backupName}" | tr -d '.')
  echo -e "infrabackup-cron-${cleanedBackupname}"
}

getCronFilePath() {
  echo -e "${INFRABACKUP_INSTALLATION_DIRECTORY}/crons/"
}
