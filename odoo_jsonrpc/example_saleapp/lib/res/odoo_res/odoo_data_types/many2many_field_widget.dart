import 'package:flutter/material.dart';

class Many2ManyFieldWidget extends StatefulWidget {
  final String name;
  final List<dynamic> values;
  final List<Map<String, dynamic>> options;
  final Function(List<dynamic>) onValuesChanged;
  final String viewType;

  const Many2ManyFieldWidget({
    required this.name,
    required this.values,
    required this.options,
    required this.onValuesChanged,
    this.viewType = 'form',
  });

  @override
  _Many2ManyFieldWidgetState createState() => _Many2ManyFieldWidgetState();
}

class _Many2ManyFieldWidgetState extends State<Many2ManyFieldWidget> {
  late List<dynamic> selectedValues;

  @override
  void initState() {
    super.initState();
    selectedValues = List.from(widget.values);
  }

  String _getOptionName(dynamic value) {
    final id = value is Map ? value['id'] : value;
    return widget.options
        .firstWhere(
          (option) => option['id'] == id,
      orElse: () => <String, Object>{'name': 'Unknown'},
    )['name'] as String;
  }

  void _toggleValue(int? value) {
    if (value == null) return;
    setState(() {
      if (selectedValues.contains(value)) {
        selectedValues.remove(value);
      } else {
        selectedValues.add(value);
      }
      widget.onValuesChanged(selectedValues);
    });
  }


  String _getSelectedValuesText() {
    if (selectedValues.isEmpty) return 'Select options';
    return selectedValues.map((value) => _getOptionName(value)).join(', ');
  }

  @override
  Widget build(BuildContext context) {
    if (widget.viewType == 'tree') {

      return DropdownButtonFormField<int>(
        value: null,
        hint: Text(_getSelectedValuesText()),
        items: widget.options.map((option) {
          return DropdownMenuItem<int>(
            value: option['id'],
            child: Row(
              children: [
                Checkbox(
                  value: selectedValues.contains(option['id']),
                  onChanged: (bool? isChecked) => _toggleValue(option['id']),
                ),
                Expanded(
                  child: Text(
                    option['name'] ?? 'Unnamed Option',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
        onChanged: _toggleValue,
        isExpanded: true,
        dropdownColor: Theme.of(context).cardColor,
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Text(
              widget.name,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          DropdownButtonFormField<int>(
            value: null,
            hint: Text(_getSelectedValuesText()),
            items: widget.options.map((option) {
              return DropdownMenuItem<int>(
                value: option['id'],
                child: Row(
                  children: [
                    Checkbox(
                      value: selectedValues.contains(option['id']),
                      onChanged: (bool? isChecked) => _toggleValue(option['id']),
                    ),
                    Expanded(
                      child: Text(
                        option['name'] ?? 'Unnamed Option',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: _toggleValue,
            isExpanded: true,
            dropdownColor: Theme.of(context).cardColor,
          ),
          // Removed the Wrap widget with chips
        ],
      );
    }
  }
}