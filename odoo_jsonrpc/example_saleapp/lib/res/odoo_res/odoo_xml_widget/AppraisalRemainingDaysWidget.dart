import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppraisalRemainingDaysWidget extends StatelessWidget {
  final String? fieldLabel;
  final String? value; // Expecting a date string
  final bool readonly;
  final String viewType;

  const AppraisalRemainingDaysWidget({
    Key? key,
    this.fieldLabel,
    this.value,
    this.readonly = true,
    this.viewType = 'tree',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Calculate remaining days
    int calculateRemainingDays() {
      if (value == null || value!.isEmpty) return 0;

      try {
        final dateFormat = DateFormat('yyyy-MM-dd');
        final appraisalDate = dateFormat.parse(value!);
        final currentDate = DateTime.now();

        // Calculate difference in days
        final difference = appraisalDate.difference(currentDate).inDays;
        return difference;
      } catch (e) {
        return 0;
      }
    }

    final remainingDays = calculateRemainingDays();
    final textColor = remainingDays < 0
        ? Colors.red
        : remainingDays <= 7
        ? Colors.orange
        : Colors.green;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (fieldLabel != null && viewType == 'form')
            Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: Text(
                fieldLabel!,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ),
          Text(
            remainingDays >= 0
                ? '$remainingDays days remaining'
                : 'Overdue by ${-remainingDays} days',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}