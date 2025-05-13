import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class StatinfoWidget extends StatelessWidget {
  final String name;
  final dynamic value;
  final String? icon;
  final Color? color;

  const StatinfoWidget({
    Key? key,
    required this.name,
    required this.value,
    this.icon,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (icon != null)
              Icon(
                _getIconData(icon!),
                size: 24,
                color: color ?? Colors.blue,
              ),
            if (icon != null) const SizedBox(height: 8),
            Text(
              value?.toString() ?? 'N/A',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey[800],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              name,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper function to map FontAwesome icons
  IconData _getIconData(String icon) {
    switch (icon) {
      case 'fa-truck':
        return FontAwesomeIcons.truck;
      case 'fa-box':
        return FontAwesomeIcons.box;
      case 'fa-chart-line':
        return FontAwesomeIcons.chartLine;
      default:
        return FontAwesomeIcons.infoCircle;
    }
  }
}