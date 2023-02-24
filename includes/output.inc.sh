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

msg() {
  echo -e "$(date +'%Y-%m-%d %H:%M') - ${1}"
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

setlogfile() {
  LOGFILE="${INFRABACKUP_INSTALLATION_DIRECTORY}/configs/${1}/$(date +%Y%m%d%H%M).log"
  exec > >(tee -i ${LOGFILE})
  exec 2>&1
}
