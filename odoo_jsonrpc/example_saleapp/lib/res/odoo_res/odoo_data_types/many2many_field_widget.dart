import 'dart:developer';

import 'package:flutter/material.dart';

class Many2ManyFieldWidget extends StatefulWidget {
  final String name;
  final List<dynamic> values;
  final List<Map<String, dynamic>> options;
  final Function(List<dynamic>) onValuesChanged;
  final String viewType;
  final bool readOnly; // Read-only flag

  const Many2ManyFieldWidget({
    required this.name,
    required this.values,
    required this.options,
    required this.onValuesChanged,
    this.viewType = 'form',
    this.readOnly = false, // Default to false
    Key? key,
  }) : super(key: key);

  @override
  _Many2ManyFieldWidgetState createState() => _Many2ManyFieldWidgetState();
}

class _Many2ManyFieldWidgetState extends State<Many2ManyFieldWidget> {
  late List<dynamic> selectedValues;

  @override
  void initState() {
    super.initState();
    log("widget.values  : ${widget.values}");
    selectedValues = List.from(widget.values);
  }

  @override
  void didUpdateWidget(Many2ManyFieldWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_listEquals(oldWidget.values, widget.values)) {
      log("Values updated from parent: ${widget.values}");
      log("Previous values were: ${oldWidget.values}");
      setState(() {
        selectedValues = List.from(widget.values);
      });
    } else {
      log("No change detected between old: ${oldWidget.values} and new: ${widget.values}");
    }
  }

  // Helper method to compare two lists
  bool _listEquals(List<dynamic> list1, List<dynamic> list2) {
    if (list1.length != list2.length) return false;

    // Handle empty lists
    if (list1.isEmpty && list2.isEmpty) return true;
    if (list1.isEmpty || list2.isEmpty) return false;

    // Convert both lists to sets of IDs for comparison
    Set<dynamic> set1 = list1.map((item) => item is Map ? item['id'] : item).toSet();
    Set<dynamic> set2 = list2.map((item) => item is Map ? item['id'] : item).toSet();

    return set1.length == set2.length && set1.containsAll(set2);
  }

  String _getOptionName(dynamic value) {
    final id = value is Map ? value['id'] : value;
    return widget.options
        .firstWhere(
          (option) => option['id'] == id,
      orElse: () => <String, Object>{'name': 'Unknown'},
    )['name'] as String? ??
        'Unknown';
  }

  void _toggleValue(int? value) {
    if (value == null) return;
    setState(() {
      if (selectedValues.contains(value)) {
        selectedValues.remove(value);
      } else {
        selectedValues.add(value);
      }
      // Removed widget.onValuesChanged call from here
    });
  }

  String _getSelectedValuesText() {
    if (selectedValues.isEmpty) return 'Select ${widget.name}';
    try {
      return selectedValues.map((value) => _getOptionName(value)).join(', ');
    } catch (e) {
      log("Error getting selected values text: $e");
      return 'Select ${widget.name}';
    }
  }

  void _showSelectionBottomSheet(BuildContext context) {
    if (widget.readOnly) return; // Prevent opening bottom sheet if readOnly
    // Create a temporary copy of selected values for the modal
    List<dynamic> tempSelectedValues = List.from(selectedValues);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.7,
              maxChildSize: 0.9,
              minChildSize: 0.5,
              expand: false,
              builder: (context, scrollController) {
                return Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Select ${widget.name}',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        itemCount: widget.options.length,
                        itemBuilder: (context, index) {
                          final option = widget.options[index];
                          final optionId = option['id'];
                          // Check if this option is selected in tempSelectedValues
                          final isSelected = tempSelectedValues.any((value) {
                            final valueId = value is Map ? value['id'] : value;
                            return valueId == optionId;
                          });

                          return ListTile(
                            leading: Checkbox(
                              value: isSelected,
                              onChanged: (bool? isChecked) {
                                setModalState(() {
                                  if (isSelected) {
                                    // Remove the item
                                    tempSelectedValues.removeWhere((value) {
                                      final valueId = value is Map ? value['id'] : value;
                                      return valueId == optionId;
                                    });
                                  } else {
                                    // Add the item - store just the ID
                                    tempSelectedValues.add(optionId);
                                  }
                                });
                              },
                            ),
                            title: Text(
                              option['name'] ?? 'Unnamed Option',
                              overflow: TextOverflow.ellipsis,
                            ),
                            onTap: () {
                              setModalState(() {
                                if (isSelected) {
                                  // Remove the item
                                  tempSelectedValues.removeWhere((value) {
                                    final valueId = value is Map ? value['id'] : value;
                                    return valueId == optionId;
                                  });
                                } else {
                                  // Add the item - store just the ID
                                  tempSelectedValues.add(optionId);
                                }
                              });
                            },
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: ElevatedButton(
                        onPressed: () {
                          // Update the actual selected values and call the callback
                          setState(() {
                            selectedValues = List.from(tempSelectedValues);
                          });
                          widget.onValuesChanged(selectedValues);
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
                        ),
                        child: const Text('Done'),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        InkWell(
          onTap: widget.readOnly ? null : () => _showSelectionBottomSheet(context), // Disable tap if readOnly
          borderRadius: BorderRadius.circular(8),
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: widget.name,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              suffixIcon: const Icon(Icons.arrow_drop_down),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            child: Text(
              _getSelectedValuesText(),
              style: TextStyle(
                color: selectedValues.isEmpty
                    ? Theme.of(context).hintColor
                    : Theme.of(context).textTheme.bodyMedium?.color,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }
}