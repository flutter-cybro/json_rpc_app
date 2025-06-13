import 'package:flutter/material.dart';

/// A customizable progress bar widget with animated progress and optional percentage display.
class ProgressBarWidget extends StatelessWidget {
  /// The progress value (0-100 scale, e.g., 62.5 for 62.5%).
  final double value;

  /// Whether to show the percentage text next to the progress bar.
  final bool showPercentage;

  /// The height of the progress bar.
  final double height;

  /// The border radius for rounded corners.
  final double borderRadius;

  /// Custom colors for the progress bar (foreground and background).
  final ProgressBarColors? customColors;

  const ProgressBarWidget({
    super.key,
    required this.value,
    this.showPercentage = true,
    this.height = 8.0,
    this.borderRadius = 4.0,
    this.customColors,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final normalizedProgress = (value / 100.0).clamp(0.0, 1.0);
    final colors = customColors ??
        ProgressBarColors(
          progress: theme.colorScheme.primary,
          background: theme.colorScheme.surfaceContainer,
        );

    return Semantics(
      label: 'Progress: ${value.toStringAsFixed(1)} percent',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: height,
              decoration: BoxDecoration(
                color: colors.background,
                borderRadius: BorderRadius.circular(borderRadius),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(borderRadius),
                child: LinearProgressIndicator(
                  value: normalizedProgress,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(colors.progress),
                  minHeight: height,
                ),
              ),
            ),
          ),
          if (showPercentage) ...[
            const SizedBox(width: 8),
            Text(
              '${value.toStringAsFixed(1)}%',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Defines custom colors for the progress bar.
class ProgressBarColors {
  final Color progress;
  final Color background;

  const ProgressBarColors({
    required this.progress,
    required this.background,
  });
}