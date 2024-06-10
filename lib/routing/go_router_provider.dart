import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/features/add_asset/add_asset_screen.dart';
import 'package:kibisis/features/dashboard/dashboard_screen.dart';
import 'package:kibisis/features/dashboard/wallet_screen.dart';
import 'package:kibisis/features/error/error_screen.dart';
import 'package:kibisis/features/pin_pad/pin_pad_screen.dart';
import 'package:kibisis/features/scan_qr/scan_qr_screen.dart';
import 'package:kibisis/features/settings/about/about_screen.dart';
import 'package:kibisis/features/settings/advanced/advanced_screen.dart';
import 'package:kibisis/features/settings/appearance/appearance_screen.dart';
import 'package:kibisis/features/settings/general/general_screen.dart';
import 'package:kibisis/features/settings/security/security_screen.dart';
import 'package:kibisis/features/settings/sessions/sessions_screen.dart';
import 'package:kibisis/features/settings/settings_screen.dart';
import 'package:kibisis/features/setup_account/add_account/add_account_screen.dart';
import 'package:kibisis/features/setup_account/copy_seed_screen/copy_seed_screen.dart';
import 'package:kibisis/features/setup_account/name_account/name_account_screen.dart';
import 'package:kibisis/features/setup_account/welcome/welcome_screen.dart';
import 'package:kibisis/features/send_transaction/send_transaction_screen.dart';
import 'package:kibisis/features/setup_account/import_via_seed/import_account_via_seed_screen.dart';
import 'package:kibisis/features/view_asset/view_asset_screen.dart';
import 'package:kibisis/providers/authentication_provider.dart';
import 'package:kibisis/providers/setup_complete_provider.dart';
import 'package:kibisis/providers/storage_provider.dart';
import 'package:kibisis/routing/named_routes.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final router = RouterNotifier(ref);
  return GoRouter(
    refreshListenable: router,
    routes: router._routes,
    redirect: router._redirectLogic,
    initialLocation: '/$welcomeRouteName',
    errorPageBuilder: (context, state) {
      final errorMessage =
          state.error?.toString() ?? 'No specific error message provided.';
      return MaterialPage(
        key: state.pageKey,
        child: ErrorScreen(errorMessage: errorMessage),
      );
    },
  );
});

class RouterNotifier extends ChangeNotifier {
  final Ref ref;

  RouterNotifier(this.ref) {
    ref.listen<bool>(
      setupCompleteProvider,
      (_, __) => notifyListeners(),
    );
    ref.listen<bool>(
      isAuthenticatedProvider,
      (_, __) => notifyListeners(),
    );
  }

  Future<String?> _redirectLogic(
      BuildContext context, GoRouterState state) async {
    final container = ProviderScope.containerOf(context);

    final isSetupComplete = container.read(setupCompleteProvider);
    final isAuthenticated = container.read(isAuthenticatedProvider);

    bool hasAccount = await container.read(storageProvider).accountExists();

    FlutterNativeSplash.remove();
    debugPrint('refresh the routing');

    if (!hasAccount &&
        !state.uri.toString().startsWith('/setup') &&
        !isSetupComplete) {
      debugPrint('redirect to /setup');
      return '/setup';
    } else if (hasAccount &&
        !isAuthenticated &&
        !state.uri.toString().startsWith('/pinPadUnlock')) {
      debugPrint('redirect to /pinPadUnlock');
      return '/pinPadUnlock';
    } else if (hasAccount &&
        isAuthenticated &&
        (state.uri.toString().startsWith('/setup') ||
            state.uri.toString().startsWith('/pinPad'))) {
      debugPrint('redirect to /');
      return '/';
    }

    debugPrint('No redirection needed');
    return null;
  }

