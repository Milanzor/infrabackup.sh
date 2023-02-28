#!/usr/bin/env bash

validateSystem() {

  EXIT_CODE=0
  if [[ $(systemHasRdiffBackupInstalled) = "true" ]]; then
    success "rdiff-backup:\tInstalled"
  else
    error "rdiff-backup:\tNot installed"
    EXIT_CODE=1
  fi

  if [[ $(systemHasRsyncInstalled) = "true" ]]; then
    success "rsync\t\tInstalled"
  else
    error "rsync\t\tNot installed"
    EXIT_CODE=1
  fi

  mutt -h >/dev/null 2>&1
  HAS_MUTT=$?

  if [[ "${HAS_MUTT}" -eq 0 ]]; then
    success "mutt:\t\tInstalled"
  else
    warn "mutt:\t\tNot installed, will skip sending backup result email"
  fi

  if [[ "${EXIT_CODE}" = "0" ]]; then
    success "Result:\t\tAll systems check, ready for backups"
  else
    error "Result:\t\tOne or more checks failed, please install the required commands"
  fi

  exit $EXIT_CODE

}
