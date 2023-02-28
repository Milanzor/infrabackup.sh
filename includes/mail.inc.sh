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
