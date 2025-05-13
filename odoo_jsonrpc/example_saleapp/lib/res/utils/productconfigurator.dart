import 'package:flutter/material.dart';

class ProductConfiguratorDialog extends StatefulWidget {
  final int productId;
  final Map<String, dynamic> initialValues;
  final Map<String, dynamic> configurationData;
  final Function(Map<String, dynamic>) onSave;

  const ProductConfiguratorDialog({
    required this.productId,
    required this.initialValues,
    required this.configurationData,
    required this.onSave,
  });

  @override
  _ProductConfiguratorDialogState createState() => _ProductConfiguratorDialogState();
}

class _ProductConfiguratorDialogState extends State<ProductConfiguratorDialog> {
  late Map<String, dynamic> _currentValues;
  List<Map<String, dynamic>> _attributes = [];
  List<Map<String, dynamic>> _variants = [];

  @override
  void initState() {
    super.initState();
    _currentValues = Map.from(widget.initialValues);
    _parseConfigurationData();
  }

  void _parseConfigurationData() {
    // Parse the configuration data from Odoo
    // This will depend on your Odoo version and product configurator implementation
    final attributes = widget.configurationData['attributes'] ?? [];
    final variants = widget.configurationData['variants'] ?? [];

    setState(() {
      _attributes = List<Map<String, dynamic>>.from(attributes);
      _variants = List<Map<String, dynamic>>.from(variants);
    });
  }

  void _onAttributeChanged(String attribute, dynamic value) {
    setState(() {
      _currentValues[attribute] = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.all(16),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 600, maxHeight: MediaQuery.of(context).size.height * 0.8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Configure Product', style: Theme.of(context).textTheme.headlineSmall),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Divider(height: 1),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Display product info
                    ListTile(
                      title: Text(widget.configurationData['product_name'] ?? 'Product'),
                      subtitle: Text(widget.configurationData['product_code'] ?? ''),
                    ),

                    // Display configurable attributes
                    ..._attributes.map((attribute) {
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(attribute['name'], style: TextStyle(fontWeight: FontWeight.bold)),
                            SizedBox(height: 8),
                            // This could be a dropdown, radio buttons, etc. depending on attribute type
                            DropdownButtonFormField(
                              value: _currentValues[attribute['code']],
                              items: (attribute['values'] as List).map((value) {
                                return DropdownMenuItem(
                                  value: value['id'],
                                  child: Text(value['name']),
                                );
                              }).toList(),
                              onChanged: (value) => _onAttributeChanged(attribute['code'], value),
                              isExpanded: true,
                            ),
                          ],
                        ),
                      );
                    }),

                    // Quantity field
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: TextFormField(
                        initialValue: _currentValues['product_uom_qty']?.toString() ?? '1',
                        decoration: InputDecoration(
                          labelText: 'Quantity',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          _currentValues['product_uom_qty'] = double.tryParse(value) ?? 1;
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    child: Text('CANCEL'),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  SizedBox(width: 12),
                  ElevatedButton(
                    child: Text('CONFIRM'),
                    onPressed: () {
                      widget.onSave(_currentValues);
                      Navigator.of(context).pop(_currentValues);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}