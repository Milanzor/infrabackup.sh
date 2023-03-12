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

  backupName="${1}"
  task="${2}"
  HAS_ANY_ERROR="${3}"


  if [[ "$HAS_ANY_ERROR" == true ]]; then
    local text="${task} for '${backupName}' finished with errors, please refer to the attached log file."
    local emoji="❌"
  else
    local text="${task} for '${backupName}' finished successfully, nothing to see here!"
    local emoji="✅"
  fi

  date=$(date)
  logo_base64=$(base64 -w 0 "${INFRABACKUP_INSTALLATION_DIRECTORY}/assets/logo.png")

  mailContents=$(cat "${INFRABACKUP_INSTALLATION_DIRECTORY}/assets/email.template.html")

  # Replace some tags
  mailContents=$(echo "${mailContents}" | sed "s|{{__DATE__}}|$(date)|g")
  mailContents=$(echo "${mailContents}" | sed "s|{{__TEXT__}}|${text}|g")
  mailContents=$(echo "${mailContents}" | sed "s|{{__RESULT_ICON__}}|${emoji}|g")
  mailContents=$(echo "${mailContents}" | sed "s|{{__LOGO_BASE64__}}|${logo_base64}|g")

  echo "${mailContents}"

}

buildSubject() {

  backupName="${1}"
  task="${2}"
  HAS_ANY_ERROR="${3}"

  if [[ "$HAS_ANY_ERROR" == true ]]; then
    local MAIL_SUBJECT="${task} for '${backupName}' finished with errors"
  else
    local MAIL_SUBJECT="${task} for '${backupName}' finished successfully"
  fi

  echo "${MAIL_SUBJECT}"
}
