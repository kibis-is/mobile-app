import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/common_widgets/custom_loading_overlay.dart';
import 'package:kibisis/common_widgets/splash_screen.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/features/settings/appearance/providers/dark_mode_provider.dart';
import 'package:kibisis/providers/connectivity_provider.dart';
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
        final isConnected = ref.watch(connectivityProvider);

        return sharedPreferences.when(
          data: (prefs) {
            final isDarkTheme = ref.watch(isDarkModeStateAdapter);
            final router = ref.watch(goRouterProvider);
            final isFullScreen = ref.watch(loadingProvider).fullScreen;
            final progress = ref.watch(loadingProvider).progress;
            final message = ref.watch(loadingProvider).message;
            final isLoading = ref.watch(loadingProvider).isLoading;

            SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness:
                  isDarkTheme ? Brightness.dark : Brightness.light,
              systemNavigationBarColor: Colors.black,
              systemNavigationBarIconBrightness: Brightness.light,
            ));

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
                    progressIndicator: CustomLoadingOverlay(
                      text: message,
                      percent: progress,
                    ),
                    isLoading: isLoading,
                    color: isFullScreen
                        ? context.colorScheme.background
                        : Colors.black,
                    opacity: isFullScreen ? 1.0 : 0.6,
                    child: Stack(
                      children: [
                        DefaultColorInitializer(child: Center(child: widget)),
                        if (isSplashScreenVisible) const SplashScreen(),
                        if (!isConnected)
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              color: context.colorScheme.error,
                              padding: const EdgeInsets.all(kScreenPadding / 2),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.warning,
                                      color: context.colorScheme.onError),
                                  const SizedBox(width: kScreenPadding / 2),
                                  Text(
                                    'No Internet Connection',
                                    style: context.textTheme.displaySmall
                                        ?.copyWith(
                                            color: context.colorScheme.onError),
                                  ),
                                ],
                              ),
                            ),
                          ),
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
