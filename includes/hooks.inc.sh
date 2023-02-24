#!/usr/bin/env bash

runHooks() {

  absoluteConfigDir=$(getAbsoluteConfigDir "${1}")
  hookType="${2}"
  HAS_ERROR=false

  for FILE in "${absoluteConfigDir}hooks/${hookType}/*"; do

    # Skip directories
    if [[ -d $FILE ]]; then
      continue
    fi

    # Test if the file is executable
    if [ ! -x $FILE ]; then
      continue
    fi

    bash $FILE || HAS_ERROR=true

    if [ "${HAS_ERROR}" = true ]; then
      return 1
    fi

  done

  return 0
}
