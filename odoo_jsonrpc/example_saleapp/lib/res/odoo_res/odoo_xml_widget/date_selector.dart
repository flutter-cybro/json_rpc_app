import 'package:flutter/material.dart';

class DateSelectorWidget extends StatefulWidget {
  @override
  _DateSelectorWidgetState createState() => _DateSelectorWidgetState();
}

class _DateSelectorWidgetState extends State<DateSelectorWidget> {
  DateTime? _selectedDate;

  // Method to show the date picker and set the selected date
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        // Display selected date or prompt text
        Text(
          _selectedDate == null
              ? 'No date selected'
              : 'Selected Date: ${_selectedDate!.toLocal()}'.split(' ')[0],
          style: TextStyle(fontSize: 16),
        ),
        SizedBox(height: 10),
        // Button to open the date picker
        ElevatedButton(
          onPressed: () => _selectDate(context),
          child: Text('Select Date'),
        ),
      ],
    );
  }
}
