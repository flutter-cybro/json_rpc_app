import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateFieldWidget extends StatefulWidget {
  final String name;
  final DateTime? value;
  final Function(DateTime)? onChanged;
  final bool readonly;
  final String? hintText;
  final EdgeInsetsGeometry? padding;

  const DateFieldWidget({
    required this.name,
    required this.value,
    this.onChanged,
    this.readonly = false,
    this.hintText,
    this.padding,
    Key? key,
  }) : super(key: key);

  @override
  _DateFieldWidgetState createState() => _DateFieldWidgetState();
}

class _DateFieldWidgetState extends State<DateFieldWidget> {
  late TextEditingController _controller;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.value ?? DateTime.now();
    _controller = TextEditingController(text: _formatDate(_selectedDate));
  }

  @override
  void didUpdateWidget(DateFieldWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      _selectedDate = widget.value ?? DateTime.now();
      _controller.text = _formatDate(_selectedDate);
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  Future<void> _selectDate(BuildContext context) async {
    if (widget.readonly || widget.onChanged == null) return;

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
        _controller.text = _formatDate(pickedDate);
      });
      widget.onChanged?.call(pickedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: widget.padding ?? const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              widget.name,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: widget.readonly ? theme.disabledColor : theme.textTheme.bodyMedium?.color,
              ),
            ),
          ),
          widget.readonly
              ? Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.dividerColor.withOpacity(0.5),
                width: 1,
              ),
            ),
            child: Text(
              _controller.text,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.disabledColor,
              ),
            ),
          )
              : TextField(
            controller: _controller,
            readOnly: true,
            style: theme.textTheme.bodyLarge,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              hintText: widget.hintText ?? 'Select date',
              hintStyle: theme.textTheme.bodyLarge?.copyWith(
                color: theme.hintColor,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: theme.dividerColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: theme.dividerColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: theme.colorScheme.primary,
                  width: 1.5,
                ),
              ),
              filled: true,
              fillColor: theme.colorScheme.surface,
              suffixIcon: Icon(
                Icons.calendar_today,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
                size: 20,
              ),
            ),
            onTap: () => _selectDate(context),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}