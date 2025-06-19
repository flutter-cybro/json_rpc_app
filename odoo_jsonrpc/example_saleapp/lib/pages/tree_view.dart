import 'dart:math';
import 'dart:developer' as dev;
import 'package:example_saleapp/pages/form_view.dart';
import 'package:example_saleapp/res/odoo_res/odoo_data_types/many2one_field_widget.dart';
import 'package:flutter/material.dart';
import '../controller/odoo_crud_mixier.dart';
import '../controller/odooclient_manager_controller.dart';
import '../res/constants/app_colors.dart';
import '../res/odoo_res/odoo_data_types/MonetaryFieldWidget.dart';
import '../res/odoo_res/odoo_data_types/date_field_widget.dart';
import '../res/odoo_res/odoo_data_types/float_field_widget.dart';
import '../res/odoo_res/odoo_data_types/html_field_widget.dart';
import '../res/odoo_res/odoo_data_types/many2one_reference_field_widget.dart';
import '../res/odoo_res/odoo_data_types/reference.dart';
import '../res/odoo_res/odoo_xml_widget/AppraisalRemainingDaysWidget.dart';
import '../res/odoo_res/odoo_xml_widget/Many2ManyTagSkillsWidget.dart';
import '../res/odoo_res/odoo_xml_widget/PriorityWidget.dart';
import '../res/odoo_res/odoo_xml_widget/RemainingDaysWidget.dart';
import '../res/odoo_res/odoo_xml_widget/badge.dart';
import '../res/odoo_res/odoo_xml_widget/boolean_favorite.dart';
import '../res/odoo_res/odoo_xml_widget/boolean_toggle.dart';
import '../res/odoo_res/odoo_xml_widget/char_with_placeholder_field_widget.dart';
import '../res/odoo_res/odoo_xml_widget/color.dart';
import '../res/odoo_res/odoo_xml_widget/color_picker.dart';
import '../res/odoo_res/odoo_xml_widget/copy_clipboard_char.dart';
import '../res/odoo_res/odoo_xml_widget/handle.dart';
import '../res/odoo_res/odoo_xml_widget/image.dart';
import '../res/odoo_res/odoo_xml_widget/image_url.dart';
import '../res/odoo_res/odoo_xml_widget/list_activity.dart';
import '../res/odoo_res/odoo_xml_widget/many2many_tags.dart';
import '../res/odoo_res/odoo_xml_widget/many2one_avatar_user_widget.dart';
import '../res/odoo_res/odoo_xml_widget/progressbar.dart';
import '../res/odoo_res/odoo_xml_widget/project_favorite.dart';
import '../res/odoo_res/odoo_xml_widget/so_line_field.dart';
import '../res/odoo_res/odoo_xml_widget/timeless_date_widget.dart';
import '../res/odoo_res/odoo_xml_widget/timesheet_uom_timer_widget.dart';
import '../res/widgets/no_data_image.dart';



class TreeViewScreen extends StatefulWidget {
  final String title;
  final List<dynamic> dataList;
  final String modelname;
  final String formdata;
  final List<Map<String, dynamic>> fieldMetadata;
  final int? viewId;
  final String? moduleName;
  final bool readonly; // Add this


  const TreeViewScreen({
    Key? key,
    required this.title,
    required this.dataList,
    required this.modelname,
    required this.formdata,
    required this.fieldMetadata,
    this.moduleName,
    this.viewId,
    this.readonly = true,
  }) : super(key: key);

  @override
  State<TreeViewScreen> createState() => _TreeViewScreenState();
}
class _TreeViewScreenState extends State<TreeViewScreen> with OdooCrudMixin, SingleTickerProviderStateMixin {
// class _TreeViewScreenState extends State<TreeViewScreen> with OdooCrudMixin {
  late final OdooClientController _odooClientController;
  late List<String> _visibleFields;
  late ScrollController _headerScrollController;
  late ScrollController _bodyScrollController;
  final int maxFieldsPerScreen = 3;
  String _searchQuery = '';
  List<dynamic> _filteredDataList = [];
  bool _isSearchActive = false;
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _searchBarAnimation;

  @override
  OdooClientController get odooClientController => _odooClientController;

  @override
  String get modelName => widget.modelname;

  @override
  Map<String, dynamic> toJson() {
    return {'name': 'New ${widget.title}'};
  }

  @override
  dynamic fromJson(Map<String, dynamic> json) {
    return json;
  }

