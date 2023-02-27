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
    local mailTo=$(getConfigValue "${absoluteConfigDir}" "mail_to")

    local cron=$(getConfigValue "${absoluteConfigDir}" "cron")
    local cronFile=$(getCronFileName "${absoluteConfigDir}")
    local cronIsEnabled=false

    if [[ -L "/etc/cron.d/${cronFile}" ]]; then
      local cronIsEnabled="true, /etc/cron.d/${cronFile}"
    fi

    # Test if the system has MUTT
    mutt -h >/dev/null 2>&1
    HAS_MUTT=$?

    willSendEmails=false
    if [[ $HAS_MUTT -eq 0 ]]; then

      if [[ -z "${mailTo}" ]]; then
        willNotSendEmailReason=", mutt installed but CONFIG[mail_to] is empty or not set"
      else
        willNotSendEmailReason=", mutt installed and CONFIG[mail_to] set"
        willSendEmails=true
      fi

    else

      willNotSendEmailReason=", mutt not installed"
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

    echo
    echo "${backupName}"
    echo
    echo "Host:                 ${host}"
    echo "Cron schedule:        ${cron}"
    echo "Cron enabled:         ${cronIsEnabled}"
    echo
    echo "Will email:           ${willSendEmails}${willNotSendEmailReason}"
    echo "Mail receiver:        ${mailTo}"
    echo
    echo "Rsync target:         ${rsyncTarget}"
    echo "Rsync args:           ${rsyncArgs}"
    echo "Rsync include list:   ${includeList}"

    if [[ "${warnAboutIncludeList}" = "true" ]]; then
      warn "Rsync include list is empty!"
    fi

    echo "Rsync exclude list:   ${excludeList}"

    echo
    echo "Rdiff target:         ${rdiffTarget}"
    echo "Rdiff args:           ${rdiffArgs}"
    echo

  done

}
