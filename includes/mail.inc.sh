#!/usr/bin/env bash

systemCanSendEmails() {

  mutt -h >/dev/null 2>&1
  HAS_MUTT=$?

  if [[ $HAS_MUTT -ne 0 ]]; then
    echo "false"
    exit 1
  fi

  echo "true"
  exit 0

}

buildEmail() {

  HAS_ANY_ERROR="${1}"
  backupName="${2}"

  if [[ "$HAS_ANY_ERROR" == true ]]; then
    local text="Infrabackup '${backupName}' finished with errors, please refer to the attached log file."
    local emoji="❌"
  else
    local text="Infrabackup '${backupName}' finished successfully, nothing to see here!"
    local emoji="✅"
  fi

  date=$(date)

  mailContents=$(cat "${INFRABACKUP_INSTALLATION_DIRECTORY}/assets/email.template.html")

  # Replace some tags
  mailContents=$(echo "${mailContents}" | sed "s|{{__DATE__}}|$(date)|g")
  mailContents=$(echo "${mailContents}" | sed "s|{{__TEXT__}}|${text}|g")
  mailContents=$(echo "${mailContents}" | sed "s|{{__RESULT_ICON__}}|${emoji}|g")

  echo "${mailContents}"

}
