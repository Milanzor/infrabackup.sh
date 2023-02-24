#!/usr/bin/env bash

show() {

  # Loop through all config directories
  for configDir in "${INFRABACKUP_INSTALLATION_DIRECTORY}/configs/*"; do

    local configId=$(basename $configDir)
    local schedule=$(getConfigValue $configDir/config.json schedule)
    local mailTo=$(getConfigValue $configDir/config.json mail.to)
    local mailSubject=$(getConfigValue $configDir/config.json mail.subject)
    local webhookBefore=$(getConfigValue $configDir/config.json webhook.before)
    local webhookAfter=$(getConfigValue $configDir/config.json webhook.after)

    info "######## $configId ###########"
    msg "Cron schedule: $schedule"
    msg "Mail to: $mailTo"
    msg "Mail subject: $mailSubject"
    msg "Webhook before: $webhookBefore"
    msg "Webhook after: $webhookAfter"

  done

}
