import 'package:flutter/material.dart';

SnackBar _buildSnackBar({
  required String message,
  Duration duration = const Duration(seconds: 3),
  Color backgroundColor = Colors.grey,
  TextStyle textStyle = const TextStyle(color: Colors.white),
  SnackBarAction? action,
}) {
  return SnackBar(
    content: Text(
      message,
      style: textStyle,
    ),
    duration: duration,
    backgroundColor: backgroundColor,
    action: action,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8.0),
    ),
  );
}