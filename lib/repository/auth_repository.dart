import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kibisis/utils/auth_service.dart';

class AuthRepository {
  final AuthService _authService;
  AuthRepository(this._authService);

  Future<String> login(String pin) async {
    return _authService.login(pin);
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.read(authServiceProvider));
});
