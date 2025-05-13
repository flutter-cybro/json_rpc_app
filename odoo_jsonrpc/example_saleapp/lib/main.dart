import 'package:example_saleapp/services/isar_service.dart';
import 'package:example_saleapp/services/local_auth.dart';
import 'package:example_saleapp/screen_handler/Linux_homescreen.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'controller/odooclient_manager_controller.dart';
import 'models/local_nodel/one2many_data.dart';
import 'pages/homescreen.dart';
import 'pages/profileview.dart';

void main() async {
  await _setup();
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      primarySwatch: Colors.purple,
      secondaryHeaderColor: Colors.white,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    ),
    home: AuthGate(),
    routes: {
      '/home': (context) => HomeScreen(),
      '/linux_home': (context) => LinuxHomeScreen(),
      // '/login': (context) => LoginScreen(),
      '/profile': (context) => ProfileView(),
    },
  ));
}

Future<void> _setup() async {
  WidgetsFlutterBinding.ensureInitialized();
  await IsarService.getInstance();
}