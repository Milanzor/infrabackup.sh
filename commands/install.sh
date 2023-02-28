#!/usr/bin/env bash

install() {

  # Already installed?
  if [[ -L "/usr/local/bin/infrabackup" ]]; then
    success "Infrabackup already symlinked to /usr/local/bin/infrabackup"
    exit 0
  fi

  # Create symlink
  ln -s "${INFRABACKUP_INSTALLATION_DIRECTORY}/infrabackup" "/usr/local/bin/infrabackup"

  # Check if symlinking worked
  if [[ $? -eq 0 ]]; then
    success "Succesfully symlinked infrabackup to /usr/local/bin/infrabackup"
    exit 0
  fi

  # Symlinking failed
  error "Failed to symlinked infrabackup to /usr/local/bin/infrabackup"
  exit 1
}
