#!/usr/bin/env bash

runHooks() {

  absoluteConfigDir=$(getAbsoluteConfigDir "${1}")
  hookType="${2}"

  local returnValue=0

  if [[ ! -d "${absoluteConfigDir}hooks/${hookType}/" ]]; then
    log "Skipping hook ${hookType}, no hooks found"
    return $returnValue
  fi

  hookFiles=$(find "${absoluteConfigDir}hooks/${hookType}/" -maxdepth 1 -mindepth 1 -type f)

  while read FILE; do

    if [[ "${returnValue}" = 1 ]]; then
      continue
    fi

    # Test if the file is executable
    if [ ! -x "${FILE}" ]; then
      continue
    fi

    log "Running ${hookType} hook $(basename ${FILE})"

    # Execute the file
    "${FILE}" "${HAS_ANY_ERROR}" | tee -a "${LOGFILE}"

    exitCode=${PIPESTATUS[0]}

    if [[ "${exitCode}" -ne 0 ]]; then
      logError "Non-zero (${exitCode}) exit code received from ${hookType} hook: ${FILE}"
      returnValue=1
    fi

  done < <(echo -e "${hookFiles}")

  return $returnValue
}
