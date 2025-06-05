import 'package:flutter/material.dart';

class Many2ManyTagsWidget extends StatefulWidget {
  final String name;
  final List<dynamic> values;
  final List<Map<String, dynamic>> options;
  final Function(List<dynamic>)? onValuesChanged; // Made optional for read-only views

  const Many2ManyTagsWidget({
    Key? key,
    required this.name,
    required this.values,
    required this.options,
    this.onValuesChanged,
  }) : super(key: key);

  @override
  _Many2ManyTagsWidgetState createState() => _Many2ManyTagsWidgetState();
}

class _Many2ManyTagsWidgetState extends State<Many2ManyTagsWidget> {
  late List<dynamic> selectedValues;

  @override
  void initState() {
    super.initState();
    selectedValues = List.from(widget.values);
  }

  String _getDisplayName(dynamic id) {
    final option = widget.options.firstWhere(
          (opt) => opt['id'] == id,
      orElse: () => {'name': 'Unknown'},
    );
    return option['name'] as String;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60, // Fit within the 80px row height with padding
      width: 200, // Match TreeViewScreen column width
      child: selectedValues.isEmpty
          ? const Text(
        '',
        style: TextStyle(color: Colors.grey, fontSize: 16),
        overflow: TextOverflow.ellipsis,
      )
          : Wrap(
        spacing: 4.0,
        runSpacing: 4.0,
        children: selectedValues.map((value) {
          return Chip(
            label: Text(
              _getDisplayName(value),
              style: const TextStyle(fontSize: 14),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            onDeleted: widget.onValuesChanged != null
                ? () {
              setState(() {
                selectedValues.remove(value);
              });
              widget.onValuesChanged!(selectedValues);
            }
                : null, // No delete button if read-only
            backgroundColor: Colors.blueGrey.withOpacity(0.1),
            labelStyle: const TextStyle(color: Colors.black),
          );
        }).toList(),
      ),
    );
  }
}