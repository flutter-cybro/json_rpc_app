import 'package:flutter/material.dart';

class ColorFieldWidget extends StatelessWidget {
  final String value; // e.g., "#3C3C3C"

  const ColorFieldWidget({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    Color color;
    try {
      color = Color(int.parse(value.replaceFirst('#', '0xff')));
    } catch (e) {
      color = Colors.grey; // Fallback for invalid hex
    }

    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: Colors.black54),
      ),
    );
  }
}