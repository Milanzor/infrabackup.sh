#!/usr/bin/env bash

buildRdiffCommand() {

  local RDIFF_ARGS=$1
  local SOURCE_DIRECTORY=$2
  local TARGET_DIRECTORY=$3

  echo "rdiff-backup ${RDIFF_ARGS} ${SOURCE_DIRECTORY} ${TARGET_DIRECTORY}"
}
