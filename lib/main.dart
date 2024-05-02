import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/routing/go_router_provider.dart';
import 'package:kibisis/theme/providers/theme_provider.dart';
import 'package:kibisis/theme/themes.dart';

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

    final theme = ref.watch(themeProvider);

    return MaterialApp.router(
      routerConfig: router,
      title: 'Kibisis',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: theme,
    );
  }
}
