// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:kibisis/providers/authentication_provider.dart';
// import 'package:kibisis/providers/setup_complete_provider.dart';
// import 'package:kibisis/providers/storage_provider.dart';


// class AppState {
//   final bool isSetupComplete;
//   final bool isAuthenticated;
//   final bool hasAccount;

//   AppState({
//     required this.isSetupComplete,
//     required this.isAuthenticated,
//     required this.hasAccount,
//   });
// }

// class AppStateNotifier extends StateNotifier<AppState> {
//   AppStateNotifier(Ref ref)
//       : super(AppState(
//           isSetupComplete: false,
//           isAuthenticated: false,
//           hasAccount: false,
//         )) {
//     _initialize(ref);
//   }

//   Future<void> _initialize(Ref ref) async {
//     final storageService = ref.read(storageProvider);

//     final isSetupComplete = ref.read(setupCompleteProvider);
//     final isAuthenticated = ref.read(isAuthenticatedProvider);
//     final hasAccount = await storageService.accountExists();

//     state = AppState(
//       isSetupComplete: isSetupComplete,
//       isAuthenticated: isAuthenticated,
//       hasAccount: hasAccount,
//     );
//   }

//   Future<void> refreshState(Ref ref) async {
//     final storageService = ref.read(storageProvider);

//     final isSetupComplete = ref.read(setupCompleteProvider);
//     final isAuthenticated = ref.read(isAuthenticatedProvider);
//     final hasAccount = await storageService.accountExists();

//     state = AppState(
//       isSetupComplete: isSetupComplete,
//       isAuthenticated: isAuthenticated,
//       hasAccount: hasAccount,
//     );
//   }

//   AppRoute getRoutingState() {
//     if (!state.hasAccount && !state.isSetupComplete) {
//       return AppRoute.setup;
//     } else if (state.hasAccount && !state.isAuthenticated) {
//       return AppRoute.pinPadUnlock;
//     } else if (state.hasAccount && state.isAuthenticated) {
//       return AppRoute.home;
//     }
//     return AppRoute.none;
//   }
// }

// final appStateProvider =
//     StateNotifierProvider<AppStateNotifier, AppState>((ref) {
//   return AppStateNotifier(ref);
// });
