import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/common_widgets/custom_loading_overlay.dart';
import 'package:kibisis/common_widgets/loading_overlay.dart';
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
import 'package:kibisis/utils/media_query_helper.dart';
import 'package:kibisis/utils/theme_extensions.dart';
import 'package:kibisis/utils/app_lifecycle_handler.dart';
import 'package:kibisis/utils/wallet_connect_manageer.dart';

final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

void main() {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  runApp(
    Builder(builder: (context) {
      final mediaQueryHelper = MediaQueryHelper(context);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mediaQueryHelper.isWideScreen()) {
          SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
        } else {
          SystemChrome.setPreferredOrientations([
            DeviceOrientation.portraitUp,
            DeviceOrientation.portraitDown,
            DeviceOrientation.landscapeLeft,
            DeviceOrientation.landscapeRight,
          ]);
        }
      });

      return const ProviderScope(child: Kibisis());
    }),
  );
}

class Kibisis extends ConsumerStatefulWidget {
  const Kibisis({super.key});

  @override
  ConsumerState<Kibisis> createState() => _KibisisState();
}

class _KibisisState extends ConsumerState<Kibisis> {
  late AppLifecycleHandler _lifecycleHandler;
  late WalletConnectManager walletConnectManager;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _initializeApp();
      FlutterNativeSplash.remove();
    });
  }

  Future<void> _initializeApp() async {
    final storageService = ref.read(storageProvider);
    storageService
        .getActiveAccount(); // Ensure account loading happens after prefs init
    walletConnectManager = WalletConnectManager(storageService);
    await walletConnectManager.reconnectSessions();
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
        // Watch sharedPreferencesProvider to delay build until prefs are initialized
        final sharedPreferences = ref.watch(sharedPreferencesProvider);
        final isSplashScreenVisible = ref.watch(isSplashScreenVisibleProvider);
        final isConnected = ref.watch(connectivityProvider);

        return sharedPreferences.when(
          data: (_) {
            // All initialization has completed, safe to read other providers
            final isDarkTheme = ref.watch(isDarkModeStateAdapter);
            final router = ref.watch(goRouterProvider);
            final loadingState = ref.watch(loadingProvider);

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
                      text: loadingState.message,
                      percent: loadingState.progress,
                    ),
                    isLoading: loadingState.isLoading,
                    color: context.colorScheme.surface,
                    opacity: 1.0,
                    child: DefaultColorInitializer(
                      child: Center(
                        child: Column(
                          children: [
                            Expanded(child: widget ?? const SizedBox.shrink()),
                            Visibility(
                              visible: isSplashScreenVisible,
                              child: const SplashScreen(),
                            ),
                            Visibility(
                              visible: !isConnected,
                              child: _buildConnectionWarning(context),
                            ),
                          ],
                        ),
                      ),
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

  Widget _buildConnectionWarning(BuildContext context) {
    return Container(
      color: context.colorScheme.error,
      padding: const EdgeInsets.all(kScreenPadding / 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.warning, color: context.colorScheme.onError),
          const SizedBox(width: kScreenPadding / 2),
          Text(
            'No Internet Connection',
            style: context.textTheme.displaySmall
                ?.copyWith(color: context.colorScheme.onError),
          ),
        ],
      ),
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
