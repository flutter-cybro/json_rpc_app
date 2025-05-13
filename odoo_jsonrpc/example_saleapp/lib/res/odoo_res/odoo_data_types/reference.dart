import 'package:flutter/material.dart';

class ReferenceFieldWidget extends StatelessWidget {
  final String value;
  final VoidCallback? onTap;

  const ReferenceFieldWidget({
    super.key,
    required this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        value,
        style: const TextStyle(
          fontSize: 16.0,
          color: Colors.blue,
          decoration: TextDecoration.underline,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}