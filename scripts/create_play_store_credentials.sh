#!/usr/bin/env bash

SCRIPT_DIR=$(dirname "${0}")

source "${SCRIPT_DIR}/set_vars.sh"

# Public: Creates a JSON to contain the Play Store credentials.
#
# Required environment variables:
# * $GOOGLE_CLOUD_SERVICE_ACCOUNT_KEY - A Google Cloud service account key in JSON format.
#
# Examples
#
#   ./scripts/create_play_store_credentials.sh
#
# Returns exit code 1 if the GOOGLE_CLOUD_SERVICE_ACCOUNT_KEY en var is not set or empty or 0 if successful.
function main {
  set_vars

  if [ -z "${GOOGLE_CLOUD_SERVICE_ACCOUNT_KEY+x}" ]; then
    printf "%b env var \"GOOGLE_CLOUD_SERVICE_ACCOUNT_KEY\" not set, or empty \n" "${ERROR_PREFIX}"
    exit 1
  fi

  printf "%b creating play_store_credentials.json... \n" "${INFO_PREFIX}"
  echo "${GOOGLE_CLOUD_SERVICE_ACCOUNT_KEY}" > "play_store_credentials.json"

  exit 0
}

# and so, it begins...
main
