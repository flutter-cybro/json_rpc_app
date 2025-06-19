import 'package:flutter/material.dart';
import '../../../controller/odooclient_manager_controller.dart';

class Many2oneReferenceFieldWidget extends StatelessWidget {
  final String name;
  final dynamic value;
  final String displayName;
  final String relationModel;
  final List<Map<String, dynamic>> options;
  final String viewType;
  final bool readonly;
  final String hintText;
  final OdooClientController odooClientController;

  const Many2oneReferenceFieldWidget({
    Key? key,
    required this.name,
    required this.value,
    required this.displayName,
    required this.relationModel,
    required this.options,
    required this.viewType,
    required this.readonly,
    required this.hintText,
    required this.odooClientController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: readonly
          ? null
          : () {
        // Implement navigation or selection logic if not readonly
        // For tree view, this is typically disabled
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
        decoration: BoxDecoration(
          border: Border.all(
            color: theme.colorScheme.onSurface.withOpacity(0.2),
            width: 1.0,
          ),
          borderRadius: BorderRadius.circular(8.0),
          color: readonly
              ? theme.colorScheme.surfaceContainerLow
              : theme.colorScheme.surface,
        ),
        child: Text(
          displayName.isNotEmpty ? displayName : hintText,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: displayName.isNotEmpty
                ? theme.colorScheme.onSurface
                : theme.colorScheme.onSurface.withOpacity(0.6),
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}