import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:developer';

class DateRangeFieldWidget extends StatefulWidget {
  final String name;
  final DateTimeRange? value;
  final bool isReadonly;
  final void Function(Map<String, String?>)? onChanged;

  const DateRangeFieldWidget({
    Key? key,
    required this.name,
    this.value,
    this.isReadonly = false,
    this.onChanged,
  }) : super(key: key);

  @override
  _DateRangeFieldWidgetState createState() => _DateRangeFieldWidgetState();
}

class _DateRangeFieldWidgetState extends State<DateRangeFieldWidget> {
  DateTimeRange? selectedRange;

  @override
  void initState() {
    super.initState();
    selectedRange = widget.value;
    log("initState: selectedRange: $selectedRange");
  }

  @override
  void didUpdateWidget(DateRangeFieldWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      log("didUpdateWidget: widget.value changed from ${oldWidget.value} to ${widget.value}");
      setState(() {
        selectedRange = widget.value;
      });
    }
  }

  Future<void> _pickDateRange() async {
    final DateTime now = DateTime.now();
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
      initialDateRange: selectedRange,
    );

    if (mounted) {
      setState(() {
        selectedRange = picked;
        log("Picked date range: $selectedRange");
      });
      if (widget.onChanged != null) {
        if (picked != null) {
          final formatter = DateFormat('yyyy-MM-dd');
          widget.onChanged!({
            'start_date': formatter.format(picked.start),
            'end_date': formatter.format(picked.end),
          });
        } else {
          widget.onChanged!({'start_date': null, 'end_date': null});
        }
      }
    }
  }

  String _formatRange(DateTimeRange? range) {
    if (range == null) return 'Select date range';
    final formatter = DateFormat('yyyy-MM-dd');
    final formatted = '${formatter.format(range.start)} → ${formatter.format(range.end)}';
    log("Formatted range: $formatted");
    return formatted;
  }

  @override
  Widget build(BuildContext context) {
    log("Building with selectedRange: $selectedRange");
    return ListTile(
      title: Text(widget.name),
      subtitle: Text(_formatRange(selectedRange)),
      trailing: widget.isReadonly ? null : const Icon(Icons.date_range),
      onTap: widget.isReadonly ? null : _pickDateRange,
    );
  }
}