import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/features/settings/providers/settings_providers.dart';
import 'package:kibisis/providers/wallet_manager_provider.dart';
import 'package:kibisis/routing/go_router_provider.dart';
import 'package:kibisis/theme/themes.dart';
import 'package:loading_overlay/loading_overlay.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  runApp(const ProviderScope(
    child: Kibisis(),
  ));
}

class Kibisis extends ConsumerWidget {
  const Kibisis({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);
    final isDarkTheme = ref.watch(isDarkModeProvider);
    final walletManager = ref.watch(walletManagerProvider);

    return MaterialApp.router(
      routerConfig: router,
      title: 'Kibisis',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: isDarkTheme ? ThemeMode.dark : ThemeMode.light,
      builder: (context, widget) => ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: LoadingOverlay(
          isLoading: walletManager.isLoading,
          color: Theme.of(context).colorScheme.background,
          opacity: 0.5,
          child: Center(
            child: widget,
          ),
        ),
      ),
    );
  }
}
