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

    info "######## ${backupName} ###########"
    msg "Cron schedule: $schedule"
    msg "Mail to: $mailTo"
    msg "Mail subject: $mailSubject"
    msg "Webhook before: $webhookBefore"
    msg "Webhook after: $webhookAfter"

  done

}
