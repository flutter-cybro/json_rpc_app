import 'package:flutter/material.dart';

class ProgressBarWidget extends StatelessWidget {
  final double value; // e.g., 62.5 (percentage)

  const ProgressBarWidget({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    // Normalize value to 0.0-1.0 range (Odoo uses 0-100)
    final progress = (value / 100.0).clamp(0.0, 1.0);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            minHeight: 8, // Adjust height to fit cell
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '${value.toStringAsFixed(1)}%', // e.g., "62.5%"
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }
}