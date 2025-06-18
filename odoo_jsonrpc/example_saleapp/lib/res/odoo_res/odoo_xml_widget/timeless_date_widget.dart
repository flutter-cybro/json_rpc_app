import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TimelessDateWidget extends StatelessWidget {
  final String name;
  final String? value;
  final String viewType;
  final bool readonly;

  const TimelessDateWidget({
    Key? key,
    required this.name,
    this.value,
    this.viewType = 'tree',
    this.readonly = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Parse and format the date if value is not null or empty
    String formattedDate = '';
    if (value != null && value!.isNotEmpty) {
      try {
        final dateTime = DateTime.parse(value!);
        formattedDate = DateFormat('yyyy-MM-dd').format(dateTime);
      } catch (e) {
        formattedDate = value ?? ''; // Fallback to raw value if parsing fails
      }
    }

    return Text(
      formattedDate,
      style: TextStyle(
        fontSize: 16.0,
        color: readonly ? Colors.black87 : Theme.of(context).colorScheme.primary,
      ),
      overflow: TextOverflow.ellipsis,
    );
  }
}