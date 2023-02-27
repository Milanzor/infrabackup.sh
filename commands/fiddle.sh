#!/usr/bin/env bash

fiddle() {

  if [[ $(systemHasRdiffBackupInstalled) = "false" ]]; then
    echo Installed
  else
    echo Not installed
  fi

}
