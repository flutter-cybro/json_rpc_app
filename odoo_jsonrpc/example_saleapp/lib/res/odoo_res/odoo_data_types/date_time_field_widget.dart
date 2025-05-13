import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateTimeFieldWidget extends StatefulWidget {
  final String name;
  final DateTime? value;
  final Function(DateTime) onChanged;

  DateTimeFieldWidget({
    required this.name,
    required this.value,
    required this.onChanged,
  });

  @override
  _DateTimeFieldWidgetState createState() => _DateTimeFieldWidgetState();
}

class _DateTimeFieldWidgetState extends State<DateTimeFieldWidget> {
  late TextEditingController _controller;
  late DateTime _selectedDateTime;
  late DateTime _originalDateTime;

  @override
  void initState() {
    super.initState();
    _selectedDateTime = widget.value ?? DateTime.now();
    _originalDateTime = _selectedDateTime;
    _controller = TextEditingController(
      text: _formatDateTime(_selectedDateTime),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
      );

      if (pickedTime != null) {
        final DateTime selectedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        setState(() {
          _selectedDateTime = selectedDateTime;
          _controller.text = _formatDateTime(selectedDateTime);
        });


        widget.onChanged(selectedDateTime);
      } else {
        setState(() {
          _selectedDateTime = _originalDateTime;
          _controller.text = _formatDateTime(_originalDateTime);
        });
      }
    } else {
      setState(() {
        _selectedDateTime = _originalDateTime;
        _controller.text = _formatDateTime(_originalDateTime);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.name,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _controller,
            readOnly: true,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              suffixIcon: Icon(Icons.calendar_today),
            ),
            onTap: () => _selectDateTime(context),
          ),
        ],
      ),
    );
  }
}
