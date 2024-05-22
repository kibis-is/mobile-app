import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/common_widgets/custom_snackbar.dart';
import 'package:kibisis/features/settings/providers/settings_providers.dart';
import 'package:kibisis/providers/error_provider.dart';
import 'package:kibisis/providers/loading_provider.dart';
import 'package:kibisis/providers/storage_provider.dart';
import 'package:kibisis/routing/go_router_provider.dart';
import 'package:kibisis/theme/themes.dart';
import 'package:loading_overlay/loading_overlay.dart';

final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: Kibisis()));
}

class Kibisis extends ConsumerWidget {
  const Kibisis({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Correct placement of ref.listen
    ref.listen<String?>(errorProvider, (previous, next) {
      if (next != null && next.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          rootScaffoldMessengerKey.currentState?.showSnackBar(
            customSnackbar(context, next),
          );
        });
        ref.read(errorProvider.notifier).state = null; // Reset the error
      }
    });

    return FutureBuilder(
      future: ref.read(sharedPreferencesProvider.future),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          final router = ref.watch(goRouterProvider);
          final isDarkTheme = ref.watch(isDarkModeProvider);
          final isLoading = ref.watch(loadingProvider);

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
                color: Theme.of(context).colorScheme.background,
                opacity: 0.5,
                child: Center(child: widget),
              ),
            ),
          );
        } else if (snapshot.hasError) {
          return const Material(
            child: Center(
                child: Text('Initialization error, please restart the app.')),
          );
        } else {
          return const Material(
            child: Center(child: CircularProgressIndicator()),
          );
        }
      },
    );
  }
}
