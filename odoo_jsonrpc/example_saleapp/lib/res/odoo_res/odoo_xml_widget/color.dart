import 'package:flutter/material.dart';

class ColorFieldWidget extends StatelessWidget {
  final String value; // e.g., "#3C3C3C"
  final bool readonly; // Controls interactivity and UI
  final VoidCallback? onTap; // Optional callback for tap action

  const ColorFieldWidget({
    super.key,
    required this.value,
    this.readonly = false, // Default to non-readonly
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Parse color with fallback
    Color color;
    try {
      color = Color(int.parse(value.replaceFirst('#', '0xff')));
    } catch (e) {
      color = Colors.grey; // Fallback for invalid hex
    }

    // Visual adjustments for readonly state
    final effectiveOpacity = readonly ? 0.6 : 1.0;
    final borderColor = readonly ? Colors.black26 : Colors.black54;

    return InkWell(
      onTap: readonly ? null : onTap, // Disable tap if readonly
      borderRadius: BorderRadius.circular(4.0), // Subtle rounded ripple
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: color.withOpacity(effectiveOpacity),
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.circular(4.0), // Slightly rounded corners
        ),
      ),
    );
  }
}