#!/usr/bin/env bash

SCRIPT_DIR=$(dirname "${0}")

source "${SCRIPT_DIR}/set_vars.sh"

# Public: Gets the key signing secrets and creates the keystore and key.properties files that are
# used in signing.
#
# Examples
#
#   ./scripts/post_install.sh
#
# Returns exit code 0 if successful.
function main {
  local encoded_keystore
  local key_alias
  local key_password
  local keystore_password

  set_vars

  printf "%b fetching secrets from doppler... \n" "${INFO_PREFIX}"
  encoded_keystore=$(doppler secrets get "KEYSTORE" --plain)
  key_alias=$(doppler secrets get "KEY_ALIAS" --plain)
  key_password=$(doppler secrets get "KEY_PASSWORD" --plain)
  keystore_password=$(doppler secrets get "KEYSTORE_PASSWORD" --plain)

  # decode the base64-encoded keystore and write it to a .jks file at the project root
  printf "%b decoding the base64-encoded key store to the keystore file... \n" "${INFO_PREFIX}"
  echo "${encoded_keystore}" | base64 -d > "key.jks"

  # generate key.properties
  printf "%b creating key.properties file... \n" "${INFO_PREFIX}"
  {
    echo "keyAlias=${key_alias}"
    echo "keyPassword=${key_password}"
    echo "storeFile=${PWD}/key.jks"
    echo "storePassword=${keystore_password}"
  } > "android/key.properties"

  exit 0
}

# and so, it begins...
main
