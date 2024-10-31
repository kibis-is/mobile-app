<p align="center">
  <a href="https://kibis.is">
    <img alt="Kibisis & Flutter logo" src=".github/assets/logo@191x64.png" style="padding-top: 15px" height="64" />
  </a>
</p>

<h1 align="center">
  Kibisis Mobile App
</h1>

<h4 align="center">
  A wallet for your lifestyle.
</h4>

<p align="center">
  <a href="https://github.com/kibis-is/mobile-app/releases/latest">
    <img alt="GitHub Release" src="https://img.shields.io/github/v/release/kibis-is/mobile-app?&logo=github">
  </a>
  <a href="https://github.com/kibis-is/mobile-app/releases/latest">
    <img alt="GitHub Release Date - Published At" src="https://img.shields.io/github/release-date/kibis-is/mobile-app?logo=github">
  </a>
</p>

<p align="center">
  <a href="https://github.com/kibis-is/mobile-app/releases">
    <img alt="GitHub Pre-release" src="https://img.shields.io/github/v/release/kibis-is/mobile-app?include_prereleases&label=pre-release&logo=github">
  </a>
  <a href="https://github.com/kibis-is/mobile-app/releases">
    <img alt="GitHub Pre-release Date - Published At" src="https://img.shields.io/github/release-date-pre/kibis-is/mobile-app?label=pre-release date&logo=github">
  </a>
</p>

<p align="center">
  <a href="https://github.com/kibis-is/mobile-app/blob/main/LICENSE">
    <img alt="GitHub License" src="https://img.shields.io/github/license/kibis-is/mobile-app">
  </a>
</p>

<p align="center">
  This is the Kibisis mobile app built in Flutter.
</p>

### Table Of Contents

