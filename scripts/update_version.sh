#!/usr/bin/env bash

SCRIPT_DIR=$(dirname "${0}")

source "${SCRIPT_DIR}/set_vars.sh"

# Public: Updates the pubspec.yaml "version" with the release version.
#
# $1 - The version to bump.
#
# Examples
#
#   ./scripts/update_version.sh "1.0.0"
#   ./scripts/update_version.sh "1.2.0-beta.3"
#
# Returns exit code 0 if successful, or 1 if the semantic version is incorrectly formatted.
function main {
  local build

  set_vars

  if [ -z "${1}" ]; then
    printf "%b no version specified, use: ./scripts/update_version.sh [version] \n" "${ERROR_PREFIX}"
    exit 1
  fi

  # check the input is in semantic version format
  if [[ ! "${1}" =~ ^[0-9]+\.[0-9]+\.[0-9]+ ]]; then
    printf "%b invalid semantic version, got '${1}', but should be in the format '1.0.0' \n" "${ERROR_PREFIX}"
    exit 1
  fi

  # get the version without the pre-release
  version=${1%-*}

  # if the input is a pre-release release, *-beta.xx is suffixed to the end of the semantic version
  # and we want to use this as a build number
  if [[ "${1}" =~ ^[0-9]+\.[0-9]+\.[0-9]-beta+ ]]; then
    printf "%b pre-release version found \n" "${INFO_PREFIX}"
    build="${1#*-beta.}"
  fi

  # if there is a build number, add it to the version
  if [[ -n "${build}" ]]; then
    version="${version}+${build}"
  fi

  printf "%b setting version '%s' to pubspec.yaml \n" "${INFO_PREFIX}" "${version}"
  yq e ".version = \"${version}\"" -i  "${PWD}/pubspec.yaml"

  exit 0
}

# and so, it begins...
main "$@"
