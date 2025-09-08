#!/usr/bin/env bash

testRestore() {

  $(validateSystem >/dev/null)
  validateSystemExitCode=$?

  if [[ "${validateSystemExitCode}" -ne 0 ]]; then
    error "System does not meet infrabackup requirements, run infrabackup validate-system for more information."
    exit 1
  fi

  local backupName="${1}"

  if [[ -z "${backupName}" ]]; then
    error "No backup name provided"
    exit 1
  fi

  # Absolute path
  local absoluteConfigDir=$(getAbsoluteConfigDir "${backupName}")

  if [[ -z "${absoluteConfigDir}" ]]; then
    error "Couldnt find config directory with name '${backupName}'"
    exit 1
  fi

  local RESTORE_TIMESTAMP="${2}"

  if [[ -z "${RESTORE_TIMESTAMP}" ]]; then
    error "Please pass a restore timestamp in rdiff-backup format"
    exit 1
  fi

  local RESTORE_WHAT_FILE_OR_DIRECTORY="${3}"

  if [[ -z "${RESTORE_WHAT_FILE_OR_DIRECTORY}" ]]; then
    error "Please pass a file or directory to restore from the rdiff backup"
    exit 1
  fi

  # Optional verification flags after the first 3 args
  shift 3

  local VERIFY_CONTAINS=""
  local NO_CLEANUP=false

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --contains)
        if [[ -z "$2" ]]; then
          error "--contains requires a non-empty pattern argument"
          exit 1
        fi
        VERIFY_CONTAINS="$2"; shift 2 ;;
      --no-cleanup)
        NO_CLEANUP=true; shift ;;
      *)
        error "Unknown option: $1"
        info  "Supported: --contains <pattern> [--no-cleanup]"
        exit 1 ;;
    esac
  done

  # Create a temporary target directory to restore into
  local TARGET_DIRECTORY
  TARGET_DIRECTORY=$(mktemp -d -t infrabackup-restore-test-XXXXXXXX) || {
    error "Failed to create temporary directory for test restore"
    exit 1
  }

  # Ensure trailing slash so buildRdiffRestoreCommand composes a valid path
  if [[ ! "${TARGET_DIRECTORY}" =~ /$ ]]; then
    TARGET_DIRECTORY="${TARGET_DIRECTORY}/"
  fi

  info "Testing restore into temporary directory: ${TARGET_DIRECTORY}"

  local RDIFF_RESTORE_COMMAND
  RDIFF_RESTORE_COMMAND=$(buildRdiffRestoreCommand "${absoluteConfigDir}" "${RESTORE_TIMESTAMP}" "${RESTORE_WHAT_FILE_OR_DIRECTORY}" "${TARGET_DIRECTORY}")

  if [[ -z "${RDIFF_RESTORE_COMMAND}" ]]; then
    error "Failed building the rdiff restore command. Please check your config (infrabackup show) and validate your system (infrabackup validate-system)"
    exit $?
  fi

  info "Executing: ${RDIFF_RESTORE_COMMAND}"

  # Suppress rdiff-backup output during test-restore; keep only our status messages
  bash -c "${RDIFF_RESTORE_COMMAND}" >/dev/null 2>&1
  if [[ $? -ne 0 ]]; then
    error "Test restore command had an error"
    if [[ "${NO_CLEANUP}" = true ]]; then
      warn "--no-cleanup set; keeping temporary directory: ${TARGET_DIRECTORY}"
    else
      warn "Removing temporary directory: ${TARGET_DIRECTORY}"
      rm -rf -- "${TARGET_DIRECTORY}"
    fi
    return 1
  fi

  # Determine restored path
  local RESTORED_PATH="${TARGET_DIRECTORY}$(basename "${RESTORE_WHAT_FILE_OR_DIRECTORY}")"

  local ANY_VERIFY_FAILED=false

  # Content verification via grep if requested
  if [[ -n "${VERIFY_CONTAINS}" ]]; then
    info "Verifying restored contents contain pattern: ${VERIFY_CONTAINS}"

    if [[ -f "${RESTORED_PATH}" ]]; then
      if ! grep -a -n -F -- "${VERIFY_CONTAINS}" "${RESTORED_PATH}" >/dev/null 2>&1; then
        error "Pattern not found in restored file: ${RESTORED_PATH}"
        ANY_VERIFY_FAILED=true
      else
        success "Pattern found in restored file:"
        info " - ${RESTORED_PATH}"
      fi
    else
      # Directory: search recursively
      mapfile -t MATCHED_FILES < <(grep -a -R -l -F -- "${VERIFY_CONTAINS}" "${RESTORED_PATH}" 2>/dev/null)
      if [[ ${#MATCHED_FILES[@]} -eq 0 ]]; then
        error "Pattern not found in any restored files under: ${RESTORED_PATH}"
        ANY_VERIFY_FAILED=true
      else
        success "Pattern found in ${#MATCHED_FILES[@]} restored file(s):"
        for f in "${MATCHED_FILES[@]}"; do
          info " - ${f}"
        done
      fi
    fi
  fi

  # (Removed mtime verification logic)

  if [[ "${ANY_VERIFY_FAILED}" = true ]]; then
    if [[ "${NO_CLEANUP}" = true ]]; then
      warn "Verification failed; --no-cleanup set; keeping: ${RESTORED_PATH}"
    else
      warn "Verification failed; removing temporary directory: ${TARGET_DIRECTORY}"
      rm -rf -- "${TARGET_DIRECTORY}"
    fi
    return 1
  fi

  if [[ "${NO_CLEANUP}" = true ]]; then
    info "--no-cleanup set; keeping restored files at: ${RESTORED_PATH}"
  else
    info "Cleaning up temporary directory: ${TARGET_DIRECTORY}"
    rm -rf -- "${TARGET_DIRECTORY}"
  fi


  return 0
}
