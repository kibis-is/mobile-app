/**
 * Parses a semantic version release version to an object with the build number calculated based on the version and any
 * pre-release indexes.
 *
 * The build number is calculated using:
 *
 * build_number = ((major * 1,000,000) + (minor * 10,000) + (patch * 1000) + pre_release_index)
 *
 * where:
 * * major: the major version - <major>.X.X
 * * minor: the minor version - X.<minor>.X
 * * patch: the minor version - X.X.<patch>
 * * pre_release_index: is the optional pre-release number that may proceed the version - X.X.X-beta.<pre_release_index>
 *
 * @param {string} version - The semantic version for the release. E.g. 1.0.0, 1.0.2-beta.2, 2.0.3-alpha.5.
 * @returns {{buildNumber: number, version: string} | null} An object containing the build number and the base semantic
 * version. If no version is supplied or the version is invalid, null is returned.
 */
function parseVersion(version) {
  let _version;
  let match;
  let preReleaseIndex;

  if (!version) {
    console.log('no version specified');

    return null;
  }

  match = version.match(new RegExp(/^([0-9]+\.[0-9]+\.[0-9]+)(?:-([a-zA-Z]+)\.(\d+))?$/));

  // check the input is in semantic version format
  if (!match) {
    console.log(`invalid semantic version, got "${version}", but should be in the format "1.0.0"`);

    return null;
  }

  _version = match[1];
  preReleaseIndex = match[3] ? parseInt(match[3], 10) : 0;

  const [major, minor, patch] = _version.split('.');

  return {
    buildNumber: (parseInt(major, 10) * 10000000) + (parseInt(minor, 10) * 10000) + (parseInt(patch, 10) * 1000) + preReleaseIndex,
    version: _version,
  };
}

export default parseVersion;
