import 'package:flutter/material.dart';

class PriorityWidget extends StatelessWidget {
  final String value; // The display value, e.g., "Normal" or "Urgent"
  final List<dynamic> selection; // The selection options, e.g., [[0, "Normal"], [1, "Urgent"]]
  final VoidCallback? onTap; // Optional tap callback for interactivity

  const PriorityWidget({
    super.key,
    required this.value,
    required this.selection,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Access theme for consistent styling
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;


    final screenWidth = MediaQuery.of(context).size.width;
    final iconSize = screenWidth < 360 ? 14.0 : 16.0; // Smaller icons on narrow screens
    final fontSize = screenWidth < 360 ? 14.0 : 16.0; // Adjust font size
    final padding = screenWidth < 360 ? 2.0 : 4.0; // Adjust spacing


    IconData? icon;
    Color textColor;
    String tooltipMessage;

    switch (value) {
      case 'Urgent':
        icon = Icons.star;
        textColor = isDarkMode ? Colors.yellow[200]! : Colors.yellow[700]!;
        tooltipMessage = 'Urgent Priority';
        break;
      case 'Normal':
        icon = Icons.star_border;
        textColor = isDarkMode ? Colors.grey[400]! : Colors.grey[600]!;
        tooltipMessage = 'Normal Priority';
        break;
      default:
        icon = Icons.help_outline;
        textColor = isDarkMode ? Colors.grey[500]! : Colors.grey[700]!;
        tooltipMessage = 'Unknown Priority';
        break;
    }

    // Build the widget with hover and tap feedback
    return Tooltip(
      message: tooltipMessage,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4.0),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: padding, vertical: 2.0),
          constraints: const BoxConstraints(
            minWidth: 60.0, // Ensure minimum width for small screens
            maxWidth: 120.0, // Prevent excessive stretching
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  color: textColor,
                  size: iconSize,
                ),
                SizedBox(width: padding),
              ],
              // Flexible(
              //   child: Text(
              //     value.isEmpty ? 'N/A' : value,
              //     style: theme.textTheme.bodyMedium?.copyWith(
              //       color: textColor,
              //       fontSize: fontSize,
              //       fontWeight: FontWeight.w500,
              //     ),
              //     overflow: TextOverflow.ellipsis,
              //     maxLines: 1,
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}