import 'package:flutter/material.dart';

class RadioFieldWidget extends StatefulWidget {
  final String name;
  final String? initialValue; // Initial selected value
  final List<dynamic> options; // List of [key, displayValue] pairs
  final Function(String?)? onChanged; // Callback for value change
  final bool readonly;

  const RadioFieldWidget({
    Key? key,
    required this.name,
    this.initialValue,
    required this.options,
    this.onChanged,
    this.readonly = false,
  }) : super(key: key);

  @override
  _RadioFieldWidgetState createState() => _RadioFieldWidgetState();
}

class _RadioFieldWidgetState extends State<RadioFieldWidget> {
  late String? _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${widget.name}:',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0),
          ),
          const SizedBox(height: 8.0),
          Column(
            children: widget.options.map((option) {
              final key = option[0].toString();
              final displayValue = option[1].toString();
              return RadioListTile<String>(
                title: Text(displayValue),
                value: key,
                groupValue: _selectedValue,
                onChanged: (widget.readonly || widget.onChanged == null)
                    ? null
                    : (newValue) {
                  setState(() {
                    _selectedValue = newValue;
                  });
                  widget.onChanged?.call(newValue);
                },
                dense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 0.0),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}