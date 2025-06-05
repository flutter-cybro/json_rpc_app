import 'package:flutter/material.dart';

class BooleanFavoriteWidget extends StatelessWidget {
  final bool isFavorite; // Indicates favorite status
  final bool readonly; // Controls interactivity and UI
  final VoidCallback? onTap; // Optional callback for tap action

  const BooleanFavoriteWidget({
    super.key,
    required this.isFavorite,
    this.readonly = false, // Default to non-readonly
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Access theme for consistent styling
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // Visual adjustments for readonly state
    final effectiveOpacity = readonly ? 0.6 : 1.0;
    final iconColor = isFavorite
        ? Colors.yellow[700]!.withOpacity(effectiveOpacity)
        : (isDarkMode ? Colors.grey[400]! : Colors.grey[600]!).withOpacity(effectiveOpacity);

    return InkWell(
      onTap: readonly ? null : onTap, // Disable tap if readonly
      borderRadius: BorderRadius.circular(12.0), // Rounded ripple effect
      child: Padding(
        padding: const EdgeInsets.all(4.0), // Small padding for tap area
        child: Icon(
          isFavorite ? Icons.star : Icons.star_border,
          color: iconColor,
          size: 24.0,
        ),
      ),
    );
  }
}