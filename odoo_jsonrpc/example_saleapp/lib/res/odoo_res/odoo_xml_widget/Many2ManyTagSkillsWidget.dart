import 'package:flutter/material.dart';
import '../../constants/app_colors.dart'; // Import for ODOO_COLOR or other app-specific colors

class Many2ManyTagSkillsWidget extends StatelessWidget {
  final String name; // Field name
  final List<dynamic> values; // List of IDs for the many2many field
  final List<Map<String, dynamic>> options; // List of available options with id and name
  final Function(List<dynamic>)? onValuesChanged; // Callback for changes
  final bool readonly; // Whether the widget is read-only
  final String viewType; // View type ('tree' or 'form')

  const Many2ManyTagSkillsWidget({
    Key? key,
    required this.name,
    required this.values,
    required this.options,
    this.onValuesChanged,
    this.readonly = true,
    this.viewType = 'tree',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get theme for consistent styling
    final theme = Theme.of(context);

    // Map values to display names
    final displayTags = options
        .where((option) => values.contains(option['id']))
        .map((option) => option['name']?.toString() ?? 'Unnamed')
        .toList();

    if (displayTags.isEmpty) {
      return Text(
        'No skills assigned',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurface.withOpacity(0.6),
        ),
      );
    }

    return Wrap(
      spacing: 8.0, // Horizontal spacing between tags
      runSpacing: 4.0, // Vertical spacing between rows
      children: displayTags.map((tag) {
        return Chip(
          label: Text(
            tag,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          backgroundColor: ODOO_COLOR, // Use app-specific color
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          // If not readonly, allow deletion of tags
          onDeleted: readonly || viewType == 'tree'
              ? null
              : () {
            final tagId = options
                .firstWhere((option) => option['name'] == tag)['id'];
            final updatedValues = List<dynamic>.from(values)
              ..remove(tagId);
            onValuesChanged?.call(updatedValues);
          },
        );
      }).toList(),
    );
  }
}