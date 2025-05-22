import 'package:flutter/material.dart';

class RemainingDaysWidget extends StatelessWidget {
  final num value; // The number of remaining days (integer or float)
  final String fieldLabel; // The label for accessibility and tooltips

  const RemainingDaysWidget({
    super.key,
    required this.value,
    required this.fieldLabel,
  });

  @override
  Widget build(BuildContext context) {
    // Access theme for consistent styling
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // Responsive sizing based on screen width
    final screenWidth = MediaQuery.of(context).size.width;
    final fontSize = screenWidth < 360 ? 14.0 : 16.0; // Adjust font size
    final padding = screenWidth < 360 ? 2.0 : 4.0; // Adjust spacing

    // Determine color based on value
    Color textColor;
    String tooltipMessage;

    if (value < 0) {
      textColor = isDarkMode ? Colors.red[300]! : Colors.red[700]!;
      tooltipMessage = 'Overdue: ${value.abs()} days';
    } else if (value <= 3) {
      textColor = isDarkMode ? Colors.orange[300]! : Colors.orange[700]!;
      tooltipMessage = 'Due soon: $value days remaining';
    } else {
      textColor = isDarkMode ? Colors.green[300]! : Colors.green[700]!;
      tooltipMessage = 'Due in: $value days';
    }

    // Format the value (e.g., "5 days" or "-2 days")
    final displayText = '$value ${value == 1 ? 'day' : 'days'}';

    return Tooltip(
      message: tooltipMessage,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: padding, vertical: 2.0),
        constraints: const BoxConstraints(
          minWidth: 60.0, // Ensure minimum width for small screens
          maxWidth: 120.0, // Prevent excessive stretching
        ),
        child: Text(
          displayText,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: textColor,
            fontSize: fontSize,
            fontWeight: FontWeight.w500,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ),
    );
  }
}