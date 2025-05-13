import 'package:flutter/material.dart';

class ClassColorMapper {
  static Map<String, Color> classColors = {
    'oe_highlight': Colors.grey[200] ?? Colors.grey,
    'default': Colors.white,
    'btn-primary': Color(0xFF7D3C98),
    'btn-secondary': Colors.grey[300] ?? Colors.grey,
    'object': Colors.white,
  };

  static Color getColor(String className) {
    return classColors[className] ?? Colors.black;
  }

}