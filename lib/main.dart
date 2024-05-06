import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/features/settings/providers/settings_providers.dart';
import 'package:kibisis/providers/mnemonic_provider.dart';
import 'package:kibisis/routing/go_router_provider.dart';
import 'package:kibisis/theme/themes.dart';
import 'package:loading_overlay/loading_overlay.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
    final wallet = ref.watch(walletManagerProvider);

    return LoadingOverlay(
      isLoading: wallet.isLoading,
      child: MaterialApp.router(
        routerConfig: router,
        title: 'Kibisis',
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: isDarkTheme ? ThemeMode.dark : ThemeMode.light,
      ),
    );
  }
}
