import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();

  /// Check if biometrics (fingerprint or face) are available and usable
  Future<bool> canCheckFingerprint() async {
    try {
      final availableBiometrics = await _auth.getAvailableBiometrics();
      return availableBiometrics.contains(BiometricType.strong);
    } catch (e) {
      debugPrint('Error checking biometrics availability: $e');
      return false;
    }
  }

  /// Authenticate the user using biometrics
  Future<bool> authenticateWithFingerprint() async {
    try {
      return await _auth.authenticate(
        localizedReason: 'Authenticate to continue',
        options:
            const AuthenticationOptions(biometricOnly: true, stickyAuth: true),
      );
    } on PlatformException catch (e) {
      debugPrint('Biometric authentication error: $e');
      return false;
    }
  }
}
