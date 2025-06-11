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
        _selectedKey = widget.value;
      });
    }
  }

  List<DropdownMenuItem<String>> _buildDropdownItems() {
    final items = <DropdownMenuItem<String>>[];
    final seenValues = <String?>{};

    // Add empty option only if it's not already in the options
    if (!_hasEmptyOption()) {
      items.add(const DropdownMenuItem<String>(
        value: null,
        child: Text('Select an option'),
      ));
      seenValues.add(null);
    }

    if (widget.options == null || widget.options!.isEmpty) {
      return items;
    }

    for (final option in widget.options!) {
      String? key;
      String displayValue;

      if (option is List && option.length >= 2) {
        key = option[0]?.toString();
        displayValue = option[1]?.toString() ?? '';
      } else {
        key = option?.toString();
        displayValue = option?.toString() ?? '';
      }

      // Skip if we've already seen this value
      if (seenValues.contains(key)) {
        continue;
      }

      seenValues.add(key);
      items.add(DropdownMenuItem<String>(
        value: key,
        child: Text(displayValue),
      ));
    }

    return items;
  }

  bool _hasEmptyOption() {
    if (widget.options == null || widget.options!.isEmpty) {
      return false;
    }

    for (final option in widget.options!) {
      String? key;
      if (option is List && option.length >= 2) {
        key = option[0]?.toString();
      } else {
        key = option?.toString();
      }

      if (key == null || key.isEmpty) {
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final dropdownItems = _buildDropdownItems();

    // Ensure the selected value exists in the items
    final selectedValueExists = _selectedKey == null ||
        dropdownItems.any((item) => item.value == _selectedKey);

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
              value: selectedValueExists ? _selectedKey : null,
              items: dropdownItems,
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
              hint: const Text('Select an option'),
            ),
          ),
        ],
      ),
    );
  }
}