import 'package:flutter/material.dart';
import 'dart:developer';

class SelectionFieldWidget extends StatefulWidget {
  final String name;
  final String? value;
  final List<dynamic>? options;
  final Function(String?)? onChanged;
  final bool readonly;

  const SelectionFieldWidget({
    Key? key,
    required this.name,
    this.value,
    this.options,
    this.onChanged,
    this.readonly = false,
  }) : super(key: key);

  @override
  State<SelectionFieldWidget> createState() => _SelectionFieldWidgetState();
}

class _SelectionFieldWidgetState extends State<SelectionFieldWidget> {
  String? _selectedKey;

  @override
  void initState() {
    super.initState();
    print("SelectionFieldWidget  :  ${widget.value }   ${widget.readonly}");
    _selectedKey = widget.value;
  }

  @override
  void didUpdateWidget(covariant SelectionFieldWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      setState(() {
        _selectedKey = widget.value; // Update with new value
      });
    }
  }

  List<DropdownMenuItem<String>> _buildDropdownItems() {
    final items = <DropdownMenuItem<String>>[
      // Add empty option as the first item
      const DropdownMenuItem<String>(
        value: null,
        child: Text('Select an option'),
      ),
    ];

    if (widget.options == null || widget.options!.isEmpty) {
      return items;
    }

    items.addAll(widget.options!.map((option) {
      String key;
      String displayValue;

      if (option is List && option.length >= 2) {
        key = option[0].toString();
        displayValue = option[1].toString();
      } else {
        key = option.toString();
        displayValue = option.toString();
      }

      return DropdownMenuItem<String>(
        value: key,
        child: Text(displayValue),
      );
    }));

    return items;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0, right: 8.0),
              child: Text(
                '${widget.name}:',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14.0,
                ),
              ),
            ),
          ),
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _selectedKey,
              items: _buildDropdownItems(),
              onChanged: widget.readonly || widget.onChanged == null
                  ? null
                  : (newKey) {
                setState(() {
                  _selectedKey = newKey;
                });
                widget.onChanged!(newKey);
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4.0),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              ),
              isExpanded: true,
              hint: const Text('Select an option'), // Hint when no value is selected
            ),
          ),
        ],
      ),
    );
  }
}