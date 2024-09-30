#!/usr/bin/env bash

SCRIPT_DIR=$(dirname "${0}")

source "${SCRIPT_DIR}/set_vars.sh"

# Public: Updates the pubspec.yaml "version" with the release's semantic version.
#
# The build number is calculated using:
#
# build_number = ((major * 1,000,000) + (minor * 10,000) + (patch * 1000) + pre_release_index)
#
# where:
#   * major: the major version - <major>.X.X
#   * minor: the minor version - X.<minor>.X
#   * patch: the minor version - X.X.<patch>
#   * pre_release_index: is the optional pre-release number that may proceed the version - X.X.X-beta.<pre_release_index>
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
  local build_number=1
  local major=0
  local minor=0
  local patch=0
  local pre_release_index=0
  local version

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

  # split into separate semantic versions
  IFS='.' read -r major minor patch <<< "${version}"

  # convert to integers
  major=${major:-0}
  minor=${minor:-0}
  patch=${patch:-0}

  # if the input is a pre-release release, *-beta.xx is suffixed to the end of the semantic version
  # and we want to use this as a pre-release index
  if [[ "${1}" =~ ^[0-9]+\.[0-9]+\.[0-9]-beta+ ]]; then
    printf "%b pre-release version found \n" "${INFO_PREFIX}"
    pre_release_index="${1#*-beta.}"
    pre_release_index=${pre_release_index:-0}
  fi

  # calculate the build number and add to the flutter version
  build_number=$(( major * 10000000 + minor * 10000 + patch * 1000 + pre_release_index ))
  version="${version}+${build_number}"

  printf "%b setting version '%s' to pubspec.yaml \n" "${INFO_PREFIX}" "${version}"
  yq e ".version = \"${version}\"" -i  "${PWD}/pubspec.yaml"

  exit 0
}

# and so, it begins...
main "$@"
