#!/usr/bin/env bash

show() {

  find "${INFRABACKUP_INSTALLATION_DIRECTORY}/configs/" -maxdepth 1 -mindepth 1 -type d | while read dir; do

    local backupName=$(basename "${dir}")
    local absoluteConfigDir=$(getAbsoluteConfigDir "${backupName}")

    local host=$(getConfigValue "${absoluteConfigDir}" "host")

    if [[ -z "${host}" ]]; then
      local host="No host set, backup is for current system"
    fi

    local rsyncTarget=$(getConfigValue "${absoluteConfigDir}" "rsync_target")
    local rsyncArgs=$(getConfigValue "${absoluteConfigDir}" "rsync_args")
    local rdiffTarget=$(getConfigValue "${absoluteConfigDir}" "rdiff_target")
    local rdiffArgs=$(getConfigValue "${absoluteConfigDir}" "rdiff_args")
    local rdiffRemoveOlderThan=$(getConfigValue "${absoluteConfigDir}" "rdiff_remove_older_than")
    local rdiff_purge_cron=$(getConfigValue "${absoluteConfigDir}" "rdiff_purge_cron")

    local mailTo=$(getConfigValue "${absoluteConfigDir}" "mail_to")

    local cron=$(getConfigValue "${absoluteConfigDir}" "cron")
    local cronFile=$(getCronFileName "${absoluteConfigDir}")
    local cronIsEnabled=$(warn "No")

    if [[ -L "/etc/cron.d/${cronFile}" ]]; then
      local cronIsEnabled=$(success "Yes, /etc/cron.d/${cronFile} $(warn "(contents not verified)")")
    fi

    willSendEmails=$(warn "Yes")
    if [[ $(systemCanSendEmails) = "true" ]]; then

      if [[ -z "${mailTo}" ]]; then
        willSendEmails=$(warn "No, system can send emails but CONFIG[mail_to] is empty or not set")
      else
        willSendEmails=$(success "Yes, system can send emails and CONFIG[mail_to] set")
      fi

    else
      willSendEmails=$(warn "No, system cannot send emails (see infrabackup validate-system for more information")
    fi

    excludeList=
    warnAboutIncludeList=false

    if [[ -f "${absoluteConfigDir}include.list" ]]; then

      if [[ -z $(cat "${absoluteConfigDir}include.list") ]]; then
        includeList=$(error "${absoluteConfigDir}include.list is empty! Rsync will sync the whole server!")

      else
        includeList="${absoluteConfigDir}include.list"
      fi

    else
      includeList=$(error "${absoluteConfigDir}include.list does not exist. Rsync will sync the whole server!")
    fi

    if [[ -f "${absoluteConfigDir}exclude.list" ]]; then
      excludeList="${absoluteConfigDir}exclude.list"
    fi

    LOG_DIRECTORY=$(getConfigValue $absoluteConfigDir "log_directory")
    LAST_BACKUP_LOG=$(find "${LOG_DIRECTORY}" -type f -iname "*-backup*" | sort -n | tail -1)
    LAST_PURGE_LOG=$(find "${LOG_DIRECTORY}" -type f -iname "*-purge*" | sort -n | tail -1)

    echo
    echo "${backupName}"
    echo
    echo "Host:                     $(warn "${host}")"
    echo
    echo "Rsync target:             ${rsyncTarget}"
    echo "Rsync args:               ${rsyncArgs}"
    echo "Rsync include list:       ${includeList}"

    if [[ "${warnAboutIncludeList}" = "true" ]]; then
      warn "Rsync include list is empty!"
    fi

    echo "Rsync exclude list:       ${excludeList}"

    echo
    echo "Rdiff target:             ${rdiffTarget}"
    echo "Rdiff purge older than:   $(info "${rdiffRemoveOlderThan}")"
    echo "Rdiff args:               ${rdiffArgs}"
    echo
    echo "Cron schedule (backup):   $(info "${cron}")"
    echo "Cron schedule (purge):    $(info "${rdiff_purge_cron}")"
    echo "Cron enabled:             ${cronIsEnabled}"
    echo
    echo "Will email:               ${willSendEmails}${willNotSendEmailReason}"
    echo "Mail receiver:            ${mailTo}"

    echo
    echo "Log directory:            ${LOG_DIRECTORY}"
    echo "Latest backup log:        ${LAST_BACKUP_LOG}"
    echo "Latest purge log:         ${LAST_PURGE_LOG}"

  done

}
