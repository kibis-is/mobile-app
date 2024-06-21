import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/features/settings/appearance/providers/dark_mode_provider.dart';
import 'package:kibisis/providers/active_account_provider.dart';
import 'package:kibisis/providers/loading_provider.dart';
import 'package:kibisis/providers/storage_provider.dart';
import 'package:kibisis/routing/go_router_provider.dart';
import 'package:kibisis/theme/themes.dart';
import 'package:kibisis/utils/app_lifecycle_handler.dart';
import 'package:kibisis/utils/theme_extensions.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:kibisis/providers/account_provider.dart';
import 'package:kibisis/providers/algorand_provider.dart';
import 'package:kibisis/providers/assets_provider.dart';
import 'package:kibisis/providers/balance_provider.dart';

final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: Kibisis()));
}

class Kibisis extends ConsumerStatefulWidget {
  const Kibisis({super.key});

  @override
  ConsumerState<Kibisis> createState() => _KibisisState();
}

class _KibisisState extends ConsumerState<Kibisis> {
  late AppLifecycleHandler _lifecycleHandler;

  @override
  void initState() {
    super.initState();
    _lifecycleHandler = AppLifecycleHandler(
        ref: ref,
        onResumed: (seconds) {
          debugPrint('App was resumed after $seconds seconds');
        });
    _lifecycleHandler.initialize();
  }

  @override
  void dispose() {
    _lifecycleHandler.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final sharedPreferences = ref.watch(sharedPreferencesProvider);

        return sharedPreferences.when(
          data: (prefs) {
            final isDarkTheme = ref.watch(isDarkModeStateAdapter);
            final isLoading = ref.watch(loadingProvider);
            final router = ref.watch(goRouterProvider);

            return MaterialApp.router(
              scaffoldMessengerKey: rootScaffoldMessengerKey,
              routerConfig: router,
              title: 'Kibisis',
              theme: lightTheme,
              darkTheme: darkTheme,
              themeMode: isDarkTheme ? ThemeMode.dark : ThemeMode.light,
              builder: (context, widget) => ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: LoadingOverlay(
                  isLoading: isLoading,
                  color: context.colorScheme.background,
                  opacity: 0.5,
                  child: Center(child: widget),
                ),
              ),
            );
          },
          loading: () => const Material(
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (error, stack) => const Material(
            child: Center(
                child: Text('Initialization error, please restart the app.')),
          ),
        );
      },
    );
  }
}