* [1. Overview](#-1-overview)
* [2. Usage](#-2-usage)
* [3. Development](#-3-development)
  - [3.1. Requirements](#31-requirements)
  - [3.2. Install Dependencies](#32-install-dependencies)
  - [3.3. Run](#33-run)
  - [3.4. Launcher Icons](#34-launcher-icons)
* [4. Building](#-4-building)
  - [4.1. Requirements](#41-requirements)
  - [4.2. Create A Personal Doppler Config](#42-create-a-personal-doppler-config)
  - [4.3. Setup `doppler`](#43-setup-doppler)
  - [4.4. Build](#44-build)
    - [4.4.1. Android](#441-android)
    - [4.4.2. iOS](#442-ios)
* [5. Publishing](#-5-publishing)
    - [5.1. Overview](#51-overview)
    - [5.2. Requirements](#52-requirements)
    - [5.3. Setup Doppler](#53-setup-doppler)
    - [5.4. Publish Via Fastlane](#54-publish-via-fastlane)
      - [5.4.1. Android](#541-android)
      - [5.4.2. iOS](#542-ios)
* [6. Appendix](#-6-appendix)
  - [6.1. Useful Commands](#61-useful-commands)
  - [6.2.Create An Upload Keystore](#62-create-an-upload-keystore)
* [7. How To Contribute](#-7-how-to-contribute)
* [8. License](#-8-license)

## 🗂️ 1. Overview

Coming soon...

## 🪄 2. Usage

Refer to the [documentation](https://kibis.is/overview) for information on how to use Kibisis.

<sup>[Back to top ^][table-of-contents]</sup>

## 🛠 3. Development

### 3.1. Requirements

* [Flutter SDK v3.22.3][flutter]

<sup>[Back to top ^][table-of-contents]</sup>

### 3.2. Install Dependencies

1. Simply run:
```bash
$ flutter pub get
```

> ⚠️ **NOTE:** This will install the required dependencies and generate the development keys that can be used for signing the development version of the app.

<sup>[Back to top ^][table-of-contents]</sup>

### 3.3. Run

* To run simply use:
```bash
$ flutter run
```

<sup>[Back to top ^][table-of-contents]</sup>

### 3.4. Launcher Icons

The icons are configured using the [`flutter_launcher_icons`](https://pub.dev/packages/flutter_launcher_icons) package. The configuration sits in the `pubspec.yaml` file.

Tl;dr, you can create new icons by running the command:
```shell
dart run flutter_launcher_icons
```

> **NOTE:** This will create the icons for all platforms except Android, see below for details on Android.

<sup>[Back to top ^][table-of-contents]</sup>

##### Android

The Android launcher icons are created using Android Studio's Image Asset Studio. You can follow [this](https://developer.android.com/studio/write/create-app-icons#access) on how to create adaptive icons.

> **NOTE:** If you are running Android Studio from the root, you will need to reopen Android Studio from the `andriod/` directory in order to access the "Andorid View".

For more information regarding Adaptive Icons, see [here](https://developer.android.com/develop/ui/views/launch/icon_design_adaptive).

<sup>[Back to top ^][table-of-contents]</sup>

## 📦 4. Building

### 4.1. Requirements

* [Doppler CLI][doppler]
* [Flutter SDK v3.22.3][flutter]

<sup>[Back to top ^][table-of-contents]</sup>

### 4.2. Create A Personal Doppler Config

To start using your own Doppler config, go to the project on [Doppler](https://dashboard.doppler.com/workplace/ae8c01548486ba93b8fd/projects/mobile-app) and press the "+" to create a new personal branch config in the "Development" config

<p align="center">
  <img alt="Screen grab of the Doppler dashboard when creating a branch config" src=".github/assets/create_doppler_config.png" style="padding-top: 15px" height="512" />
</p>

> ⚠️ **NOTE:** Use your name in lowercase with underscores instead of spaces (snake_case).

<sup>[Back to top ^][table-of-contents]</sup>

### 4.3. Setup `doppler`

Follow the instructions [here](https://docs.doppler.com/docs/install-cli#local-development) to:

* login to Doppler, and;
* setup Doppler to use the `mobile-app` project with your personal config.

> ⚠️ **NOTE:** When naming your token, it is recommended you use: "<your_name>-<device_name>".

<sup>[Back to top ^][table-of-contents]</sup>

### 4.4. Build

#### 4.4.1. Android

1. Create the signing keys with a wrapped Doppler command:
```shell
doppler run -- ./scripts/create_android_signing_keys.sh
```

> ⚠️ **NOTE:** The wrapped Doppler command will fetch the secrets for the active config and inject them into the command shell.

2. Build a release:
```shell
flutter build <apk|aab> --release
```

3. The APK or AAB will use the signing keys from step 2 and add the file.
   i. APK builds will be in: `build/app/outputs/apk/release/app-release.apk`
   ii. AAB builds will be in: `build/app/outputs/bundle/release/app-release.aab`

> 🚨 **WARNING:** The `dev` Doppler configs contain "dummy" upload signing keys and CANNOT be used to upload to the Play Store.

<sup>[Back to top ^][table-of-contents]</sup>

#### 4.4.2. iOS

Coming soon...

<sup>[Back to top ^][table-of-contents]</sup>

## 🚀 5. Publishing

### 5.1. Overview

Publishing is automated by the CD, but it is possible to publish locally using the keys stored on [Doppler](https://www.doppler.com/) and [Fastlane][fastlane].

<sup>[Back to top ^][table-of-contents]</sup>

### 5.2. Requirements

* [Doppler CLI][doppler]
* [Bundler (via `gem`)][bundler]
* [Fastlane (via `gem`)][fastlane]
* [Ruby][ruby]

<sup>[Back to top ^][table-of-contents]</sup>

### 5.3. Setup Doppler

Repeat the steps in [4.2. Create A Personal Doppler Config](#42-create-a-personal-doppler-config) and [4.3. Setup `doppler`](#43-setup-doppler) to setup Doppler.

<sup>[Back to top ^][table-of-contents]</sup>

### 5.3. Install Bundler Dependencies

[Fastlane][fastlane] is installed and executed via [Bundler][bundler]. This repo contains a `Gemfile` to handle the Fastlane dependencies needed, so, with Bundler installed, you can simply run:
```shell
bundle install
```

<sup>[Back to top ^][table-of-contents]</sup>

### 5.4. Publish Via Fastlane

#### 5.4.1 Android

1. Assuming Doppler setup has been setup, you will need fetch the production upload signing keys. This can be done using the command:
```shell
doppler run --config=prd -- ./scripts/create_android_signing_keys.sh
```

> ⚠️ **NOTE:** This is the same command as [4.4.1. Android](#441-android), but the config has been set to the "production".

2. Build a new version of the app:
```shell
flutter build aab --release
```

3. Get the Google Cloud Service credentials that will allow you to upload an app bundle to the Play Store by using the following command:
```shell
./scripts/create_play_store_credentials.sh
```

> ⚠️ **NOTE:** The following script will require the `$GOOGLE_CLOUD_SERVICE_ACCOUNT_KEY` to be set with the credentials.

4. Use Fastlane to upload the release to the Google Play Store using the follwing commands:
```shell
cd ./android
bundle exec fastlane <lane>
```

> ⚠️ **NOTE:** The `lane` can either be `beta` or `production`. With `beta` uploading to the Internal Testing track and `production` uploading to the live version of the app.

<sup>[Back to top ^][table-of-contents]</sup>

#### 5.4.2 iOS

Coming soon...

<sup>[Back to top ^][table-of-contents]</sup>

## 📑 6. Appendix

### 6.1. Useful Commands

| Command                              | Description                                                                                                                                                                                               |
|--------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `flutter pub add <package_name>`     | Installs a new package and saves it to the `pubspec.yaml` file.                                                                                                                                           |
| `flutter run`                        | Runs the app locally.                                                                                                                                                                                     |
| `flutter build <apk\|aab> --release` | Builds an Android APK/AAB to `build/app/outputs/bundle/release/app-release.<apk\|aab>`. NOTE: You will need a signing key, this can be acquired by following the steps in [4.4.1. Android](#441-android). |
| `bundle exec fastlane <lane>`        | Uploads a mobile artifact to the Play Store/AppStore based on the lane, where `lane` is either `beta` or `production`.                                                                                    |
| `dart run flutter_launcher_icons`    | Creates the launcher and store icons for all the apps (Android is excluded.).                                                                                                                             |

See the [Flutter CLI](https://docs.flutter.dev/reference/flutter-cli#flutter-commands) reference for a full list of available commands.

<sup>[Back to top ^][table-of-contents]</sup>

### 6.2. Create An Upload Keystore

The command below can be used to generate a keystore used for app signing:

```shell
keytool -genkeypair \
  -v \
  -validity 10000 \
  -keystore upload_keystore.jks \
  -keyalg RSA \
  -keysize 2048 \
  -keypass <key_password> \
  -alias <key_alias> \
  -storepass <keystore_password> \
  -storetype JKS
```

<sup>[Back to top ^][table-of-contents]</sup>

## 👏 7. How To Contribute

Please read the [**Contributing Guide**][contribute] to learn about the development process.

<sup>[Back to top ^][table-of-contents]</sup>

## 📄 8. License

Please refer to the [COPYING][license] file.

<sup>[Back to top ^][table-of-contents]</sup>

<!-- Links -->
[bundler]: https://bundler.io/
[contribute]: ./CONTRIBUTING.md
[doppler]: https://docs.doppler.com/docs/install-cli
[fastlane]: https://docs.fastlane.tools/
[flutter]: https://docs.flutter.dev/get-started/install
[make]: https://www.gnu.org/software/make/
[license]: ./COPYING
[ruby]: https://www.ruby-lang.org/en/documentation/installation/
[table-of-contents]: #table-of-contents

