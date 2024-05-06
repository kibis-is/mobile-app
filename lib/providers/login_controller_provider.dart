// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:kibisis/providers/states/login_states.dart';
// import 'package:kibisis/repository/auth_repository.dart';
// import 'package:kibisis/utils/login_validator.dart';

// class LoginController extends StateNotifier<LoginState> {
//   LoginController(this.ref) : super(const LoginStateInitial());

//   final Ref ref;

//   void login(String pin, String accountName, String mnemonic) async {
//     state = const LoginStateLoading();

//     // Validate the pin
//     String? pinError = LoginValidator.validatePin(pin);
//     if (pinError != null) {
//       state = LoginStateError(pinError);
//       return;
//     }

//     // Validate the account name
//     String? accountNameError = LoginValidator.validateAccountName(accountName);
//     if (accountNameError != null) {
//       state = LoginStateError(accountNameError);
//       return;
//     }

//     // Validate the mnemonic
//     String? mnemonicError = LoginValidator.validateMnemonic(mnemonic);
//     if (mnemonicError != null) {
//       state = LoginStateError(mnemonicError);
//       return;
//     }

//     // Proceed with the login if all validations pass
//     try {
//       await ref.read(authRepositoryProvider).login(pin);
//       state = const LoginStateSuccess();
//     } catch (e) {
//       state = LoginStateError(e.toString());
//     }
//   }

//   void logout() {
//     state = const LoginStateInitial();
//   }
// }

// final loginControllerProvider =
//     StateNotifierProvider<LoginController, LoginState>((ref) {
//   return LoginController(ref);
// });
