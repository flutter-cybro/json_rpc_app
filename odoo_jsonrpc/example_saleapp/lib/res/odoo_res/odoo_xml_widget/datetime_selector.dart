import 'package:flutter/material.dart';

class DateTimeSelectorWidget extends StatefulWidget {
  @override
  _DateTimeSelectorWidgetState createState() => _DateTimeSelectorWidgetState();
}

class _DateTimeSelectorWidgetState extends State<DateTimeSelectorWidget> {
  DateTime? _selectedDateTime;

  // Method to pick both date and time
  Future<void> _selectDateTime(BuildContext context) async {
    // Step 1: Pick a Date
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      // Step 2: Pick a Time after selecting a Date
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime ?? DateTime.now()),
      );

      if (pickedTime != null) {
        // Combine picked date and time into a single DateTime object
        setState(() {
          _selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
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

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        // Display selected date and time or prompt text
        Text(
          _selectedDateTime == null
              ? 'No date & time selected'
              : 'Selected: ${_selectedDateTime!.toLocal()}',
          style: TextStyle(fontSize: 16),
        ),
        SizedBox(height: 10),
        // Button to open date & time picker
        ElevatedButton(
          onPressed: () => _selectDateTime(context),
          child: Text('Select Date & Time'),
        ),
      ],
    );
  }
}
