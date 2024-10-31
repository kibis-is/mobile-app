import { existsSync, mkdirSync, writeFileSync } from 'node:fs';
import { resolve } from 'node:path';

// utils
import convertMarkdownToPlainText from './convert-markdown-to-plain-text.mjs';
import parseVersion from './parse-version.mjs';

/**
 * Creates a Fastlane metadata change-log file based on the release. It will parse the version to get the build number,
 * convert the notes from markdown to plain text and create a file at: `android/fastlane/metadata/en-GB/changelogs/<build_number>.txt`
 *
 * **Example:**
 * ```
 * // using semantic-release
 * node create-store-release-notes.mjs ${nextRelease.version} ${nextRelease.notes}
 * ```
 * @param {string} version - The semantic version for the release. E.g. `1.0.0`, `1.0.2-beta.2`, `2.0.3-alpha.5`.
 * @param {string} notes - The markdown release notes passed from `@semantic-release/release-notes-generator`.
 */
function main(version, notes) {
  const _version = parseVersion(version);
  let changeLogsDirPath;
  let releaseNotes;

  if (!_version) {
    console.error('failed to parse version');

    process.exit(1);
  }

  releaseNotes = convertMarkdownToPlainText(notes);

  if (!releaseNotes) {
    console.error('failed to convert the release notes to plain text');

    process.exit(1);
  }

  changeLogsDirPath = resolve(process.cwd(), 'android', 'fastlane', 'metadata', 'en-GB', 'changelogs');

  if (!existsSync(changeLogsDirPath)) {
    console.log(`"${changeLogsDirPath}" does not exist, creating...`);

    try {
      mkdirSync(changeLogsDirPath, { recursive: true });
    } catch (error) {
      console.error(`failed to create "${changeLogsDirPath}":`, error);

      process.exit(1);
    }
  }

  writeFileSync(resolve(changeLogsDirPath, `${_version.buildNumber}.txt`), releaseNotes, 'utf8');

  console.log(`created new release notes at "${resolve(changeLogsDirPath, `${_version.buildNumber}.txt`)}"`);

  process.exit(0);
}

main(process.argv[2], process.argv[3]);
