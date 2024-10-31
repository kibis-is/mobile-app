import { existsSync, readFileSync, writeFileSync } from 'node:fs';
import { resolve } from 'node:path';

// utils
import parseVersion from './parse-version.mjs';

/**
 * Updates the pubspec.yaml "version" property with the supplied semantic version.
 * @param {string} version - The semantic version for the release. E.g. 1.0.0, 1.0.2-beta.2, 2.0.3-alpha.5.
 */
function main(version) {
  const _version = parseVersion(version);
  let pubspecFileContents;
  let pubspecFilePath

  if (!_version) {
    console.error('failed to update version');

    process.exit(1);
  }

  pubspecFilePath = resolve(process.cwd(), 'pubspec.yaml');

  if (!existsSync(pubspecFilePath)) {
    console.error(`pubspec.yaml does not exist at: "${pubspecFilePath}"`);

    process.exit(1);
  }

  // get the pubspec file and replace the version and build number
  pubspecFileContents = readFileSync(pubspecFilePath, 'utf8');
  pubspecFileContents = pubspecFileContents.replace(/version:\s*[\d.]+\+\d+/g, `version: ${_version.version}+${_version.buildNumber}`);

  writeFileSync(pubspecFilePath, pubspecFileContents, 'utf8');

  console.info(`updated pubspec.yaml with new version: "${_version.version}+${_version.buildNumber}"`);

  process.exit(0);
}

main(process.argv[2]);
