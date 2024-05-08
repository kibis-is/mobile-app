import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/features/add_asset/add_asset_screen.dart';
import 'package:kibisis/features/add_wallet/add_wallet_screen.dart';
import 'package:kibisis/features/dashboard/dashboard_screen.dart';
import 'package:kibisis/features/dashboard/wallet_screen.dart';
import 'package:kibisis/features/error/error_screen.dart';
import 'package:kibisis/features/pin_pad/pin_pad_screen.dart';
import 'package:kibisis/features/settings/about/about_screen.dart';
import 'package:kibisis/features/settings/advanced/advanced_screen.dart';
import 'package:kibisis/features/settings/appearance/appearance_screen.dart';
import 'package:kibisis/features/settings/general/general_screen.dart';
import 'package:kibisis/features/settings/security/security_screen.dart';
import 'package:kibisis/features/settings/sessions/sessions_screen.dart';
import 'package:kibisis/features/settings/settings_screen.dart';
import 'package:kibisis/features/setup_account/add_account/add_account_screen.dart';
import 'package:kibisis/features/setup_account/create_account/create_account_screen.dart';
import 'package:kibisis/features/setup_account/welcome/welcome_screen.dart';
import 'package:kibisis/features/send_voi/send_voi_screen.dart';
import 'package:kibisis/features/setup_account/import_via_seed/import_account_via_seed_screen.dart';
import 'package:kibisis/providers/wallet_manager_provider.dart';
import 'package:kibisis/routing/named_routes.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final router = RouterNotifier(ref);
  return GoRouter(
    refreshListenable: router,
    routes: router._routes,
    redirect: router._redirectLogic,
    initialLocation: '/$welcomeRouteName',
    errorPageBuilder: (context, state) {
      // Retrieve the error message from the state
      final errorMessage =
          state.error?.toString() ?? 'No specific error message provided.';
      return MaterialPage(
        key: state
            .pageKey, // Ensure to pass the pageKey for proper state management
        child: ErrorScreen(errorMessage: errorMessage),
      );
    },
  );
});

class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterNotifier(this._ref) {
    _ref.listen<WalletState>(
      walletManagerProvider,
      (_, __) => notifyListeners(),
    );
  }

  Future<String?> _redirectLogic(
      BuildContext context, GoRouterState state) async {
    final walletState = _ref.read(walletManagerProvider);
    bool isWalletInitialized = walletState.accountName?.isNotEmpty ?? false;
    final hasAccountFromStorage =
        await _ref.read(walletManagerProvider.notifier).hasAccountFromStorage();
    FlutterNativeSplash.remove();

    // If there is no account from storage, and user is not on a setup page, redirect to setup.
    if (!hasAccountFromStorage && !state.uri.toString().startsWith('/setup')) {
      return '/setup';
    }

    // If an account exists in storage but is not initialized, and user is not on the pin screen, Redirect to the PIN screen
    else if (hasAccountFromStorage &&
        !isWalletInitialized &&
        !state.uri.toString().startsWith('/pinPad')) {
      return '/pinPad';
    }

    // If the wallet is initialized and the user is on either the setup page or the pin page, redirect to the home page.
    else if (isWalletInitialized &&
        (state.uri.toString().startsWith('/setup') ||
            state.uri.toString().startsWith('/pinPad'))) {
      return '/';
    }

    // No redirection needed; stay on the current route.
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
              path: setupPinPadRouteName,
              name: setupPinPadRouteName,
              pageBuilder: (context, state) {
                return defaultTransitionPage(
                    const PinPadScreen(
                      mode: PinPadMode.setup,
                    ),
                    state);
              },
            ),
            GoRoute(
              name: addAccountRouteName,
              path: addAccountRouteName,
              pageBuilder: (context, state) {
                return defaultTransitionPage(const AddAccountScreen(), state);
              },
            ),
            GoRoute(
              name: createAccountRouteName,
              path: createAccountRouteName,
              pageBuilder: (context, state) {
                return defaultTransitionPage(
                    const CreateAccountScreen(), state);
              },
            ),
            GoRoute(
              name: importAccountViaSeedRouteName,
              path: importAccountViaSeedRouteName,
              pageBuilder: (context, state) {
                return defaultTransitionPage(
                    const ImportAccountViaSeedScreen(), state);
              },
            ),
          ],
        ),
        GoRoute(
          path: '/$pinPadRouteName',
          name: pinPadRouteName,
          pageBuilder: (context, state) {
            return defaultTransitionPage(
                const PinPadScreen(
                  mode: PinPadMode.unlock,
                ),
                state);
          },
        ),
        GoRoute(
          path: '/',
          name: rootRouteName,
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
              name: addWalletRouteName,
              path: addWalletRouteName,
              pageBuilder: (context, state) {
                return defaultTransitionPage(AddWalletScreen(), state);
              },
            ),
            GoRoute(
              name: sendVOIRouteName,
              path: sendVOIRouteName,
              pageBuilder: (context, state) {
                return defaultTransitionPage(const SendVOIScreen(), state);
              },
            ),
            GoRoute(
              path: settingsRouteName,
              name: settingsRouteName,
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
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return child;
      },
    );
  }
}
