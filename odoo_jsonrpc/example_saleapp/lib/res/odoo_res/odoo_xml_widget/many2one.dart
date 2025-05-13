import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:odoo_jsonrpc/odoo_jsonrpc.dart';

class Many2one extends StatefulWidget {
  final String modelName;
  final String fieldName;
  final OdooClient? client;
  final String? hint;
  final Color? buttonColor;
  final Color? dropdownColor;
  final double? buttonHeight;
  final double? buttonWidth;
  final double? dropdownWidth;
  final BorderRadius? borderRadius;
  final int? recordId;

  const Many2one({
    super.key,
    required this.fieldName,
    required this.modelName,
    this.client,
    this.hint = 'Select',
    this.buttonColor = Colors.white,
    this.dropdownColor = Colors.white,
    this.buttonHeight = 50,
    this.buttonWidth = 160,
    this.dropdownWidth = 150,
    this.borderRadius = const BorderRadius.all(Radius.circular(14)),
    this.recordId,
  });
  @override
  State<Many2one> createState() => _Many2oneState();
}

class _Many2oneState extends State<Many2one> {
  List<Map<String, dynamic>> items = [];
  String? selectedValue;
  late OdooClient _client;

  @override
  void initState() {
    super.initState();
    _client = widget.client ?? OdooClient('http://10.42.0.1:8017/');
    fetchModelData();
  }

  Future<void> fetchModelData() async {
    if (widget.modelName.isNotEmpty) {
      try {
        final session = await _client.authenticate('odoo_json_rpc', '1', '1');
        print('Authenticated: $session');

        // Check if the model is 'res.partner' or any other condition
        if (widget.modelName == 'res.partner') {
          // Fetch data from the 'res.partner' model if partner_id is passed
          final recordsResponse = await _client.callKw({
            'model': widget.modelName,
            'method': 'search_read',
            'args': [],
            'kwargs': {
              'fields': ['id', 'name'],
            },
          });

          print('Records Response: $recordsResponse');

          if (recordsResponse != null && recordsResponse.isNotEmpty) {
            setState(() {
              // Store the fetched records
              items = List<Map<String, dynamic>>.from(recordsResponse);

              // If recordId is provided, set the selected value
              if (widget.recordId != null) {
                final record = items.firstWhere(
                      (item) => item['id'] == widget.recordId,
                  orElse: () => items.first,
                );
                selectedValue = record['name']?.toString();
              }
            });
          }
        } else {
          // For other models, implement a default fetch logic
          final recordsResponse = await _client.callKw({
            'model': widget.modelName,
            'method': 'search_read',
            'args': [],
            'kwargs': {
              'fields': ['id', 'name'],
            },
          });

          print('Records Response: $recordsResponse');

          if (recordsResponse != null && recordsResponse.isNotEmpty) {
            setState(() {
              items = List<Map<String, dynamic>>.from(recordsResponse);

              if (widget.recordId != null) {
                final record = items.firstWhere(
                      (item) => item['id'] == widget.recordId,
                  orElse: () => items.first,
                );
                selectedValue = record['name']?.toString();
              }
            });
          }
        }
      } catch (e) {
        print('Error fetching model data: $e');
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.buttonHeight,
      width: widget.buttonWidth,
      child: DropdownButtonHideUnderline(
        child: DropdownButton2<String>(
          isExpanded: true,
          hint: Row(
            children: [
              Expanded(
                child: Text(
                  widget.hint!,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          items: items.map((item) => DropdownMenuItem<String>(
            value: item['name']?.toString(),
            child: Text(
              item['name']?.toString() ?? '',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          )).toList(),
          value: selectedValue,
          onChanged: (String? value) {
            setState(() {
              selectedValue = value;
            });
            // Get the selected item's ID if needed
            final selectedItem = items.firstWhere(
                  (item) => item['name'].toString() == value,
              orElse: () => {},
            );
            print('Selected Value check: $value');
            print('Selected ID: ${selectedItem['id']}');
          },
          buttonStyleData: ButtonStyleData(
            height: widget.buttonHeight,
            width: widget.buttonWidth,
            padding: const EdgeInsets.only(left: 14, right: 14),
            decoration: BoxDecoration(
              borderRadius: widget.borderRadius!,
              border: Border.all(
                color: Colors.black26,
              ),
              color: widget.buttonColor,
            ),
            elevation: 2,
          ),
          iconStyleData: const IconStyleData(
            icon: Icon(
              Icons.arrow_drop_down,
            ),
            iconSize: 24,
            iconEnabledColor: Colors.black54,
            iconDisabledColor: Colors.grey,
          ),
          dropdownStyleData: DropdownStyleData(
            maxHeight: 200,
            width: widget.dropdownWidth,
            decoration: BoxDecoration(
              borderRadius: widget.borderRadius!,
              color: widget.dropdownColor,
            ),
            offset: const Offset(5, 0),
            scrollbarTheme: ScrollbarThemeData(
              radius: const Radius.circular(40),
              thickness: MaterialStateProperty.all<double>(6),
              thumbVisibility: MaterialStateProperty.all<bool>(true),
            ),
          ),
          menuItemStyleData: const MenuItemStyleData(
            height: 40,
            padding: EdgeInsets.only(left: 14, right: 14),
          ),
        ),
      ),
    );
  }}



