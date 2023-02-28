#!/usr/bin/env bash
RESTORE='\033[0m'

RED='\033[00;31m'
GREEN='\033[00;32m'
YELLOW='\033[00;33m'
BLUE='\033[00;34m'
PURPLE='\033[00;35m'
CYAN='\033[00;36m'
LIGHTGRAY='\033[00;37m'

LRED='\033[01;31m'
LGREEN='\033[01;32m'
LYELLOW='\033[01;33m'
LBLUE='\033[01;34m'
LPURPLE='\033[01;35m'
LCYAN='\033[01;36m'
WHITE='\033[01;37m'

log() {

  if [[ -z "${LOGFILE}" ]]; then
    error "log function called but log file not set, please call setlogfile"
    exit 1
  fi

  MESSAGE="$(date +'%Y-%m-%d %H:%M:%S') - ${1}"

  # To log file
  echo -e "${MESSAGE}" | tee -a "${LOGFILE}"

}

msg() {
  echo -e "${1}"
}

info() {
  msg "${CYAN}$1${RESTORE}"
}

success() {
  msg "${GREEN}$1${RESTORE}"
}

warn() {
  msg "${YELLOW}$1${RESTORE}"
}

error() {
  msg "${RED}$1${RESTORE}"
}

logError() {
  log "ERROR: ${1}"
}

setlogfile() {

  absoluteConfigDir="${1}"
  suffix="${2}"

  LOG_DIRECTORY=$(getConfigValue $absoluteConfigDir "log_directory")

  if [[ -z "${LOG_DIRECTORY}" ]]; then
    error "Target log directory is empty, please check your config"
    exit 1
  fi

  # If we passed a suffix, add a dash infront for readability
  if [[ ! -z "${suffix}" ]]; then
    suffix="-${suffix}"
  fi

  # Random 5 character string
  runId=$(
    echo $RANDOM | md5sum | head -c 5
    echo
  )

  if [[ ! -d "${LOG_DIRECTORY}" ]]; then
    mkdir -p "${LOG_DIRECTORY}"
  fi

  LOGFILE="${LOG_DIRECTORY}$(date +%Y%m%d%H%M)${suffix}-${runId}.log"

  log "Logging to ${LOGFILE}"
}
