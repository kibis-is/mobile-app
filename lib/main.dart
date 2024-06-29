import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/common_widgets/splash_screen.dart';
import 'package:kibisis/features/settings/appearance/providers/dark_mode_provider.dart';
import 'package:kibisis/providers/loading_provider.dart';
import 'package:kibisis/providers/splash_screen_provider.dart';
import 'package:kibisis/providers/storage_provider.dart';
import 'package:kibisis/routing/go_router_provider.dart';
import 'package:kibisis/theme/themes.dart';
import 'package:kibisis/utils/app_icons.dart';
import 'package:kibisis/utils/theme_extensions.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:kibisis/utils/app_lifecycle_handler.dart';

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
      },
    );
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
        final isSplashScreenVisible = ref.watch(isSplashScreenVisibleProvider);

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
              builder: (context, widget) {
                return ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: LoadingOverlay(
                    isLoading: isLoading,
                    color: context.colorScheme.background,
                    opacity: 0.5,
                    child: Stack(
                      children: [
                        DefaultColorInitializer(child: Center(child: widget)),
                        if (isSplashScreenVisible) const SplashScreen(),
                      ],
                    ),
                  ),
                );
              },
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

class DefaultColorInitializer extends StatelessWidget {
  final Widget child;

  const DefaultColorInitializer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // Initialize the default color after the theme has been applied
    AppIcons.initializeDefaultColor(context);
    return child;
  }
}
