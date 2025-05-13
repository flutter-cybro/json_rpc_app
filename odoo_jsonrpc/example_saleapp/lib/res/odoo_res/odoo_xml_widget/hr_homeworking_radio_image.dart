import 'package:flutter/material.dart';

class HrHomeworkingRadioImageWidget extends StatefulWidget {
  final String name; // Field name (e.g., "Cover Image")
  final dynamic value; // Current value (e.g., 'office')
  final List<Map<String, dynamic>> options; // Options from parent or pythonAttributes
  final ValueChanged<dynamic>? onChanged; // Callback for value change (null if readonly)
  final Map<String, dynamic>? pythonAttributes; // Python attributes for dynamic selection

  const HrHomeworkingRadioImageWidget({
    Key? key,
    required this.name,
    required this.value,
    required this.options,
    this.onChanged,
    this.pythonAttributes,
  }) : super(key: key);

  @override
  _HrHomeworkingRadioImageWidgetState createState() => _HrHomeworkingRadioImageWidgetState();
}

class _HrHomeworkingRadioImageWidgetState extends State<HrHomeworkingRadioImageWidget> {
  late dynamic _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.value; // Initialize with current value
  }

  // Helper method to extract selection options from pythonAttributes or fallback to options
  List<Map<String, dynamic>> _getSelectionOptions() {
    if (widget.pythonAttributes != null && widget.pythonAttributes!['type'] == 'selection') {
      final selection = widget.pythonAttributes!['selection'] as List<dynamic>?;
      if (selection != null && selection.isNotEmpty) {
        return selection.map((item) {
          final key = item[0] as String;
          final val = item[1] as String;
          return {'id': key, 'name': val};
        }).toList();
      }
    }
    return widget.options;
  }

  // Map selection keys to icons
  IconData _getIconForOption(String id) {
    switch (id) {
      case 'office':
        return Icons.business;
      case 'home':
        return Icons.home;
      case 'other':
        return Icons.location_on;
      default:
        return Icons.help_outline;
    }
  }

  // Determine if the layout should be horizontal based on options
  bool _isHorizontal() {
    final xmlOptions = widget.pythonAttributes?['xml_attributes']?['options'] as Map<String, dynamic>?;
    return xmlOptions != null && xmlOptions['horizontal'] == true;
  }

  @override
  Widget build(BuildContext context) {
    final selectionOptions = _getSelectionOptions();
    final isHorizontal = _isHorizontal();
    final isReadonly = widget.onChanged == null;

    // Debugging output
    print('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>');
    print('Field Name: ${widget.name}');
    print('Current Value: $_selectedValue');
    print('Selection Options: $selectionOptions');
    print('Is Horizontal: $isHorizontal');
    print('Is Readonly: $isReadonly');

    // Validate the value
    if (!selectionOptions.any((opt) => opt['id'] == _selectedValue)) {
      _selectedValue = null; // Reset if invalid
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.name,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          isHorizontal
              ? Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: selectionOptions.map((option) {
              final id = option['id'] as String;
              final name = option['name'] as String;
              return Row(
                children: [
                  Radio<dynamic>(
                    value: id,
                    groupValue: _selectedValue,
                    onChanged: isReadonly ? null : (newValue) {
                      setState(() {
                        _selectedValue = newValue;
                      });
                      widget.onChanged?.call(newValue);
                    },
                  ),
                  Icon(
                    _getIconForOption(id),
                    size: 20,
                    color: isReadonly ? Colors.grey : Colors.grey.withOpacity(0.5),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    name,
                    style: TextStyle(
                      color: isReadonly ? Colors.grey : Colors.black,
                    ),
                  ),
                  const SizedBox(width: 16), // Space between options
                ],
              );
            }).toList(),
          )
              : Column(
            children: selectionOptions.map((option) {
              final id = option['id'] as String;
              final name = option['name'] as String;
              return RadioListTile<dynamic>(
                value: id,
                groupValue: _selectedValue,
                onChanged: isReadonly ? null : (newValue) {
                  setState(() {
                    _selectedValue = newValue;
                  });
                  widget.onChanged?.call(newValue);
                },
                title: Row(
                  children: [
                    Icon(
                      _getIconForOption(id),
                      size: 20,
                      color: isReadonly ? Colors.grey : Colors.grey.withOpacity(0.5),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      name,
                      style: TextStyle(
                        color: isReadonly ? Colors.grey : Colors.black,
                      ),
                    ),
                  ],
                ),
                contentPadding: EdgeInsets.zero,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}