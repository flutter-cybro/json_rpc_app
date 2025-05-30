import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateTimeFieldWidget extends StatefulWidget {
  final String name;
  final DateTime? value;
  final Function(DateTime)? onChanged;
  final bool readonly;
  final String? format;

  const DateTimeFieldWidget({
    super.key,
    required this.name,
    required this.value,
    this.onChanged,
    this.readonly = false,
    this.format,
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
    final format = widget.format ?? 'dd/MM/yyyy HH:mm';
    return DateFormat(format).format(dateTime);
  }

  Future<void> _selectDateTime(BuildContext context) async {
    if (widget.readonly) return;

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

        widget.onChanged?.call(selectedDateTime);
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
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Tooltip(
      message: widget.readonly ? 'This field is read-only' : 'Select date and time',
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.name,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Semantics(
              label: '${widget.name}: ${_controller.text}${widget.readonly ? ', read-only' : ''}',
              enabled: !widget.readonly,
              child: TextField(
                controller: _controller,
                readOnly: true,
                enabled: !widget.readonly,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  suffixIcon: widget.readonly
                      ? const Icon(Icons.lock, size: 18)
                      : const Icon(Icons.calendar_today),
                  disabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: theme.disabledColor.withOpacity(0.5),
                    ),
                  ),
                  filled: widget.readonly,
                  fillColor: widget.readonly
                      ? theme.disabledColor.withOpacity(0.1)
                      : null,
                ),
                style: TextStyle(
                  color: widget.readonly
                      ? theme.disabledColor
                      : theme.textTheme.bodyMedium?.color,
                ),
                onTap: widget.readonly ? null : () => _selectDateTime(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}