import 'package:flutter/material.dart';

class FloatFieldWidget extends StatelessWidget {
  final String name;
  final double value;
  final bool readOnly; // Read-only flag (no effect as widget is display-only)

  const FloatFieldWidget({
    required this.name,
    required this.value,
    this.readOnly = false, // Default to false
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4), // Reduced height to minimize space
          Text(
            value.toStringAsFixed(2), // Display float with 2 decimal places
            style: const TextStyle(
              fontSize: 16.0,
              color: Colors.black87,
            ),
            overflow: TextOverflow.ellipsis, // Handle long text
          ),
        ],
      ),
    );
  }
}