#!/usr/bin/env bash

uninstall() {

  # Wasnt installed?
  if [[ ! -L "/usr/local/bin/infrabackup" ]]; then
    msg "infrabackup was not symlinked to /usr/local/bin/infrabackup, no need to uninstall"
    exit 0
  fi

  rm "/usr/local/bin/infrabackup"

  # Sucessfully removed?
  if [[ $? -eq 0 ]]; then
    success "Succesfully removed symlinked infraback at /usr/local/bin/infrabackup"
    exit 0
  fi

  # rm failed
  error "Failed to uninstall symlinked infraback at /usr/local/bin/infrabackup"
  exit 1
}
