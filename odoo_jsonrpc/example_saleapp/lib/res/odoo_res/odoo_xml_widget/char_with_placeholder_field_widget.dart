import 'package:flutter/material.dart';

class CharWithPlaceholderFieldWidget extends StatelessWidget {
  final String name;
  final String value;
  final String? hintText;
  final bool readOnly;
  final String viewType;

  const CharWithPlaceholderFieldWidget({
    Key? key,
    required this.name,
    required this.value,
    this.hintText,
    this.readOnly = true,
    this.viewType = 'tree',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      value.isEmpty ? hintText ?? 'Enter $name' : value,
      style: TextStyle(
        fontSize: 16.0,
        color: value.isEmpty ? Colors.grey.shade500 : Colors.black87,
      ),
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
    );
  }
}