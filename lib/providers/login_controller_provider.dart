import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/providers/states/login_states.dart';
import 'package:kibisis/repository/auth_repository.dart';

class LoginController extends StateNotifier<LoginState> {
  LoginController(this.ref) : super(const LoginStateInitial());

  final Ref ref;

  void login(String email, String password) async {
    state = const LoginStateLoading();

    try {
      await ref.read(authRepositoryProvider).login(email, password);
      state = const LoginStateSuccess();
    } catch (e) {
      state = LoginStateError(e.toString());
    }
  }

  void logout() {
    state = const LoginStateInitial();
  }
}

final loginControllerProvider =
    StateNotifierProvider<LoginController, LoginState>((ref) {
  return LoginController(ref);
});
