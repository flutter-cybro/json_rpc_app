import 'package:example_saleapp/res/constants/app_colors.dart';
import 'package:flutter/material.dart';

class RotatingLoadingWidget extends StatefulWidget {
  @override
  _RotatingLoadingWidgetState createState() => _RotatingLoadingWidgetState();
}

class _RotatingLoadingWidgetState extends State<RotatingLoadingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: Center(
        child: CircularProgressIndicator(
          strokeWidth: 6.0,
          valueColor: AlwaysStoppedAnimation<Color>(ODOO_COLOR),
        ),
      ),
    );
  }
}
