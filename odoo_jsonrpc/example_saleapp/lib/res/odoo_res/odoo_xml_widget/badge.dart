import 'package:flutter/material.dart';

class BadgeWidget extends StatelessWidget {
  final String value; // The display value, e.g., "Done", "Error", "In Progress"
  final String fieldLabel; // The label for accessibility and tooltips
  final VoidCallback? onTap; // Optional tap callback for interactivity

  const BadgeWidget({
    super.key,
    required this.value,
    required this.fieldLabel,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Access theme for consistent styling
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // Responsive sizing based on screen width
    final screenWidth = MediaQuery.of(context).size.width;
    final fontSize = screenWidth < 360 ? 12.0 : 14.0; // Smaller font for narrow screens
    final padding = screenWidth < 360 ? 4.0 : 6.0; // Adjust padding

    // Determine background and text color based on value
    Color backgroundColor;
    Color textColor;
    String tooltipMessage = '$fieldLabel: $value';

    switch (value.toLowerCase()) {
      case 'done':
      case 'completed':
        backgroundColor = isDarkMode ? Colors.green[800]! : Colors.green[100]!;
        textColor = isDarkMode ? Colors.white : Colors.green[900]!;
        break;
      case 'error':
      case 'failed':
        backgroundColor = isDarkMode ? Colors.red[800]! : Colors.red[100]!;
        textColor = isDarkMode ? Colors.white : Colors.red[900]!;
        break;
      case 'in progress':
      case 'pending':
        backgroundColor = isDarkMode ? Colors.blue[800]! : Colors.blue[100]!;
        textColor = isDarkMode ? Colors.white : Colors.blue[900]!;
        break;
      default:
        backgroundColor = isDarkMode ? Colors.grey[700]! : Colors.grey[200]!;
        textColor = isDarkMode ? Colors.white : Colors.grey[800]!;
        break;
    }

    return Tooltip(
      message: tooltipMessage,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.0),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: padding * 2, vertical: padding),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(
              color: textColor.withOpacity(0.5),
              width: 1.0,
            ),
          ),
          constraints: BoxConstraints(
            minWidth: 60.0, // Ensure minimum width
            maxWidth: screenWidth < 360 ? 100.0 : 120.0, // Responsive max width
          ),
          child: Text(
            value.isEmpty ? 'N/A' : value,
            style: theme.textTheme.bodySmall?.copyWith(
              color: textColor,
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ),
    );
  }
}