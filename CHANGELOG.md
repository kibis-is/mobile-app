# [1.0.0-beta.12](https://github.com/kibis-is/mobile-app/compare/v1.0.0-beta.11...v1.0.0-beta.12) (2024-10-24)


### Bug Fixes

* Align action button to the left to prevent overlapping with floating action button. ([189cb71](https://github.com/kibis-is/mobile-app/commit/189cb71d355473157bac45e1e12075c819323c61))
* Asset select field on the Send Transaction screen now fixed to handle long lists of items. ([ddce1bd](https://github.com/kibis-is/mobile-app/commit/ddce1bd25962707fb577b3d93ebcd1b36bedae47))
* Bottom sheet now correctly scrolling with high long lists ([a31f159](https://github.com/kibis-is/mobile-app/commit/a31f15919df25c9b2919b026628a734e7d843ead))
* Bottom sheet title now aligns correctyl to centre ([6ba7139](https://github.com/kibis-is/mobile-app/commit/6ba7139eee590e7c04dd1df18569a5f56a2e075d))
* Change to allow user to open 'already added' assets in the asset search screen. ([3c709c2](https://github.com/kibis-is/mobile-app/commit/3c709c23234fc02294db038db6627a84a1a4c5aa))
* Correctly showing Algorand icons instead of Voi icons when using the Algorand network. ([a29037d](https://github.com/kibis-is/mobile-app/commit/a29037d014effae55aacabad0099357fddc20563))
* Fix bug when switching networks when viewing in a tablet or desktop where the left panel still shows an asset from the other network. ([1ba1dde](https://github.com/kibis-is/mobile-app/commit/1ba1ddebee2c43701a9fc56df585de053b180389))
* Fixed error showing when user selected network already active, causing it to re-init the account. Now correctly takes no action. ([abf7341](https://github.com/kibis-is/mobile-app/commit/abf73412636da5f77d9d8b6b72a8cbe78ea3af59))
* Fixed issue with searching and opting in to assets. ([9deb1c9](https://github.com/kibis-is/mobile-app/commit/9deb1c9ce934f304c35e450bdbeb0a57cb1704da))
* Now once again showing the date / time of transactions ([aff392a](https://github.com/kibis-is/mobile-app/commit/aff392a203f3069331fc81c8a10d7896b531efad))
* remove unused commented code ([3c16486](https://github.com/kibis-is/mobile-app/commit/3c164864a466604cb7a97b6e27deeaa43dbbe82f))
* Removed some irrelevant comments ([0ee9aa6](https://github.com/kibis-is/mobile-app/commit/0ee9aa66ae503f7d1a1ec4322d3a9fafa4dd70b5))
* removed some unused code ([63b5ce0](https://github.com/kibis-is/mobile-app/commit/63b5ce024d1ae342167c7d30d557d28c22c6297d))
* version number updates for leak_tracker ([880c1dd](https://github.com/kibis-is/mobile-app/commit/880c1dda0f212a5b082c59d83b6347f47cba94d9))


### Features

* Now showing shimmer effect when loading sessions in place of the default circular spinner ([394e84d](https://github.com/kibis-is/mobile-app/commit/394e84d5fc0932219397cd9ea35aa360e6018702))
* Now showing shimmer effect when searching for assets, in place of the default circular spinner ([535be5f](https://github.com/kibis-is/mobile-app/commit/535be5f99eb7c2e8893b93b8bd2ffe1d06d43f07))
* shimmer loading effect on account name when fetching account details. ([4067ec3](https://github.com/kibis-is/mobile-app/commit/4067ec30adbaa7bf87d9833f1f68cdc2bdbf55ac))
* Users can now change between Voi and Algorand main and test networks. ([eeaa20c](https://github.com/kibis-is/mobile-app/commit/eeaa20cf60797b6011dcc12acc7f9d987197857b))

# [1.0.0-beta.11](https://github.com/kibis-is/mobile-app/compare/v1.0.0-beta.10...v1.0.0-beta.11) (2024-10-16)


### Features

* add adaptive icons ([#13](https://github.com/kibis-is/mobile-app/issues/13)) ([a6fe285](https://github.com/kibis-is/mobile-app/commit/a6fe28504a1efc5abea1db29e92516f77522068a))

# [1.0.0-beta.10](https://github.com/kibis-is/mobile-app/compare/v1.0.0-beta.9...v1.0.0-beta.10) (2024-10-10)


### Features

* add a delete contact button ([65ca386](https://github.com/kibis-is/mobile-app/commit/65ca3864ebf7a9dd32265a8bf1072e4b15566e68))

# [1.0.0-beta.9](https://github.com/kibis-is/mobile-app/compare/v1.0.0-beta.8...v1.0.0-beta.9) (2024-10-10)


### Bug Fixes

* incorrect version of test package for currently used dart sdk. Set to 1.24.9 ([8fc7567](https://github.com/kibis-is/mobile-app/commit/8fc75673ec9a37f6e17c5c7137ce89b06364287f))
* Remove unused variable ([915d865](https://github.com/kibis-is/mobile-app/commit/915d865d9d776e0aaf445b5e4eb3ca274402f420))

# [1.0.0-beta.8](https://github.com/kibis-is/mobile-app/compare/v1.0.0-beta.7...v1.0.0-beta.8) (2024-10-09)


### Bug Fixes

* export account screen qr code where it was not displaying correctly on landscape ([5951b99](https://github.com/kibis-is/mobile-app/commit/5951b997b25a965754fb5cd7ad12be26c493d806))

# [1.0.0-beta.7](https://github.com/kibis-is/mobile-app/compare/v1.0.0-beta.6...v1.0.0-beta.7) (2024-10-09)


### Features

* move fastlane to automatically publish ([e364199](https://github.com/kibis-is/mobile-app/commit/e364199e4c517ad2dbcd21e223b992569ca573a4))

# [1.0.0-beta.6](https://github.com/kibis-is/mobile-app/compare/v1.0.0-beta.5...v1.0.0-beta.6) (2024-10-09)


### Bug Fixes

* use correct fastlane option ([8b64705](https://github.com/kibis-is/mobile-app/commit/8b647057250ee77025488b32155530c251fea525))

# [1.0.0-beta.5](https://github.com/kibis-is/mobile-app/compare/v1.0.0-beta.4...v1.0.0-beta.5) (2024-10-09)


### Features

* update package mismatch ([3979324](https://github.com/kibis-is/mobile-app/commit/39793244f0817b24dabb05d2ba46563419e91468))

# [1.0.0-beta.4](https://github.com/kibis-is/mobile-app/compare/v1.0.0-beta.3...v1.0.0-beta.4) (2024-10-09)


### Bug Fixes

* check if the widget is mounted before using pagingcontroller ([5b734a7](https://github.com/kibis-is/mobile-app/commit/5b734a7fce6ea872c3a34f99cf2a69472253650c))
* not updating the active asset provider when selecting an asset from add assets screen ([19b8e4b](https://github.com/kibis-is/mobile-app/commit/19b8e4b1045bed0dbf586a205e70254508796ded))
* reduce the confetti ([86e76e8](https://github.com/kibis-is/mobile-app/commit/86e76e8b42f17b14ffae4cf8f432e6d4464a995e))
* update the app reset function to delete all instead of deleting 1 by 1. ([8397f4f](https://github.com/kibis-is/mobile-app/commit/8397f4fdcf6ec1f66c91953ead8d4376baf6b9c8))


### Features

* add a different color to each of the fab submenu items ([0fe1b56](https://github.com/kibis-is/mobile-app/commit/0fe1b569c356b400a8cc467fef381dbb486b0a09))
* add contact address book ([ebd4b48](https://github.com/kibis-is/mobile-app/commit/ebd4b48aabf0ed4bc7c5a05247c1a2143770df8d))
* add last used date on contacts and show the contact names in transaction items ([21a8f53](https://github.com/kibis-is/mobile-app/commit/21a8f53f0d96a325994707055ad78dddfe33c893))
* add pagination and ignore duplicate accounts scanned ([3522678](https://github.com/kibis-is/mobile-app/commit/35226780ac6f2a83bd2eb6d99c976c55c0010ca2))
* change security screen time picker to use bottom sheet ([455c2b1](https://github.com/kibis-is/mobile-app/commit/455c2b1b5b4aca3eb7e8956d44eb9aca2e982452))
* implement paginated scan imports ([d3e6afd](https://github.com/kibis-is/mobile-app/commit/d3e6afd12fa5d332d7bb28dc689c5beeb0338a1b))

# [1.0.0-beta.2](https://github.com/kibis-is/mobile-app/compare/v1.0.0-beta.1...v1.0.0-beta.2) (2024-09-26)


### Features

* add arc 0200 contract wrapper ([#5](https://github.com/kibis-is/mobile-app/issues/5)) ([ecaa62a](https://github.com/kibis-is/mobile-app/commit/ecaa62add7dd84e009597148c21dc627eac7e39a))

# 1.0.0-beta.1 (2024-08-29)


### Features

* add release workflow and commit linting ([#2](https://github.com/kibis-is/mobile-app/issues/2)) ([b369557](https://github.com/kibis-is/mobile-app/commit/b3695571f19a6f39325b882a46fd390bdfe99c00))
