#!/usr/bin/env bash

runHooks() {

  absoluteConfigDir=$(getAbsoluteConfigDir "${1}")
  hookType="${2}"

  returnValue=0

  find "${absoluteConfigDir}hooks/${hookType}/" -maxdepth 1 -mindepth 1 -type f | while read FILE; do

    if [[ "${returnValue}" = 1 ]]; then
      continue
    fi

    # Test if the file is executable
    if [ ! -x "${FILE}" ]; then
      continue
    fi

    bash "${FILE}"
    exitCode=$?
    if [[ "${exitCode}" -ne 0 ]]; then
      abort "Non-zero (${exitCode}) exit code received from ${hookType} hook: ${FILE}"
      returnValue=1
    fi

  done

  return $returnValue
}