  @override
  void initState() {
    super.initState();
    dev.log("title : ${widget.title} \ndataList  : ${widget.dataList} \nmodelname : ${widget.modelname} \nfieldMetadata : ${widget.fieldMetadata}");
    _odooClientController = OdooClientController();
    _initializeOdooClient();
    _headerScrollController = ScrollController();
    _bodyScrollController = ScrollController();
    _filteredDataList = widget.dataList;

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _searchBarAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _searchController.addListener(_onSearchChanged);

    _headerScrollController.addListener(() {
      if (_headerScrollController.hasClients && _bodyScrollController.hasClients) {
        if (_bodyScrollController.offset != _headerScrollController.offset) {
          _bodyScrollController.jumpTo(_headerScrollController.offset);
        }
      }
    });

    _bodyScrollController.addListener(() {
      if (_bodyScrollController.hasClients && _headerScrollController.hasClients) {
        if (_headerScrollController.offset != _bodyScrollController.offset) {
          _headerScrollController.jumpTo(_bodyScrollController.offset);
        }
      }
    });

    _visibleFields = widget.fieldMetadata
        .asMap()
        .entries
        .where((entry) => isFieldVisibleByDefault(entry.value))
        .map((entry) => entry.value['name'] as String)
        .toSet() // Remove duplicates
        .toList();
  }
  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
      _filterDataList(_searchQuery);
    });
  }

  void _toggleSearch() {
    setState(() {
      _isSearchActive = !_isSearchActive;
      if (_isSearchActive) {
        _animationController.forward();
      } else {
        _animationController.reverse();
        _searchController.clear();
        _searchQuery = '';
        _filteredDataList = widget.dataList;
      }
    });
  }
  Future<void> _initializeOdooClient() async {
    try {
      await _odooClientController.initialize();
    } catch (e) {
      // log('Failed to initialize Odoo client: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to initialize Odoo client: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _headerScrollController.dispose();
    _bodyScrollController.dispose();
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Map<String, dynamic>? getFieldMetadata(String fieldName) {
    try {
      return widget.fieldMetadata
          .firstWhere((metadata) => metadata['name'] == fieldName);
    } catch (e) {
      return null;
    }
  }

  dynamic getFieldDisplay(Map<String, dynamic> data, String fieldName) {
    final metadata = getFieldMetadata(fieldName);
    if (metadata == null) return '';

    // Skip rendering fields with type 'properties'
    if (metadata['type'] == 'properties') {
      return const Text('');
    }

    dynamic fieldValue = data[fieldName];

    if (fieldValue == null ||
        fieldValue.toString().isEmpty ||
        fieldValue == false) {
      return '';
    }

    final xmlAttrs = metadata['xmlAttributes'] as List<dynamic>?;
    final widgetType = xmlAttrs?.firstWhere(
          (attr) => attr['name'] == 'widget',
      orElse: () => {'value': null},
    )['value'];

    print(
        "widgetType : $widgetType  , fieldName  : $fieldName  , metadata : $metadata");
    final fieldLabel = metadata['pythonAttributes']['string'] ?? fieldName;
    if (metadata['type'] == 'monetary') {
      double monetaryValue = fieldValue is num ? fieldValue.toDouble() : 0.0;

      // Function to fetch currency symbol
      Future<String> fetchCurrencySymbol() async {
        try {
          // Check if currency_id exists in data
          if (data.containsKey('currency_id') && data['currency_id'] is List && data['currency_id'].length >= 2) {
            int currencyId = data['currency_id'][0];
            final currencyData = await _odooClientController.client.callKw({
              'model': 'res.currency',
              'method': 'search_read',
              'args': [
                [['id', '=', currencyId]],
              ],
              'kwargs': {
                'fields': ['symbol', 'name'],
              },
            });
            if (currencyData is List && currencyData.isNotEmpty) {
              return currencyData[0]['symbol'] ?? currencyData[0]['name'] ?? '';
            }
          }

          // Fallback: Fetch the company's default currency
          final companyData = await _odooClientController.client.callKw({
            'model': 'res.company',
            'method': 'search_read',
            'args': [
              [], // No domain, fetch the current user's company
            ],
            'kwargs': {
              'fields': ['currency_id'],
              'limit': 1,
            },
          });
          if (companyData is List && companyData.isNotEmpty && companyData[0]['currency_id'] is List) {
            int companyCurrencyId = companyData[0]['currency_id'][0];
            final currencyData = await _odooClientController.client.callKw({
              'model': 'res.currency',
              'method': 'search_read',
              'args': [
                [['id', '=', companyCurrencyId]],
              ],
              'kwargs': {
                'fields': ['symbol', 'name'],
              },
            });
            if (currencyData is List && currencyData.isNotEmpty) {
              return currencyData[0]['symbol'] ?? currencyData[0]['name'] ?? '';
            }
          }

          // Ultimate fallback: empty string
          return '';
        } catch (e) {
          // log('Failed to fetch currency symbol: $e');
          return ''; // Return empty string on error
        }
      }

      return MonetaryFieldWidget(
        name: fieldLabel,
        value: monetaryValue,
        currencySymbolFuture: fetchCurrencySymbol(),
        viewType: 'tree',
      );
    }
    if (fieldValue is List &&
        fieldValue.length >= 2 &&
        metadata['type'] == 'many2one') {
      return fieldValue[1].toString();
    }
    if (metadata['type'] == 'float') {
      double floatValue = fieldValue is num ? fieldValue.toDouble() : 0.0;
      if (widgetType == 'timesheet_uom') {
        return TimesheetUomTimerWidget(
          name: fieldLabel,
          value: floatValue,
          viewType: 'tree',
        );
      }
      return FloatFieldWidget(
        name: '',
        value: floatValue,
      );
    }
    if (metadata['type'] == 'selection' &&
        metadata['pythonAttributes']['selection'] != null) {
      final selection = metadata['pythonAttributes']['selection'] as List<dynamic>;
      String displayValue = '';
      for (var option in selection) {
        if (option[0].toString() == fieldValue.toString()) {
          displayValue = option[1].toString();
          break;
        }
      }
      print('Field: $fieldName, WidgetType: $widgetType, Selection: $selection, FieldValue: $fieldValue, DisplayValue: $displayValue'); // Debug log
      if (widgetType == 'priority') {
        print('Rendering PriorityWidget for $fieldName'); // Confirm widget rendering
        return PriorityWidget(
          value: displayValue,
          selection: selection,
        );
      }
      return displayValue;
    }
// Inside getFieldDisplay method, add or update this condition before the generic boolean handling
    if (metadata['type'] == 'boolean' && widgetType == 'project_is_favorite') {
      bool favoriteValue = fieldValue is bool ? fieldValue : false;
      return ProjectFavoriteWidget(
        isFavorite: favoriteValue,
        onChanged: (newValue) {
          setState(() {
            data[fieldName] = newValue;
            _updateRecord(data['id'], {fieldName: newValue});
          });
        },
        readonly: true, // Set to true for tree view to prevent editing
      );
    }
// Handle one2many or list_activity widget
    if (metadata['type'] == 'one2many' && widgetType == 'list_activity') {
      return ListActivityWidget(
        fieldName: fieldName,
        value: fieldValue is List ? fieldValue : [],
        relationModel: metadata['pythonAttributes']['relation'] ?? "",
        client: _odooClientController.client,
      );
    }

    // Handle one2many with many2many_tags widget
    if (metadata['type'] == 'one2many' && widgetType == 'many2many_tags') {
      return FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchMany2ManyOptions(
            metadata['pythonAttributes']['relation'], fieldValue as List<dynamic>),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return Text('Error: ${snapshot.error}');
          }
          final options = snapshot.data!;
          return Many2ManyTagsWidget(
            name: fieldName,
            values: fieldValue,
            options: options,
            onValuesChanged: (newValues) {
              setState(() {
                data[fieldName] = newValues;
              });
            },
          );
        },
      );
    }
    if (metadata['type'] == 'boolean' && widgetType == 'boolean_toggle') {
      bool toggleValue = fieldValue is bool ? fieldValue : false;
      return BooleanToggleFieldWidget(
        name: fieldLabel,
        value: toggleValue,
        onChanged: (newValue) {
          setState(() {
            data[fieldName] = newValue;
            _updateRecord(data['id'], {fieldName: newValue});
          });
        },
        readonly: true, // Keep readonly for tree view
        viewType: 'tree', // Specify tree view layout
      );
    }
    if (metadata['type'] == 'char' || widgetType == 'char_with_placeholder_field') {
      String charValue = fieldValue is String ? fieldValue : '';
      String hintText = xmlAttrs?.firstWhere(
            (attr) => attr['name'] == 'placeholder',
        orElse: () => {'value': 'Enter $fieldLabel'},
      )['value'] ?? 'Enter $fieldLabel';
      return CharWithPlaceholderFieldWidget(
        name: fieldLabel,
        value: charValue,
        hintText: hintText,
        readOnly: true,
        viewType: 'tree',
      );
    }

    if (metadata['type'] == 'char' && widgetType == 'CopyClipboardChar') {
      String charValue = fieldValue is String ? fieldValue : '';
      return CopyClipboardChar(
        name: fieldLabel,
        value: charValue,
        readonly: widget.readonly,
        viewType: 'tree',
      );
    }

    if (metadata['type'] == 'char' || widgetType == 'image_url') {
      String urlValue = fieldValue is String ? fieldValue : '';
      if (widgetType == 'image_url' || (metadata['type'] == 'char' && _isImageUrl(urlValue))) {
        return ImageUrlFieldWidget(
          value: urlValue,
          baseUrl: 'http://10.0.20.232:8018', // Replace with your Odoo server URL
        );
      }
      String charValue = fieldValue is String ? fieldValue : '';
      String hintText = xmlAttrs?.firstWhere(
            (attr) => attr['name'] == 'placeholder',
        orElse: () => {'value': 'Enter $fieldLabel'},
      )['value'] ?? 'Enter $fieldLabel';
      return CharWithPlaceholderFieldWidget(
        name: fieldLabel,
        value: charValue,
        hintText: hintText,
        readOnly: true,
        viewType: 'tree',
      );
    }

    if (metadata['type'] == 'one2many' || widgetType == 'list_activity') {
      return ListActivityWidget(
        fieldName: fieldName,
        value: fieldValue is List ? fieldValue : [],
        relationModel: metadata['pythonAttributes']['relation'] ?? "",
        client: _odooClientController.client,
      );
    }
    if (metadata['type'] == 'many2one' && widgetType == 'so_line_field') {
      dynamic valueId = (fieldValue is List && fieldValue.length >= 2)
          ? fieldValue[0]
          : null;
      String displayValue = (fieldValue is List && fieldValue.length >= 2)
          ? fieldValue[1].toString()
          : '';

      return FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchMany2OneOptions(
            metadata['pythonAttributes']['relation'] ?? '',
            valueId != null ? [valueId] : []),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
          final options = snapshot.data ?? [
            if (valueId != null) {'id': valueId, 'name': displayValue}
          ];

          return SoLineFieldWidget(
            name: fieldLabel,
            value: valueId,
            options: options,
            onValueChanged: (newValue) {
              setState(() {
                data[fieldName] = newValue != null
                    ? [newValue, _getDisplayNameFromOptions(newValue, options)]
                    : false;
                if (newValue != null) {
                  _updateRecord(data['id'], {fieldName: newValue});
                }
              });
            },
            viewType: 'tree',
            readonly: true, // Set to true for tree view to prevent editing
            hintText: 'Select $fieldLabel',
            odooClientController: _odooClientController,
          );
        },
      );
    }


    // if (metadata['type'] == 'many2many' || widgetType == 'many2many_tags') {
    //   return FutureBuilder<List<Map<String, dynamic>>>(
    //     future: _fetchMany2ManyOptions(metadata['pythonAttributes']['relation'],
    //         fieldValue as List<dynamic>),
    //     builder: (context, snapshot) {
    //       if (snapshot.connectionState == ConnectionState.waiting) {
    //         return const CircularProgressIndicator();
    //       }
    //       if (snapshot.hasError || !snapshot.hasData) {
    //         return Text('Error: ${snapshot.error}');
    //       }
    //       final options = snapshot.data!;
    //       return Many2ManyTagsWidget(
    //         name: fieldName,
    //         values: fieldValue,
    //         options: options,
    //         onValuesChanged: (newValues) {
    //           setState(() {
    //             data[fieldName] = newValues;
    //           });
    //         },
    //       );
    //     },
    //   );
    // }
    if (metadata['type'] == 'many2many' || widgetType == 'many2many_tags' || widgetType == 'many2many_tag_skills') {
      return FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchMany2ManyOptions(
            metadata['pythonAttributes']['relation'], fieldValue as List<dynamic>),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return Text('Error: ${snapshot.error}');
          }
          final options = snapshot.data!;
          if (widgetType == 'many2many_tag_skills') {
            return Many2ManyTagSkillsWidget(
              name: fieldName,
              values: fieldValue,
              options: options,
              onValuesChanged: (newValues) {
                setState(() {
                  data[fieldName] = newValues;
                });
              },
              readonly: widget.readonly,
              viewType: 'tree',
            );
          }
          return Many2ManyTagsWidget(
            name: fieldName,
            values: fieldValue,
            options: options,
            onValuesChanged: (newValues) {
              setState(() {
                data[fieldName] = newValues;
              });
            },
          );
        },
      );
    }
    if (metadata['type'] == 'many2one') {
      dynamic valueId = (fieldValue is List && fieldValue.length >= 2)
          ? fieldValue[0]
          : null;
      String displayValue = (fieldValue is List && fieldValue.length >= 2)
          ? fieldValue[1].toString()
          : '';

      return FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchMany2OneOptions(
            metadata['pythonAttributes']['relation'] ?? '',
            valueId != null ? [valueId] : []),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
          final options = snapshot.data ?? [
            if (valueId != null) {'id': valueId, 'name': displayValue}
          ];

          return Many2OneFieldWidget(
            name: fieldLabel,
            value: valueId,
            options: options,
            onValueChanged: (newValue) {
              setState(() {
                data[fieldName] = newValue != null
                    ? [newValue, _getDisplayNameFromOptions(newValue, options)]
                    : false;
                if (newValue != null) {
                  _updateRecord(data['id'], {fieldName: newValue});
                }
              });
            },
            viewType: 'tree',
            readonly: true, // Set to true for tree view to prevent editing
            hintText: 'Select $fieldLabel',
          );
        },
      );
    }


    if (metadata['type'] == 'one2many') {
      return ListActivityWidget(
        fieldName: fieldName,
        value: fieldValue is List ? fieldValue : [],
        relationModel: metadata['pythonAttributes']['relation'] ?? "",
        client: _odooClientController.client,
      );
    }

    if (widgetType == 'color_picker') {
      int colorValue = int.tryParse(fieldValue.toString()) ?? 0;
      return ColorPickerWidget(
        initialColorValue: colorValue,
        viewType: 'tree',
      );
    }

    if (metadata['type'] == 'html') {
      return SizedBox(
        height: 76,
        child: SingleChildScrollView(
          child: HtmlFieldWidget(
            name: fieldLabel,
            value: fieldValue.toString(),
          ),
        ),
      );
    }

    if (widgetType == 'color') {
      String colorValue = fieldValue is String ? fieldValue : '#000000';
      return ColorFieldWidget(value: colorValue);
    }
    if (widgetType == 'progressbar') {
      double progressValue = fieldValue is num ? fieldValue.toDouble() : 0.0;
      return ProgressBarWidget(value: progressValue);
    }
    if (widgetType == 'image_url') {
      String urlValue = fieldValue is String ? fieldValue : '';
      return ImageUrlFieldWidget(value: urlValue);
    }
    if (widgetType == 'image') {
      String imageValue = fieldValue is String ? fieldValue : '';
      return ImageFieldWidget(
        name: fieldLabel,
        value: imageValue,
        isReadonly: true,
        viewType: 'tree',
      );
    }
    if (widgetType == 'handle') {
      int sequenceValue = int.tryParse(fieldValue.toString()) ?? 0;
      return HandleWidget(sequence: sequenceValue);
    }
    if (widgetType == 'boolean_favorite') {
      bool favoriteValue = fieldValue is bool ? fieldValue : false;
      return BooleanFavoriteWidget(isFavorite: favoriteValue);
    }

    if (widgetType == 'remaining_days') {
      num daysValue = fieldValue is num ? fieldValue : 0;
      return RemainingDaysWidget(
        value: daysValue,
        fieldLabel: fieldLabel,
      );
    }

    if (widgetType == 'badge') {
      // dev.log(
      //     "badgefieldName: $fieldName, widgetType: boolean_favorite, fieldValue: $fieldValue");
      String badgeValue = fieldValue.toString();
      return BadgeWidget(
        value: badgeValue,
        fieldLabel: fieldLabel,
      );
    }

    if (metadata['type'] == 'boolean') {
      bool boolValue = fieldValue is bool ? fieldValue : false;
      return Checkbox(
        value: boolValue,
        onChanged: (newValue) {
          if (newValue != null) {
            setState(() {
              data[fieldName] = newValue;
              _updateRecord(data['id'], {fieldName: newValue});
            });
          }
        },
      );
    }


    if (metadata['type'] == 'binary' || widgetType == 'image') {
      dynamic valueId = (fieldValue is List && fieldValue.length >= 2)
          ? fieldValue[0]
          : null;
      String displayName = (fieldValue is List && fieldValue.length >= 2)
          ? fieldValue[1].toString()
          : '';
      String binaryData = fieldValue is String ? fieldValue : ''; // Binary data (e.g., base64 string)

      return FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchMany2OneOptions(
            metadata['pythonAttributes']['relation'] ?? '',
            valueId != null ? [valueId] : []),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
          final options = snapshot.data ?? [
            if (valueId != null) {'id': valueId, 'name': displayName}
          ];

          return Many2OneAvatarUserWidget(
            name: fieldLabel,
            value: valueId,
            displayName: displayName,
            binaryData: binaryData,
            options: options,
            viewType: 'tree',
            readonly: true, // Set to true for tree view to prevent editing
          );
        },
      );
    }

    if (metadata['type'] == 'reference') {
      String referenceValue = fieldValue is String ? fieldValue : '';
      print('referenceValue: $referenceValue ');

      return ReferenceFieldWidget(
        value: referenceValue,
        onTap: () {
          // Implement navigation to the referenced record if needed
        },
        odooClientController: _odooClientController, // Pass the Odoo client
      );
    }

    if (metadata['type'] == 'date' && widgetType == 'appraisal_remaining_days') {
      String dateValue = fieldValue is String ? fieldValue : '';
      return AppraisalRemainingDaysWidget(
        fieldLabel: fieldLabel,
        value: dateValue,
        readonly: widget.readonly,
        viewType: 'tree',
      );
    }
    if (metadata['type'] == 'many2one_reference') {
      dynamic valueId = fieldValue is int ? fieldValue : null;
      String relationModel = metadata['pythonAttributes']['model_field'] ?? ''; // The field storing the model name, e.g., 'res_model'
      String resIdField = metadata['pythonAttributes']['id_field'] ?? 'id'; // The field storing the record ID, e.g., 'res_id'

      return FutureBuilder<Map<String, dynamic>>(
        future: _fetchMany2oneReferenceOption(relationModel, valueId, data, resIdField),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
          final option = snapshot.data ?? {'id': valueId, 'name': 'Unnamed'};

          return Many2oneReferenceFieldWidget(
            name: fieldLabel,
            value: valueId,
            displayName: option['name']?.toString() ?? 'Unnamed',
            relationModel: relationModel,
            options: [option],
            viewType: 'tree',
            readonly: true,
            hintText: 'Select $fieldLabel',
            odooClientController: _odooClientController,
          );
        },
      );
    }

    if (metadata['type'] == 'datetime' && widgetType == 'timeless_date') {
      String dateValue = fieldValue is String ? fieldValue : '';
      return TimelessDateWidget(
        name: fieldLabel,
        value: dateValue,
        viewType: 'tree',
        readonly: widget.readonly,
      );
    }


    if (widgetType != null) {
      // dev.log('Unsupported widget type: $widgetType for field: $fieldName');
      return const Text('Unsupported');
    }

    return fieldValue.toString();
  }

  Future<void> _updateRecord(int id, Map<String, dynamic> values) async {
    try {
      final success = await update(id);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Record updated successfully')),
        );
        _refreshDataList();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update record: $e')),
        );
      }
    }
  }


