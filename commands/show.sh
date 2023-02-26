#!/usr/bin/env bash

show() {

  find "${INFRABACKUP_INSTALLATION_DIRECTORY}/configs/" -maxdepth 1 -mindepth 1 -type d | while read dir; do

    local backupName=$(basename "${dir}")
    local absoluteConfigDir=$(getAbsoluteConfigDir "${backupName}")

    local cron=$(getConfigValue "${absoluteConfigDir}" cron)
    local mailTo=$(getConfigValue "${absoluteConfigDir}" mail.to)

    local cronFile=$(getCronFileName "${absoluteConfigDir}")

    local cronIsEnabled=false
    if [[ -L "/etc/cron.d/${cronFile}" ]]; then
      local cronIsEnabled=true
    fi

    echo "Backup:         ${backupName}"
    echo "Cron schedule:  $cron"
    echo "Cron enabled:   $cronIsEnabled"
    echo "Mail result to: $mailTo"
    echo ""

  done

}
