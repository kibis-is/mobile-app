#!/usr/bin/env bash

SCRIPT_DIR=$(dirname "${0}")

source "${SCRIPT_DIR}/set_vars.sh"

# Public: Creates the Android signing keys necessary for signing a release.
#
# Required environment variables:
# * $ANDROID_KEY_ALIAS - The alias for the key.
# * $ANDROID_KEY_PASSWORD - The password for the key.
# * $ANDROID_KEYSTORE - The base64-encoded content of the keystore file.
# * $ANDROID_KEYSTORE_PASSWORD - The password for the keystore.
#
# Examples
#
#   ./scripts/create_android_signing_keys.sh
#
# Returns exit code 0 if successful.
function main {
  set_vars

  # decode the base64-encoded keystore and write it to a .jks file at the project root
  printf "%b decoding the base64-encoded key store to the keystore file... \n" "${INFO_PREFIX}"
  echo "${ANDROID_KEYSTORE}" | base64 -d > "upload_keystore.jks"

  # generate key.properties
  printf "%b creating key.properties file... \n" "${INFO_PREFIX}"
  {
    echo "keyAlias=${ANDROID_KEY_ALIAS}"
    echo "keyPassword=${ANDROID_KEY_PASSWORD}"
    echo "storeFile=${PWD}/upload_keystore.jks"
    echo "storePassword=${ANDROID_KEYSTORE_PASSWORD}"
  } > "android/key.properties"

  exit 0
}

# and so, it begins...
main
