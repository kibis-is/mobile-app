import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kibisis/features/add_asset/add_asset_screen.dart';
import 'package:kibisis/features/add_wallet/add_wallet_screen.dart';
import 'package:kibisis/features/dashboard/dashboard_screen.dart';
import 'package:kibisis/features/error/error_screen.dart';
import 'package:kibisis/features/setup_account/add_account/add_account_screen.dart';
import 'package:kibisis/features/setup_account/create_account/create_account_screen.dart';
import 'package:kibisis/features/setup_account/create_pin/create_pin_screen.dart';
import 'package:kibisis/features/send_voi/send_voi_screen.dart';
import 'package:kibisis/features/setup_account/import_via_seed/import_account_via_seed_screen.dart';
import 'package:kibisis/providers/login_controller_provider.dart';
import 'package:kibisis/providers/states/login_states.dart';
import 'package:kibisis/routing/named_routes.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final router = RouterNotifier(ref);
  return GoRouter(
    refreshListenable: router,
    routes: router._routes,
    redirect: router._redirectLogic,
    initialLocation: '/$createPinRouteName',
    errorPageBuilder: (context, state) => const MaterialPage(
      child: ErrorScreen(),
    ),
  );
});

class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterNotifier(this._ref) {
    _ref.listen<LoginState>(
      loginControllerProvider,
      (_, __) => notifyListeners(),
    );
  }

  // Future<String?> _redirectLogic(BuildContext context, GoRouterState state) {
  //   final loginState = _ref.read(loginControllerProvider);

  //   if (loginState is LoginStateSuccess) return Future.value('/');

  //   if (loginState is LoginStateInitial) {
  //     return Future.value('/$loginRouteName');
  //   }
  //   return Future.value(null);
  // }

  Future<String?> _redirectLogic(BuildContext context, GoRouterState state) {
    final loginState = _ref.read(loginControllerProvider);
    List<String> validLoggedOutLocations = [
      '/setup/createPin',
      '/setup/addAccount',
      '/setup/createAccount',
      '/setup/importAccountViaSeed',
    ];
    List<String> validLoggedInLocations = [
      '/',
      '/sendVOI',
      '/addAsset',
      '/addWallet',
      '/addNetwork',
      '/settings',
    ];

    if (loginState is LoginStateSuccess) {
      if (validLoggedInLocations.contains(state.uri.toString())) {
        return Future.value(null);
      } else {
        return Future.value('/');
      }
    }
    if (loginState is LoginStateInitial) {
      if (validLoggedOutLocations.contains(state.uri.toString())) {
        return Future.value(null);
      } else {
        return Future.value('/setup/createPin');
      }
    }
    return Future.value(null);
  }

  List<GoRoute> get _routes => [
        GoRoute(
          name: createPinRouteName,
          path: '/$createPinRouteName',
          // builder: (context, state) => CreatePinScreen(key: state.pageKey),
          pageBuilder: (context, state) {
            return defaultTransitionPage(const CreatePinScreen(), state);
          },
        ),
        GoRoute(
          name: addAccountRouteName,
          path: '/$addAccountRouteName',
          pageBuilder: (context, state) {
            return defaultTransitionPage(const AddAccountScreen(), state);
          },
        ),
        GoRoute(
          name: createAccountRouteName,
          path: '/$createAccountRouteName',
          pageBuilder: (context, state) {
            return defaultTransitionPage(const CreateAccountScreen(), state);
          },
        ),
        GoRoute(
          name: importAccountViaSeedRouteName,
          path: '/$importAccountViaSeedRouteName',
          pageBuilder: (context, state) {
            return defaultTransitionPage(
                const ImportAccountViaSeedScreen(), state);
          },
        ),
        GoRoute(
          path: '/',
          name: rootRouteName,
          pageBuilder: (context, state) {
            return defaultTransitionPage(const Dashboard(), state);
          },
          routes: [
            GoRoute(
              name: addAssetRouteName,
              path: addAssetRouteName,
              pageBuilder: (context, state) {
                return defaultTransitionPage(AddAsset(), state);
              },
            ),
            GoRoute(
              name: addWalletRouteName,
              path: addWalletRouteName,
              pageBuilder: (context, state) {
                return defaultTransitionPage(AddWallet(), state);
              },
            ),
            GoRoute(
              name: sendVOIRouteName,
              path: sendVOIRouteName,
              pageBuilder: (context, state) {
                return defaultTransitionPage(const SendVOI(), state);
              },
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