  List<GoRoute> get _routes => [
        GoRoute(
          name: welcomeRouteName,
          path: '/$welcomeRouteName',
          pageBuilder: (context, state) {
            return defaultTransitionPage(const WelcomeScreen(), state);
          },
          routes: [
            GoRoute(
              name: pinPadSetupRouteName,
              path: pinPadSetupRouteName,
              pageBuilder: (context, state) {
                return defaultTransitionPage(
                    const PinPadScreen(
                      mode: PinPadMode.setup,
                    ),
                    state);
              },
            ),
            GoRoute(
              name: setupAddAccountRouteName,
              path: setupAddAccountRouteName,
              pageBuilder: (context, state) {
                return defaultTransitionPage(
                  const AddAccountScreen(accountFlow: AccountFlow.setup),
                  state,
                );
              },
            ),
            GoRoute(
              name: setupCopySeedRouteName,
              path: setupCopySeedRouteName,
              pageBuilder: (context, state) {
                return defaultTransitionPage(
                    const CopySeedScreen(
                      accountFlow: AccountFlow.setup,
                    ),
                    state);
              },
            ),
            GoRoute(
              name: setupImportSeedRouteName,
              path: setupImportSeedRouteName,
              pageBuilder: (context, state) {
                return defaultTransitionPage(
                    const ImportSeedScreen(
                      accountFlow: AccountFlow.setup,
                    ),
                    state);
              },
            ),
            GoRoute(
              name: setupNameAccountRouteName,
              path: setupNameAccountRouteName,
              pageBuilder: (context, state) {
                return defaultTransitionPage(
                  const NameAccountScreen(accountFlow: AccountFlow.setup),
                  state,
                );
              },
            ),
            GoRoute(
              name: setupImportQrRouteName,
              path: setupImportQrRouteName,
              pageBuilder: (context, state) {
                return defaultTransitionPage(
                    const QrCodeScannerScreen(accountFlow: AccountFlow.setup),
                    state);
              },
            ),
          ],
        ),
        GoRoute(
          name: mainAddAccountRouteName,
          path: '/$mainAddAccountRouteName',
          pageBuilder: (context, state) {
            return defaultTransitionPage(
              const AddAccountScreen(accountFlow: AccountFlow.addNew),
              state,
            );
          },
          routes: [
            GoRoute(
              name: mainCopySeedRouteName,
              path: mainCopySeedRouteName,
              pageBuilder: (context, state) {
                return defaultTransitionPage(
                    const CopySeedScreen(
                      accountFlow: AccountFlow.addNew,
                    ),
                    state);
              },
            ),
            GoRoute(
              name: mainImportSeedRouteName,
              path: mainImportSeedRouteName,
              pageBuilder: (context, state) {
                return defaultTransitionPage(
                    const ImportSeedScreen(
                      accountFlow: AccountFlow.addNew,
                    ),
                    state);
              },
            ),
            GoRoute(
              name: mainNameAccountRouteName,
              path: mainNameAccountRouteName,
              pageBuilder: (context, state) {
                return defaultTransitionPage(
                  const NameAccountScreen(accountFlow: AccountFlow.addNew),
                  state,
                );
              },
            ),
            GoRoute(
              name: mainImportQrRouteName,
              path: mainImportQrRouteName,
              pageBuilder: (context, state) {
                return defaultTransitionPage(
                    const QrCodeScannerScreen(accountFlow: AccountFlow.addNew),
                    state);
              },
            ),
          ],
        ),
        GoRoute(
          name: editNameAccountRouteName,
          path: '/editAccount/:accountId',
          pageBuilder: (context, state) {
            final accountId = state.pathParameters['accountId']!;
            final extra = state.extra as Map<String, String>?;
            final accountName = extra?['accountName'];
            return defaultTransitionPage(
              NameAccountScreen(
                accountFlow: AccountFlow.edit,
                accountId: accountId,
                initialAccountName: accountName,
              ),
              state,
            );
          },
        ),
        GoRoute(
          name: pinPadUnlockRouteName,
          path: '/$pinPadUnlockRouteName',
          pageBuilder: (context, state) {
            return defaultTransitionPage(
                const PinPadScreen(
                  mode: PinPadMode.unlock,
                ),
                state);
          },
        ),
        GoRoute(
          name: rootRouteName,
          path: '/',
          pageBuilder: (context, state) {
            return defaultTransitionPage(const DashboardScreen(), state);
          },
          routes: [
            GoRoute(
              name: walletsRouteName,
              path: walletsRouteName,
              pageBuilder: (context, state) {
                return defaultTransitionPage(const WalletsScreen(), state);
              },
            ),
            GoRoute(
              name: addAssetRouteName,
              path: addAssetRouteName,
              pageBuilder: (context, state) {
                return defaultTransitionPage(AddAssetScreen(), state);
              },
            ),
            GoRoute(
              name: viewAssetRouteName,
              path: '$viewAssetRouteName/:assetId',
              pageBuilder: (context, state) {
                final assetId = state.pathParameters['assetId']!;
                return defaultTransitionPage(
                    ViewAssetScreen(assetId: assetId), state);
              },
            ),
            GoRoute(
              name: sendTransactionWithAssetIdRouteName,
              path: '$sendTransactionWithAssetIdRouteName/:mode/:assetId',
              pageBuilder: (context, state) {
                final mode = state.pathParameters['mode'] == 'currency'
                    ? SendTransactionScreenMode.currency
                    : SendTransactionScreenMode.asset;
                final assetId = mode == SendTransactionScreenMode.asset
                    ? int.tryParse(state.pathParameters['assetId'] ?? '0')
                    : null;
                return defaultTransitionPage(
                    SendTransactionScreen(
                      mode: mode,
                      assetId: assetId,
                    ),
                    state);
              },
            ),
            GoRoute(
              name: sendTransactionRouteName,
              path: '$sendTransactionRouteName/:mode',
              pageBuilder: (context, state) {
                final mode = state.pathParameters['mode'] == 'currency'
                    ? SendTransactionScreenMode.currency
                    : SendTransactionScreenMode.asset;
                return defaultTransitionPage(
                    SendTransactionScreen(
                      mode: mode,
                    ),
                    state);
              },
            ),
            GoRoute(
              name: settingsRouteName,
              path: settingsRouteName,
              pageBuilder: (context, state) {
                return defaultTransitionPage(const SettingsScreen(), state);
              },
              routes: [
                GoRoute(
                  name: generalRouteName,
                  path: generalRouteName,
                  pageBuilder: (context, state) {
                    return defaultTransitionPage(const GeneralScreen(), state);
                  },
                ),
                GoRoute(
                  name: securityRouteName,
                  path: securityRouteName,
                  pageBuilder: (context, state) {
                    return defaultTransitionPage(const SecurityScreen(), state);
                  },
                ),
                GoRoute(
                  name: appearanceRouteName,
                  path: appearanceRouteName,
                  pageBuilder: (context, state) {
                    return defaultTransitionPage(
                        const AppearanceScreen(), state);
                  },
                ),
                GoRoute(
                  name: sessionsRouteName,
                  path: sessionsRouteName,
                  pageBuilder: (context, state) {
                    return defaultTransitionPage(const SessionsScreen(), state);
                  },
                ),
                GoRoute(
                  name: advancedRouteName,
                  path: advancedRouteName,
                  pageBuilder: (context, state) {
                    return defaultTransitionPage(const AdvancedScreen(), state);
                  },
                ),
                GoRoute(
                  name: aboutRouteName,
                  path: aboutRouteName,
                  pageBuilder: (context, state) {
                    return defaultTransitionPage(const AboutScreen(), state);
                  },
                ),
              ],
            ),
          ],
        ),
      ];

  CustomTransitionPage defaultTransitionPage(
      Widget child, GoRouterState state) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) =>
          child,
    );
  }
}
