import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kibisis/constants/constants.dart';
import 'package:kibisis/features/add_asset/add_asset_screen.dart';
import 'package:kibisis/features/dashboard/dashboard_screen.dart';
import 'package:kibisis/features/dashboard/account_list_screen.dart';
import 'package:kibisis/features/error/error_screen.dart';
import 'package:kibisis/features/setup_account/add_watch/add_watch_screen.dart';
import 'package:kibisis/features/setup_account/import_via_private_key/import_via_private_key.dart';
import 'package:kibisis/features/view_nft/view_nft_screen.dart';
import 'package:kibisis/features/pin_pad/pin_pad_screen.dart';
import 'package:kibisis/features/scan_qr/scan_qr_screen.dart';
import 'package:kibisis/features/settings/about/about_screen.dart';
import 'package:kibisis/features/settings/advanced/advanced_screen.dart';
import 'package:kibisis/features/settings/appearance/appearance_screen.dart';
import 'package:kibisis/features/settings/general/general_screen.dart';
import 'package:kibisis/features/settings/providers/pin_lock_provider.dart';
import 'package:kibisis/features/settings/security/export_accounts.dart';
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
import 'package:kibisis/features/view_transaction/view_transaction_screen.dart';
import 'package:kibisis/generated/l10n.dart';
import 'package:kibisis/providers/authentication_provider.dart';
import 'package:kibisis/providers/loading_provider.dart';
import 'package:kibisis/providers/locale_provider.dart';
import 'package:kibisis/providers/setup_complete_provider.dart';
import 'package:kibisis/providers/storage_provider.dart';
import 'package:kibisis/routing/named_routes.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final routerNotifier = RouterNotifier(ref);
  return GoRouter(
    refreshListenable: routerNotifier,
    routes: routerNotifier._routes,
    redirect: routerNotifier._redirectLogic,
    initialLocation: '/$welcomeRouteName',
    errorPageBuilder: (context, state) {
      final errorMessage =
          state.error?.toString() ?? S.of(context).somethingWentWrong;
      return MaterialPage(
        key: state.pageKey,
        child: ErrorScreen(errorMessage: errorMessage),
      );
    },
    observers: [
      CustomNavigatorObserver(ref),
    ],
  );
});

class CustomNavigatorObserver extends NavigatorObserver {
  final Ref ref;

  CustomNavigatorObserver(this.ref);
}

class RouterNotifier extends ChangeNotifier {
  final Ref ref;
  bool? _previousSetupComplete;
  bool? _previousIsAuthenticated;

  RouterNotifier(this.ref) {
    ref.listen<bool>(
      setupCompleteProvider,
      (previous, next) {
        if (_previousSetupComplete != next) {
          _previousSetupComplete = next;
          notifyListeners();
        }
      },
    );
    ref.listen<bool>(
      isAuthenticatedProvider,
      (previous, next) {
        if (_previousIsAuthenticated != next) {
          _previousIsAuthenticated = next;
          notifyListeners();
        }
      },
    );

    ref.listen<Locale?>(
      localeProvider,
      (_, __) {
        notifyListeners();
      },
    );
  }

  Future<String?> _redirectLogic(
      BuildContext context, GoRouterState state) async {
    final container = ProviderScope.containerOf(context);

    final isSetupComplete = container.read(setupCompleteProvider);
    final isAuthenticated = container.read(isAuthenticatedProvider);
    final isPasswordLockEnabled = container.read(pinLockProvider);
    bool hasAccount = await container.read(storageProvider).accountExists();

    String? redirectPath;

    if (!hasAccount &&
        !state.uri.toString().startsWith('/setup') &&
        !isSetupComplete) {
      redirectPath = '/setup';
    } else if (hasAccount &&
        !isAuthenticated &&
        isPasswordLockEnabled &&
        !state.uri.toString().startsWith('/pinPadUnlock')) {
      redirectPath = '/pinPadUnlock';
    } else if (hasAccount &&
        (isAuthenticated || !isPasswordLockEnabled) &&
        (state.uri.toString().startsWith('/setup') ||
            state.uri.toString().startsWith('/pinPad'))) {
      redirectPath = '/';
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(loadingProvider.notifier).stopLoading();
    });

