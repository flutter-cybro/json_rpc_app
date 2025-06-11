// File: lib/res/odoo_res/odoo_data_types/timesheet_uom_timer_widget.dart

import 'package:flutter/material.dart';

class TimesheetUomTimerWidget extends StatelessWidget {
  final String name;
  final double value;
  final String viewType;

  const TimesheetUomTimerWidget({
    Key? key,
    required this.name,
    required this.value,
    required this.viewType,
  }) : super(key: key);

  // Format the float value into a readable time format (e.g., 2.5 -> "2h 30m")
  String _formatTime(double hours) {
    if (hours == 0) return '0h 0m';
    final int totalMinutes = (hours * 60).round();
    final int h = totalMinutes ~/ 60;
    final int m = totalMinutes % 60;
    String result = '';
    if (h > 0) result += '${h}h';
    if (m > 0) result += (h > 0 ? ' ' : '') + '${m}m';
    return result.isEmpty ? '0h 0m' : result;
  }

  @override
  Widget build(BuildContext context) {
    // For tree view, display as a simple text widget
    if (viewType == 'tree') {
      return Text(
        _formatTime(value),
        style: const TextStyle(
          fontSize: 16.0,
          color: Colors.black87,
        ),
        overflow: TextOverflow.ellipsis,
      );
    }

    // Placeholder for other view types (e.g., form view, if needed)
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        _formatTime(value),
        style: const TextStyle(
          fontSize: 16.0,
          color: Colors.black87,
        ),
      ),
    );
  }
}