import 'package:flutter/material.dart';

class BadgeWidget extends StatelessWidget {
  final String value; // e.g., "open", "sold"
  final Map<String, dynamic> metadata; // For selection and decoration attrs

  const BadgeWidget({
    super.key,
    required this.value,
    required this.metadata,
  });

  // Get display text from selection options
  String _getDisplayText() {
    final selection = metadata['pythonAttributes']['selection'] as List<dynamic>?;
    if (selection != null) {
      for (var option in selection) {
        if (option[0].toString() == value) {
          return option[1].toString(); // e.g., "open" -> "Registered"
        }
      }
    }
    return value; // Fallback to raw value if no match
  }

  // Determine badge style based on decoration attributes
  (Color bgColor, Color textColor) _getBadgeStyle() {
    final xmlAttrs = metadata['xmlAttributes'] as List<dynamic>?;
    if (xmlAttrs == null) {
      return (Colors.grey[200]!, Colors.black); // Default
    }

    // Check decoration conditions
    if (_matchesDecoration(xmlAttrs, 'decoration-info', value)) {
      return (Colors.blue[100]!, Colors.blue[900]!); // Info style
    } else if (_matchesDecoration(xmlAttrs, 'decoration-success', value)) {
      return (Colors.green[100]!, Colors.green[900]!); // Success style
    } else if (_matchesDecoration(xmlAttrs, 'decoration-danger', value)) {
      return (Colors.red[100]!, Colors.red[900]!); // Danger style
    } else if (_matchesDecoration(xmlAttrs, 'decoration-muted', value)) {
      return (Colors.grey[300]!, Colors.grey[700]!); // Muted style
    }
    return (Colors.grey[200]!, Colors.black); // Default
  }

  bool _matchesDecoration(List<dynamic> attrs, String decoration, String value) {
    final attr = attrs.firstWhere(
          (a) => a['name'] == decoration,
      orElse: () => {'value': null},
    );
    final condition = attr['value'];
    if (condition == null) return false;

    // Simple condition parsing (e.g., "state == 'done'")
    if (condition.contains('==')) {
      final parts = condition.split('==').map((p) => p.trim()).toList();
      if (parts.length == 2) {
        final field = parts[0].trim();
        final expected = parts[1].trim().replaceAll("'", "");
        return field == 'state' && value == expected;
      }
    } else if (condition.contains('in')) {
      final parts = condition.split('in').map((p) => p.trim()).toList();
      if (parts.length == 2) {
        final field = parts[0].trim();
        final list = parts[1].trim().replaceAll('(', '').replaceAll(')', '').split(',').map((v) => v.trim().replaceAll("'", "")).toList();
        return field == 'state' && list.contains(value);
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final displayText = _getDisplayText();
    final (bgColor, textColor) = _getBadgeStyle();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: textColor.withOpacity(0.5)),
      ),
      child: Text(
        displayText,
        style: TextStyle(
          color: textColor,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}