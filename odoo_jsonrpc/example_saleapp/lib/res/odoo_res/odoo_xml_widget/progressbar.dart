// import 'package:flutter/material.dart';
//
// /// A customizable progress bar widget with animated progress and optional percentage display.
// class ProgressBarWidget extends StatelessWidget {
//   /// The progress value (0-100 scale, e.g., 62.5 for 62.5%).
//   final double value;
//
//   /// Whether to show the percentage text next to the progress bar.
//   final bool showPercentage;
//
//   /// The height of the progress bar.
//   final double height;
//
//   /// The border radius for rounded corners.
//   final double borderRadius;
//
//   /// Custom colors for the progress bar (foreground and background).
//   final ProgressBarColors? customColors;
//
//   const ProgressBarWidget({
//     super.key,
//     required this.value,
//     this.showPercentage = true,
//     this.height = 8.0,
//     this.borderRadius = 4.0,
//     this.customColors,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final normalizedProgress = (value / 100.0).clamp(0.0, 1.0);
//     final colors = customColors ??
//         ProgressBarColors(
//           progress: theme.colorScheme.primary,
//           background: theme.colorScheme.surfaceContainer,
//         );
//
//     return Semantics(
//       label: 'Progress: ${value.toStringAsFixed(1)} percent',
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Expanded(
//             child: AnimatedContainer(
//               duration: const Duration(milliseconds: 300),
//               height: height,
//               decoration: BoxDecoration(
//                 color: colors.background,
//                 borderRadius: BorderRadius.circular(borderRadius),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.1),
//                     blurRadius: 2,
//                     offset: const Offset(0, 1),
//                   ),
//                 ],
//               ),
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(borderRadius),
//                 child: LinearProgressIndicator(
//                   value: normalizedProgress,
//                   backgroundColor: Colors.transparent,
//                   valueColor: AlwaysStoppedAnimation<Color>(colors.progress),
//                   minHeight: height,
//                 ),
//               ),
//             ),
//           ),
//           if (showPercentage) ...[
//             const SizedBox(width: 8),
//             Text(
//               '${value.toStringAsFixed(1)}%',
//               style: theme.textTheme.bodyMedium?.copyWith(
//                 color: theme.colorScheme.onSurface,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ],
//         ],
//       ),
//     );
//   }
// }
//
// /// Defines custom colors for the progress bar.
// class ProgressBarColors {
//   final Color progress;
//   final Color background;
//
//   const ProgressBarColors({
//     required this.progress,
//     required this.background,
//   });
// }






// import 'package:flutter/material.dart';
//
// class ProgressBarWidget extends StatelessWidget {
//   final double value; // e.g., 62.5 (percentage)
//
//   const ProgressBarWidget({super.key, required this.value});
//
//   @override
//   Widget build(BuildContext context) {
//     // Normalize value to 0.0-1.0 range (Odoo uses 0-100)
//     final progress = (value / 100.0).clamp(0.0, 1.0);
//
//     return Row(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Expanded(
//           child: LinearProgressIndicator(
//             value: progress,
//             backgroundColor: Colors.grey[300],
//             valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
//             minHeight: 8, // Adjust height to fit cell
//           ),
//         ),
//         const SizedBox(width: 8),
//         Text(
//           '${value.toStringAsFixed(1)}%', // e.g., "62.5%"
//           style: const TextStyle(fontSize: 16),
//         ),
//       ],
//     );
//   }
// }
import 'package:flutter/material.dart';

class ProgressBarWidget extends StatelessWidget {
  final double value; // Progress value, typically 0-100 for Odoo
  final String? fieldLabel; // Optional label for accessibility or display
  final bool readonly; // Controls interactivity, default true for tree view

  const ProgressBarWidget({
    super.key,
    required this.value,
    this.fieldLabel,
    this.readonly = true,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (value / 100.0).clamp(0.0, 1.0);
    final theme = Theme.of(context);

    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 36, maxWidth: 100), // Adjusted height for vertical layout
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 100, // Fixed width for progress bar
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: theme.colorScheme.surfaceContainerHigh,
              valueColor: AlwaysStoppedAnimation<Color>(
                readonly
                    ? theme.colorScheme.primary
                    : theme.colorScheme.primary.withOpacity(0.7),
              ),
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 4), // Space between progress bar and text
          Text(
            '${value.toStringAsFixed(1)}%',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface,
              fontSize: 14,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}