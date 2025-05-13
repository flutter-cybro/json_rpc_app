import 'package:flutter/material.dart';

import '../controller/authgate_controller.dart';
import '../res/constants/const.dart';
import '../screen_handler/screen_handler.dart';
import '../pages/login.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({Key? key}) : super(key: key);

  @override
  _AuthGateState createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late final AuthGateController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AuthGateController();
    _controller.checkLoginStatus().then((_) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_controller.isLoggedIn == null || _controller.useLocalAuth == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_controller.isLoggedIn!) {
      if (_controller.useLocalAuth!) {
        return FutureBuilder<AuthenticationResult>(
          future: _controller.authenticateWithBiometrics(),
          builder: (context, authSnapshot) {
            if (authSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            } else {
              switch (authSnapshot.data) {
                case AuthenticationResult.success:
                  return const ScreenHandler();
                case AuthenticationResult.failure:
                  return const Login();
                case AuthenticationResult.error:
                  return const Login();
                case AuthenticationResult.unavailable:
                  return const ScreenHandler();
                default:
                  return const Login();
              }
            }
          },
        );
      } else {
        return const ScreenHandler();
      }
    } else {
      return const Login();
    }
  }
}
