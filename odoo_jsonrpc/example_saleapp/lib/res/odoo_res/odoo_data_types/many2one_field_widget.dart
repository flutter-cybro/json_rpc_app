import 'package:flutter/material.dart';
import 'dart:developer';

class Many2OneFieldWidget extends StatefulWidget {
  final String name;
  final dynamic value;
  final List<Map<String, dynamic>> options;
  final Function(dynamic) onValueChanged;
  final String viewType;
  final bool readonly;

  const Many2OneFieldWidget({
    required this.name,
    required this.value,
    required this.options,
    required this.onValueChanged,
    super.key,
    this.viewType = 'form',
    this.readonly = false,
  });

  @override
  _Many2OneFieldWidgetState createState() => _Many2OneFieldWidgetState();
}

class _Many2OneFieldWidgetState extends State<Many2OneFieldWidget> {
  dynamic selectedValue;

  @override
  void initState() {
    super.initState();
    print("Many2OneFieldWidget  : ${widget.readonly}  ${widget.name}");
    _updateSelectedValue(widget.value);
  }

  @override
  void didUpdateWidget(Many2OneFieldWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value || oldWidget.options != widget.options) {
      _updateSelectedValue(widget.value);
    }
  }

  void _updateSelectedValue(dynamic value) {
    final valueId = (value is List && value.isNotEmpty) ? value[0] : value;
    final existsInOptions = widget.options.any((option) => option['id'] == valueId);
    setState(() {
      selectedValue = existsInOptions ? valueId : null;
    });
  }

  // Helper method to get the display name for the selected value
  String _getDisplayName(dynamic valueId) {
    if (valueId == null || widget.options.isEmpty) {
      return 'N/A';
    }

    for (var option in widget.options) {
      if (option['id'] == valueId) {
        return option['name']?.toString() ?? 'Unnamed';
      }
    }

    return 'N/A'; // Fallback if no matching option is found
  }

  @override
  Widget build(BuildContext context) {
    final uniqueOptions = _removeDuplicateOptions(widget.options);

    // Define common styling for readonly and editable fields
    final borderRadius = BorderRadius.circular(8.0);
    const contentPadding =
        EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0);

    if (widget.viewType == 'tree') {
      return widget.readonly
          ? Container(
              padding: contentPadding,
              decoration: BoxDecoration(
                color: Colors.grey[100], // Muted background for readonly
                border: Border.all(color: Colors.grey[400]!, width: 1.0),
                borderRadius: borderRadius,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                _getDisplayName(selectedValue),
                style: TextStyle(
                  fontSize: 14.0,
                  color: Colors.grey[600], // Grey text for readonly
                  fontWeight: FontWeight.w400,
                ),
              ),
            )
          : DropdownButtonFormField<dynamic>(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                    ),
                    value: selectedValue,
                    items: uniqueOptions
                        .map((option) => DropdownMenuItem<dynamic>(
                      value: option['id'],
                      child: Text(option['name']?.toString() ?? 'Unnamed'),
                    ))
                        .toList(),
                    onChanged: (newValue) {
                      setState(() {
                        selectedValue = newValue;
                      });
                      widget.onValueChanged(newValue);
                    },
                    isExpanded: true,
                    hint: const Text('Select an option'),
                  );
    } else {
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
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.0,
                    color: widget.readonly ? Colors.grey : Colors.black87,
                  ),
                ),
              ),
            ),
            Expanded(
              child: widget.readonly
                  ? Container(
                      padding: contentPadding,
                      decoration: BoxDecoration(
                        color:
                            Colors.grey[100], // Muted background for readonly
                        border:
                            Border.all(color: Colors.grey[400]!, width: 1.0),
                        borderRadius: borderRadius,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        _getDisplayName(selectedValue),
                        style: TextStyle(
                          fontSize: 14.0,
                          color: Colors.grey[600], // Grey text for readonly
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    )
                  : DropdownButtonFormField<dynamic>(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: borderRadius,
                          borderSide: BorderSide(color: Colors.grey[400]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: borderRadius,
                          borderSide: BorderSide(color: Colors.grey[400]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: borderRadius,
                          borderSide:
                              BorderSide(color: Theme.of(context).primaryColor),
                        ),
                        contentPadding: contentPadding,
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      value: selectedValue,
                      items: uniqueOptions
                          .map((option) => DropdownMenuItem<dynamic>(
                                value: option['id'],
                                child: Text(
                                  option['name']?.toString() ?? 'Unnamed',
                                  style: const TextStyle(fontSize: 14.0),
                                ),
                              ))
                          .toList(),
                      onChanged: (newValue) {
                        setState(() {
                          selectedValue = newValue;
                        });
                        widget.onValueChanged(newValue);
                      },
                      isExpanded: true,
                      hint: const Text(
                        'Select an option',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
            ),
          ],
        ),
      );
    }
  }

  List<Map<String, dynamic>> _removeDuplicateOptions(List<Map<String, dynamic>> options) {
    final seenIds = <dynamic>{};
    final uniqueOptions = <Map<String, dynamic>>[];

    for (var option in options) {
      final id = option['id'];
      if (id != null && !seenIds.contains(id)) {
        seenIds.add(id);
        uniqueOptions.add(option);
      } else if (id != null) {
      }
    }

    return uniqueOptions;
  }
}