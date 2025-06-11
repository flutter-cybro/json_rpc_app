import 'package:flutter/material.dart';
import 'package:example_saleapp/controller/odooclient_manager_controller.dart';

class SoLineFieldWidget extends StatelessWidget {
  final String name;
  final dynamic value;
  final List<Map<String, dynamic>> options;
  final Function(dynamic) onValueChanged;
  final String viewType;
  final bool readonly;
  final String? hintText;
  final OdooClientController? odooClientController;

  const SoLineFieldWidget({
    Key? key,
    required this.name,
    required this.value,
    required this.options,
    required this.onValueChanged,
    this.viewType = 'form',
    this.readonly = false,
    this.hintText,
    this.odooClientController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // For tree view, show a simple display
    if (viewType == 'tree') {
      final displayName = _getDisplayNameFromOptions(value, options);
      return Text(
        displayName,
        style: const TextStyle(fontSize: 16),
        overflow: TextOverflow.ellipsis,
      );
    }

    // For form view, show a more detailed widget
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(4),
          ),
          child: DropdownButton<dynamic>(
            value: value,
            isExpanded: true,
            hint: Text(hintText ?? 'Select $name'),
            items: options.map((option) {
              return DropdownMenuItem<dynamic>(
                value: option['id'],
                child: Text(option['name'] ?? 'Unnamed'),
              );
            }).toList(),
            onChanged: readonly ? null : onValueChanged,
          ),
        ),
      ],
    );
  }

  String _getDisplayNameFromOptions(dynamic valueId, List<Map<String, dynamic>> options) {
    for (var option in options) {
      if (option['id'] == valueId) {
        return option['name']?.toString() ?? 'Unnamed';
      }
    }
    return 'Unnamed';
  }
}