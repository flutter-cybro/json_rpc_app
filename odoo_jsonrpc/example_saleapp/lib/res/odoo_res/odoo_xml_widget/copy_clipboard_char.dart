import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../constants/app_colors.dart';

class CopyClipboardChar extends StatelessWidget {
  final String name;
  final String value;
  final bool readonly;
  final String viewType;

  const CopyClipboardChar({
    Key? key,
    required this.name,
    required this.value,
    required this.readonly,
    required this.viewType,
  }) : super(key: key);

  void _copyToClipboard(BuildContext context) {
    if (value.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: value));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$name copied to clipboard'),
          duration: const Duration(seconds: 2),
          backgroundColor: ODOO_COLOR,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No text to copy'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min, // Use min to avoid taking infinite width
      children: [
        Flexible(
          fit: FlexFit.loose, // Allow text to take only the space it needs
          child: Text(
            value.isEmpty ? '--' : value,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: value.isEmpty
                  ? theme.colorScheme.onSurface.withOpacity(0.6)
                  : theme.colorScheme.onSurface,
              fontSize: 16.0,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (!readonly && viewType == 'tree')
          IconButton(
            icon: Icon(
              Icons.copy,
              color: ODOO_COLOR,
              size: 20.0,
            ),
            onPressed: () => _copyToClipboard(context),
            tooltip: 'Copy $name to clipboard',
          ),
      ],
    );
  }
}