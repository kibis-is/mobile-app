import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:kibisis/providers/platform_info/state.dart';

class PlatformInfoNotifier extends StateNotifier<PlatformInfoState> {
  PlatformInfoNotifier() : super(PlatformInfoState(
    build: kDebugMode ? 'debug' : 'release',
    buildNumber: '-',
    version: '-',
  )) {
    _platformInfo();
  }

  Future<void> _platformInfo() async {
    const build = kDebugMode ? 'debug' : 'release';

    try {
      final packageInfo = await PackageInfo.fromPlatform();

      state = PlatformInfoState(
        build: build,
        buildNumber: packageInfo.buildNumber,
        version: packageInfo.version,
      );
    } catch (error) {
      debugPrint('failed to get platform info: $error');

      state = PlatformInfoState(
        build: build,
        buildNumber: '-',
        version: '-',
      );
    }
  }
}

final platformInfoProvider = StateNotifierProvider<PlatformInfoNotifier, PlatformInfoState>(
      (ref) => PlatformInfoNotifier(),
);
