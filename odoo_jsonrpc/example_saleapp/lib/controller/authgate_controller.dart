import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';

import '../res/constants/const.dart';

class AuthGateController {
  final LocalAuthentication auth = LocalAuthentication();
  bool? isLoggedIn;
  bool? useLocalAuth;
  bool isAuthenticating = false;

  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    useLocalAuth = prefs.getBool('useLocalAuth') ?? false;
  }

  Future<AuthenticationResult> authenticateWithBiometrics() async {
    if (isAuthenticating) return AuthenticationResult.error;

    isAuthenticating = true;

    try {
      bool canCheckBiometrics = await auth.canCheckBiometrics;
      List<BiometricType> availableBiometrics = await auth.getAvailableBiometrics();

      if (canCheckBiometrics && availableBiometrics.isNotEmpty) {
        try {
          final authenticate = await auth.authenticate(
            localizedReason: 'Authenticate to access the app',
            options: const AuthenticationOptions(
              stickyAuth: true,
              biometricOnly: true,
            ),
          );

          isAuthenticating = false;

          if (authenticate) {
            return AuthenticationResult.success;
          } else {
            return AuthenticationResult.failure;
          }
        } catch (authError) {
          isAuthenticating = false;
          return AuthenticationResult.error;
        }
      } else {
        isAuthenticating = false;
        return AuthenticationResult.unavailable;
      }
    } catch (e) {
      isAuthenticating = false;
      return AuthenticationResult.error;
    }
  }

  Future<void> updateLoginStatus(bool status) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', status);
    isLoggedIn = status;
  }

  void stopAuthentication() {
    auth.stopAuthentication();
  }
}