// Helper function to fetch many2one options
  Future<List<Map<String, dynamic>>> _fetchMany2OneOptions(String model, List<dynamic> ids) async {
    if (model.isEmpty || ids.isEmpty) return [];
    try {
      final result = await _odooClientController.client.callKw({
        'model': model,
        'method': 'search_read',
        'args': [
          [['id', 'in', ids]],
        ],
        'kwargs': {
          'fields': ['id', 'name'],
        },
      });
      return (result as List<dynamic>)
          .map((item) => {
        'id': item['id'],
        'name': item['name'] ?? 'Unnamed',
      })
          .toList();
    } catch (e) {
      // dev.log('Failed to fetch many2one options: $e');
      return [];
    }
  }

// Helper function to get display name from options
  String _getDisplayNameFromOptions(dynamic valueId, List<Map<String, dynamic>> options) {
    for (var option in options) {
      if (option['id'] == valueId) {
        return option['name']?.toString() ?? 'Unnamed';
      }
    }
    return 'Unnamed';
  }


  Future<void> _refreshDataList() async {
    try {
      final updatedData = await search(
        [],
        fields: _visibleFields,
        limit: 50, // Match your original limit if applicable
      );
      if (mounted) {
        setState(() {
          widget.dataList.clear();
          widget.dataList.addAll(updatedData);
        });
      }
    } catch (e) {
      // log('Failed to refresh data: $e');
    }
  }

  Future<List<Map<String, dynamic>>> _fetchMany2ManyOptions(String model, List<dynamic> ids) async {
    if (ids.isEmpty) return [];
    try {
      final result = await _odooClientController.client.callKw({
        'model': model,
        'method': 'search_read',
        'args': [
          [['id', 'in', ids]],
        ],
        'kwargs': {
          'fields': ['id', 'name'],
        },
      });
      return (result as List<dynamic>)
          .map((item) => {
        'id': item['id'],
        'name': item['name'] ?? 'Unnamed',
      })
          .toList();
    } catch (e) {
      return [];
    }
  }

  bool isFieldVisibleByDefault(Map<String, dynamic> metadata) {
    final xmlAttrs = metadata['xmlAttributes'] as List<dynamic>?;
    final columnInvisible = xmlAttrs?.firstWhere(
          (attr) => attr['name'] == 'column_invisible',
      orElse: () => {'value': 'False'},
    )['value'];
    final optional = xmlAttrs?.firstWhere(
          (attr) => attr['name'] == 'optional',
      orElse: () => {'value': null},
    )['value'];
    final widgetType = xmlAttrs?.firstWhere(
          (attr) => attr['name'] == 'widget',
      orElse: () => {'value': null},
    )['value'];

    // Define allowed widget types
    const allowedWidgetTypes = {
      'color',
      'progressbar',
      'image_url',
      'image',
      'handle',
      'boolean_favorite',
      'color_picker',
      'many2many_tags',
      'many2many_tag_skills',
      'priority',
      'char_with_placeholder_field',
      'boolean_toggle',
      'timesheet_uom_timer',// Add this
      'many2one_avatar_user',
      'appraisal_remaining_days'// Add this
    };
    print('innnnnnnnnnnnnnnnnn $columnInvisible $optional $widgetType');
    return (columnInvisible != 'True' && columnInvisible != '1') &&
        optional != 'hide' &&
        (widgetType == null || allowedWidgetTypes.contains(widgetType));
  }

  bool isFieldVisible(Map<String, dynamic> metadata) {
    final xmlAttrs = metadata['xmlAttributes'] as List<dynamic>?;
    final columnInvisible = xmlAttrs?.firstWhere(
          (attr) => attr['name'] == 'column_invisible',
      orElse: () => {'value': 'False'},
    )['value'];
    return _visibleFields.contains(metadata['name']) && (columnInvisible != 'True' && columnInvisible != '1');
  }

  void _showFieldSelectorDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Select Fields'),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView(
                  shrinkWrap: true,
                  children: widget.fieldMetadata.where((metadata) {
                    final xmlAttrs =
                    metadata['xmlAttributes'] as List<dynamic>?;
                    final columnInvisible = xmlAttrs?.firstWhere(
                          (attr) => attr['name'] == 'column_invisible',
                      orElse: () => {'value': 'False'},
                    )['value'];
                    return columnInvisible != 'True' && columnInvisible != '1';
                  }).map((metadata) {
                    final fieldName = metadata['name'] as String;
                    final xmlAttrs =
                    metadata['xmlAttributes'] as List<dynamic>?;
                    final fieldLabel = xmlAttrs?.firstWhere(
                          (attr) => attr['name'] == 'string',
                      orElse: () => {'value': null},
                    )['value'] ??
                        metadata['pythonAttributes']['string'] ??
                        fieldName;

                    return CheckboxListTile(
                      title: Text(fieldLabel),
                      value: _visibleFields.contains(fieldName),
                      onChanged: (bool? value) {
                        setDialogState(() {
                          if (value == true) {
                            if (!_visibleFields.contains(fieldName)) {
                              _visibleFields.add(fieldName);
                            }
                          } else {
                            _visibleFields.remove(fieldName);
                          }
                        });
                        setState(() {});
                      },
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            );
          },
        );
      },
    );
  }
  void _filterDataList(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredDataList = widget.dataList;
      } else {
        _filteredDataList = widget.dataList.where((data) {
          return _visibleFields.any((fieldName) {
            final fieldValue = data[fieldName];
            if (fieldValue == null) return false;
            if (fieldValue is List && fieldValue.length >= 2) {
              return fieldValue[1].toString().toLowerCase().contains(query.toLowerCase());
            }
            return fieldValue.toString().toLowerCase().contains(query.toLowerCase());
          });
        }).toList();
      }
    });
  }
  String _getRecordName(Map<String, dynamic> data) {
    // dev.log("data  log : $data");
    if (data.containsKey('name') &&
        data['name'] is String &&
        data['name'].isNotEmpty) {
      return data['name'];
    }

    if (data.containsKey('complete_name') &&
        data['complete_name'] is String &&
        data['complete_name'].isNotEmpty) {
      return data['complete_name'];
    }
    if (data.containsKey('display_name') &&
        data['display_name'] is String &&
        data['display_name'].isNotEmpty) {
      return data['display_name'];
    }
    for (var metadata in widget.fieldMetadata) {
      if (metadata['type'] == 'many2one') {
        final fieldName = metadata['name'];
        final fieldValue = data[fieldName];
        if (fieldValue is List &&
            fieldValue.length >= 2 &&
            fieldValue[1] is String &&
            fieldValue[1].isNotEmpty) {
          return fieldValue[1];
        }
      }
    }
    return data['id']?.toString() ?? 'Unnamed';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Define theme here
    final visibleFieldCount = _visibleFields.length;
    final screenWidth = MediaQuery.of(context).size.width.isFinite
        ? MediaQuery.of(context).size.width
        : 400.0; // Fallback width

    // final screenWidth = MediaQuery.of(context).size.width;
    final fieldWidth = max(
        120.0,
        screenWidth /
            (visibleFieldCount <= maxFieldsPerScreen
                ? visibleFieldCount
                : maxFieldsPerScreen));


    SnackBar _buildCustomSnackBar(String message) {
      return SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.warning_rounded,
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.redAccent, // Error color for visibility
        behavior: SnackBarBehavior.floating, // Floating style
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), // Rounded corners
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), // Margin for floating effect
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 1), // Inner padding
        duration: const Duration(seconds: 3), // Visible for 3 seconds
        elevation: 8, // Shadow
        action: SnackBarAction(
          label: 'DISMISS',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 4,
        shadowColor: theme.colorScheme.shadow.withOpacity(0.2),
        title: _isSearchActive
            ? FadeTransition(
          opacity: _searchBarAnimation,
          child: TextField(
            controller: _searchController,
            autofocus: true,
            style: theme.textTheme.bodyLarge,
            decoration: InputDecoration(
              hintText: 'Search records...',
              hintStyle: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerHigh,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              suffixIcon: IconButton(
                icon: Icon(Icons.clear, color: theme.colorScheme.onSurface),
                onPressed: _toggleSearch,
              ),
            ),
          ),
        )
            : Text(
          widget.title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onPrimary,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: theme.colorScheme.onPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (!_isSearchActive)
            IconButton(
              icon: Icon(Icons.search, color: theme.colorScheme.onPrimary),
              onPressed: _toggleSearch,
            ),
          IconButton(
            icon: Icon(Icons.add, color: theme.colorScheme.onPrimary),
            onPressed: () async {

              if (widget.formdata == null || widget.formdata.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  _buildCustomSnackBar('Form data is missing'),
                );
                return;
              }
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FormView(
                    modelName: widget.modelname,
                    recordId: 0,
                    formData: widget.formdata,
                    name: 'New ${widget.title}',
                  ),
                ),
              );
              if (result == true && mounted) {
                _refreshDataList();
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.filter_list, color: theme.colorScheme.onPrimary),
            onPressed: _showFieldSelectorDialog,
          ),
        ],
        backgroundColor: ODOO_COLOR,
      ),
      body: _filteredDataList.isEmpty
      // body: widget.dataList.isEmpty
          ? const NoDataWidget()
          : Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            controller: _headerScrollController,
            child: Container(
              color: ODOO_COLOR.withOpacity(0.1),
              child: Row(
                children: widget.fieldMetadata
                    .where((metadata) => isFieldVisible(metadata) && metadata['type'] != 'properties')
                    .map((metadata) {
                  final xmlAttrs =
                  metadata['xmlAttributes'] as List<dynamic>?;
                  final pythonAttrs = metadata['pythonAttributes']
                  as Map<String, dynamic>?;
                  final xmlString = xmlAttrs?.firstWhere(
                        (attr) => attr['name'] == 'string',
                    orElse: () => {'value': null},
                  )['value'];
                  final headerString = xmlString ??
                      pythonAttrs?['string'] ??
                      metadata['name'];

                  return Container(
                    width: fieldWidth,
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      headerString,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                        color: ODOO_COLOR,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Ensure fieldWidth and visibleFieldCount are valid
                final double validFieldWidth = fieldWidth > 0 && fieldWidth.isFinite ? fieldWidth : 100.0; // Fallback width
                final int validVisibleFieldCount = visibleFieldCount > 0 ? visibleFieldCount : 1; // Fallback count
                final double calculatedWidth = validFieldWidth * validVisibleFieldCount;

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  controller: _bodyScrollController,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minWidth: calculatedWidth,
                      maxWidth: calculatedWidth.isFinite ? calculatedWidth : constraints.maxWidth,
                    ),
                    child: SizedBox(
                      width: calculatedWidth.isFinite ? calculatedWidth : constraints.maxWidth,
                      child: ReorderableListView(
                        // onReorder: (oldIndex, newIndex) {
                        //   setState(() {
                        //     if (newIndex > oldIndex) newIndex--;
                        //     final item = widget.dataList.removeAt(oldIndex);
                        //     widget.dataList.insert(newIndex, item);
                        //     for (int i = 0; i < widget.dataList.length; i++) {
                        //       widget.dataList[i]['sequence'] = i + 1;
                        //     }
                        //   });
                        // },
                        onReorder: (oldIndex, newIndex) {
                          setState(() {
                            if (newIndex > oldIndex) newIndex--;
                            final item = _filteredDataList.removeAt(oldIndex);
                            _filteredDataList.insert(newIndex, item);
                            for (int i = 0; i < _filteredDataList.length; i++) {
                              _filteredDataList[i]['sequence'] = i + 1;
                            }
                          });
                        },
                        // children: widget.dataList.asMap()
                        children: _filteredDataList.asMap().entries.map((entry) {
                          final index = entry.key;
                          final data = entry.value as Map<String, dynamic>;
                          final recordId = data['id'] as int?;
                          final recordName = _getRecordName(data);

                          return GestureDetector(
                            key: ValueKey(index),
                            onTap: () {

                              if (widget.formdata == null || widget.formdata.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  _buildCustomSnackBar('Form data is missing'),
                                );
                                return;
                              }

                              if (recordId != null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => FormView(
                                      modelName: widget.modelname,
                                      recordId: recordId,
                                      formData: widget.formdata,
                                      name: recordName,
                                      moduleName: widget.moduleName,
                                    ),
                                  ),
                                ).then((result) {
                                  if (result == true && mounted) {
                                    _refreshDataList();
                                  }
                                });
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Record ID not found')),
                                );
                              }
                            },
                            child: Container(
                              height: 120,
                              decoration: BoxDecoration(
                                border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
                              ),
                              child: Row(
                                children: widget.fieldMetadata
                                    .where((metadata) => isFieldVisible(metadata))
                                    .map((metadata) {
                                  final fieldName = metadata['name'];
                                  final displayValue = getFieldDisplay(data, fieldName);
                                  return Expanded(
                                    child: SizedBox(
                                      width: validFieldWidth, // Use validated fieldWidth
                                      child: Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: Row(
                                            children: [
                                              if (displayValue is Widget)
                                                displayValue
                                              else
                                                Text(
                                                  displayValue.toString(),
                                                  style: const TextStyle(
                                                    fontSize: 16.0,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  Future<Map<String, dynamic>> _fetchMany2oneReferenceOption(
      String modelField, dynamic valueId, Map<String, dynamic> data, String resIdField) async {
    if (modelField.isEmpty || valueId == null || !data.containsKey(modelField)) return {'id': valueId, 'name': 'Unnamed'};
    try {
      String model = data[modelField] ?? '';
      if (model.isEmpty) return {'id': valueId, 'name': 'Unnamed'};

      final result = await _odooClientController.client.callKw({
        'model': model,
        'method': 'search_read',
        'args': [
          [['id', '=', valueId]],
        ],
        'kwargs': {
          'fields': ['id', 'name', 'display_name'],
          'limit': 1,
        },
      });

      if (result is List && result.isNotEmpty) {
        return {
          'id': result[0]['id'],
          'name': result[0]['display_name'] ?? result[0]['name'] ?? 'Unnamed',
        };
      }
      return {'id': valueId, 'name': 'Unnamed'};
    } catch (e) {
      dev.log('Failed to fetch many2one_reference option: $e');
      return {'id': valueId, 'name': 'Unnamed'};
    }
  }
}

bool _isImageUrl(String value) {
  // Basic check for image URL patterns
  if (value.isEmpty || value == 'false') return false;
  // Check if the value ends with common image extensions
  final imageExtensions = ['.png', '.jpg', '.jpeg', '.gif', '.bmp', '.webp'];
  return imageExtensions.any((ext) => value.toLowerCase().endsWith(ext)) ||
      value.startsWith('http') ||
      value.startsWith('/'); // Relative paths are also considered
}