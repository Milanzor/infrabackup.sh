#!/usr/bin/env bash

show() {

  find "${INFRABACKUP_INSTALLATION_DIRECTORY}/configs/" -maxdepth 1 -mindepth 1 -type d | while read dir; do

    local backupName=$(basename "${dir}")
    local absoluteConfigDir=$(getAbsoluteConfigDir "${backupName}")
    
    local schedule=$(getConfigValue "${absoluteConfigDir}" schedule)
    local mailTo=$(getConfigValue "${absoluteConfigDir}" mail.to)
    local mailSubject=$(getConfigValue "${absoluteConfigDir}" mail.subject)
    local webhookBefore=$(getConfigValue "${absoluteConfigDir}" webhook.before)
    local webhookAfter=$(getConfigValue "${absoluteConfigDir}" webhook.after)

    echo "Backup:         ${backupName}"
    echo "Cron schedule:  $schedule"
    echo "Mail to:        $mailTo"
    echo "Mail subject:   $mailSubject"
    echo "Webhook before: $webhookBefore"
    echo "Webhook after:  $webhookAfter"
    echo ""

  done

}
