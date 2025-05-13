import 'package:flutter/material.dart';

import '../pages/homescreen.dart';
import 'Linux_homescreen.dart';

class ScreenHandler extends StatelessWidget {
  const ScreenHandler({super.key});

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    double phoneWidthThreshold = 600;

    if (size.width > phoneWidthThreshold) {
      return LinuxHomeScreen();
    } else {
      return HomeScreen();
    }
  }
}