    return redirectPath;
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
                    const QrCodeScannerScreen(
                      accountFlow: AccountFlow.setup,
                      scanMode: ScanMode.privateKey,
                    ),
                    state);
              },
            ),
            GoRoute(
              name: setupPrivateKeyRouteName,
              path: setupPrivateKeyRouteName,
              pageBuilder: (context, state) {
                return defaultTransitionPage(
                    const ImportPrivateKeyScreen(
                      accountFlow: AccountFlow.setup,
                    ),
                    state);
              },
            ),
            GoRoute(
              name: setupAddWatchAccountRouteName,
              path: setupAddWatchAccountRouteName,
              pageBuilder: (context, state) {
                return defaultTransitionPage(
                    const AddWatchScreen(
                      accountFlow: AccountFlow.setup,
                    ),
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
                    const QrCodeScannerScreen(
                        accountFlow: AccountFlow.addNew,
                        scanMode: ScanMode.privateKey),
                    state);
              },
            ),
            GoRoute(
              name: mainPrivateKeyRouteName,
              path: mainPrivateKeyRouteName,
              pageBuilder: (context, state) {
                return defaultTransitionPage(
                    const ImportPrivateKeyScreen(
                      accountFlow: AccountFlow.addNew,
                    ),
                    state);
              },
            ),
            GoRoute(
              name: mainAddWatchAccountRouteName,
              path: mainAddWatchAccountRouteName,
              pageBuilder: (context, state) {
                return defaultTransitionPage(
                    const AddWatchScreen(
                      accountFlow: AccountFlow.addNew,
                    ),
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
              name: accountListRouteName,
              path: accountListRouteName,
              pageBuilder: (context, state) {
                return defaultTransitionPage(const AccountListScreen(), state);
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
              path: viewAssetRouteName,
              pageBuilder: (context, state) {
                return defaultTransitionPage(const ViewAssetScreen(), state);
              },
            ),
            GoRoute(
              name: viewNftRouteName,
              path: '$viewNftRouteName/:index',
              pageBuilder: (context, state) {
                final index =
                    int.tryParse(state.pathParameters['index'] ?? '0') ?? 0;
                return defaultTransitionPage(
                  ViewNftScreen(initialIndex: index),
                  state,
                );
              },
            ),
            GoRoute(
              name: viewTransactionRouteName,
              path: viewTransactionRouteName,
              pageBuilder: (context, state) {
                return defaultTransitionPage(
                    const ViewTransactionScreen(), state);
              },
            ),
            GoRoute(
              name: sendTransactionRouteName,
              path: '$sendTransactionRouteName/:mode',
              pageBuilder: (context, state) {
                final mode = state.pathParameters['mode'] == 'payment'
                    ? SendTransactionScreenMode.payment
                    : SendTransactionScreenMode.asset;
                final extra = state.extra as Map<String, dynamic>?;
                final address = extra?['address'] as String?;

                return defaultTransitionPage(
                  SendTransactionScreen(
                    mode: mode,
                    address: address,
                  ),
                  state,
                );
              },
              routes: [
                GoRoute(
                  name: sendTransactionQrScannerRouteName,
                  path: sendTransactionQrScannerRouteName,
                  pageBuilder: (context, state) {
                    final scanMode = state.extra as ScanMode;
                    return defaultTransitionPage(
                      QrCodeScannerScreen(scanMode: scanMode),
                      state,
                    );
                  },
                ),
              ],
            ),
            GoRoute(
              name: qrScannerRouteName,
              path: qrScannerRouteName,
              pageBuilder: (context, state) {
                final scanMode = state.extra as ScanMode;
                return defaultTransitionPage(
                  QrCodeScannerScreen(scanMode: scanMode),
                  state,
                );
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
                  routes: [
                    GoRoute(
                      name: exportAccountsRouteName,
                      path: exportAccountsRouteName,
                      pageBuilder: (context, state) {
                        return defaultTransitionPage(
                            const ExportAccountsScreen(), state);
                      },
                    ),
                    GoRoute(
                      name: pinPadChangePinRouteName,
                      path: pinPadChangePinRouteName,
                      pageBuilder: (context, state) {
                        return defaultTransitionPage(
                          const PinPadScreen(
                            mode: PinPadMode.changePin,
                          ),
                          state,
                        );
                      },
                    ),
                    GoRoute(
                      name: viewSeedPhraseRouteName,
                      path: viewSeedPhraseRouteName,
                      pageBuilder: (context, state) {
                        return defaultTransitionPage(
                          const CopySeedScreen(accountFlow: AccountFlow.view),
                          state,
                        );
                      },
                    ),
                  ],
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

  CustomTransitionPage<void> defaultTransitionPage(
    Widget child,
    GoRouterState state, {
    Duration duration = const Duration(milliseconds: 200),
  }) {
    return CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionsBuilder:
          (context, animation, secondaryAnimation, Widget child) {
        return AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            if (secondaryAnimation.value > 0) {
              return Opacity(
                opacity: 1 - secondaryAnimation.value,
                child: Container(
                  color: Colors.white,
                  child: child,
                ),
              );
            }
            return Opacity(
              opacity: animation.value,
              child: child,
            );
          },
          child: child,
        );
      },
      transitionDuration: duration,
    );
  }
}
