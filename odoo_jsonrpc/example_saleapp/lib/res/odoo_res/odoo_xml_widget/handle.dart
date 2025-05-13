import 'package:flutter/material.dart';

class HandleWidget extends StatelessWidget {
  final int sequence;

  const HandleWidget({super.key, required this.sequence});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.drag_handle, size: 24, color: Colors.grey),
        SizedBox(width: 4),
        Text(sequence.toString()),
      ],
    );
  }
}