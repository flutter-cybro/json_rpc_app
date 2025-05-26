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
    selectedValues = List.from(widget.values);
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
      widget.onValuesChanged(selectedValues);
    });
  }

  String _getSelectedValuesText() {
    if (selectedValues.isEmpty) return 'Select ${widget.name}';
    return selectedValues.map((value) => _getOptionName(value)).join(', ');
  }

  void _showSelectionBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
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
                      final isSelected = selectedValues.contains(option['id']);
                      return ListTile(
                        leading: Checkbox(
                          value: isSelected,
                          onChanged: (bool? isChecked) => _toggleValue(option['id']),
                        ),
                        title: Text(
                          option['name'] ?? 'Unnamed Option',
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () => _toggleValue(option['id']),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
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
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        InkWell(
          onTap: () => _showSelectionBottomSheet(context),
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