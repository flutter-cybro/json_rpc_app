import 'package:flutter/material.dart';
import 'dart:convert'; // For base64 decoding

class Many2OneAvatarUserWidget extends StatelessWidget {
  final String name;
  final dynamic value; // The ID of the related record
  final String displayName; // The display name of the related record
  final String binaryData; // Base64 encoded image data
  final List<Map<String, dynamic>> options; // List of available options
  final String viewType; // 'tree' or 'form'
  final bool readonly; // Whether the widget is editable

  const Many2OneAvatarUserWidget({
    Key? key,
    required this.name,
    required this.value,
    required this.displayName,
    required this.binaryData,
    required this.options,
    required this.viewType,
    this.readonly = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Decode base64 image if available, otherwise use a default avatar
    Widget avatarWidget;
    if (binaryData.isNotEmpty) {
      try {
        final bytes = base64Decode(binaryData);
        avatarWidget = CircleAvatar(
          radius: viewType == 'tree' ? 20 : 30,
          backgroundImage: MemoryImage(bytes),
        );
      } catch (e) {
        // Fallback to default avatar if decoding fails
        avatarWidget = CircleAvatar(
          radius: viewType == 'tree' ? 20 : 30,
          child: Icon(
            Icons.person,
            size: viewType == 'tree' ? 24 : 36,
            color: theme.colorScheme.onSurface,
          ),
        );
      }
    } else {
      // Default avatar if no binary data
      avatarWidget = CircleAvatar(
        radius: viewType == 'tree' ? 20 : 30,
        child: Icon(
          Icons.person,
          size: viewType == 'tree' ? 24 : 36,
          color: theme.colorScheme.onSurface,
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        avatarWidget,
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            displayName.isNotEmpty ? displayName : '',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: viewType == 'tree' ? 14 : 16,
              color: theme.colorScheme.onSurface,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}