import 'dart:developer';
import 'dart:math';
import 'package:example_saleapp/pages/form_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import '../controller/odoo_crud_mixier.dart';
import '../controller/odooclient_manager_controller.dart';
import '../res/constants/app_colors.dart';
import '../res/odoo_res/odoo_data_types/boolean_field_widget.dart';
import '../res/odoo_res/odoo_data_types/html_field_widget.dart';
import '../res/odoo_res/odoo_data_types/reference.dart';
import '../res/odoo_res/odoo_xml_widget/boolean_favorite.dart';
import '../res/odoo_res/odoo_xml_widget/color.dart';
import '../res/odoo_res/odoo_xml_widget/color_picker.dart';
import '../res/odoo_res/odoo_xml_widget/handle.dart';
import '../res/odoo_res/odoo_xml_widget/image.dart';
import '../res/odoo_res/odoo_xml_widget/image_url.dart';
import '../res/odoo_res/odoo_xml_widget/list_activity.dart';
import '../res/odoo_res/odoo_xml_widget/many2many_tags.dart';
import '../res/odoo_res/odoo_xml_widget/progressbar.dart';
import '../res/widgets/no_data_image.dart';



class TreeViewScreen extends StatefulWidget {
  final String title;
  final List<dynamic> dataList;
  final String modelname;
  final String formdata;
  final List<Map<String, dynamic>> fieldMetadata;
  final int? viewId;
  final String? moduleName;


  const TreeViewScreen({
    Key? key,
    required this.title,
    required this.dataList,
    required this.modelname,
    required this.formdata,
    required this.fieldMetadata,
    this.moduleName,
    this.viewId,
  }) : super(key: key);

  @override
  State<TreeViewScreen> createState() => _TreeViewScreenState();
}

class _TreeViewScreenState extends State<TreeViewScreen> with OdooCrudMixin {
  late final OdooClientController _odooClientController;
  late List<String> _visibleFields;
  late ScrollController _headerScrollController;
  late ScrollController _bodyScrollController;
  final int maxFieldsPerScreen = 3;

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

    _odooClientController = OdooClientController();
    _initializeOdooClient();
    _headerScrollController = ScrollController();
    _bodyScrollController = ScrollController();

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
        .where((metadata) => isFieldVisibleByDefault(metadata))
        .map((metadata) => metadata['name'] as String)
        .toList();
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
    super.dispose();
  }

  Map<String, dynamic>? getFieldMetadata(String fieldName) {
    try {
      return widget.fieldMetadata.firstWhere((metadata) => metadata['name'] == fieldName);
    } catch (e) {
      return null;
    }
  }

  dynamic getFieldDisplay(Map<String, dynamic> data, String fieldName) {
    final metadata = getFieldMetadata(fieldName);
    if (metadata == null) return '';

    dynamic fieldValue = data[fieldName];

    if (fieldValue == null || fieldValue.toString().isEmpty || fieldValue == false) {
      return '';
    }

    if (fieldValue is List && fieldValue.length >= 2 && metadata['type'] == 'many2one') {
      return fieldValue[1].toString();
    }

    if (metadata['type'] == 'selection' && metadata['pythonAttributes']['selection'] != null) {
      final selection = metadata['pythonAttributes']['selection'] as List<dynamic>;
      for (var option in selection) {
        if (option[0].toString() == fieldValue.toString()) {
          return option[1].toString();
        }
      }
    }

    if (metadata['type'] == 'many2many' && metadata['widget'] == 'many2many_tags') {
      return FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchMany2ManyOptions(metadata['pythonAttributes']['relation'], fieldValue as List<dynamic>),
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

    if (metadata['type'] == 'one2many') {
      return ListActivityWidget(
        fieldName: fieldName,
        value: fieldValue is List ? fieldValue : [],
        relationModel: metadata['pythonAttributes']['relation'] ?? "",
        client: _odooClientController.client,
      );
    }

    if (metadata['widget'] == 'color_picker') {
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
            name: metadata['pythonAttributes']['string'] ?? fieldName,
            value: fieldValue.toString(),
          ),
        ),
      );
    }

    final xmlAttrs = metadata['xmlAttributes'] as List<dynamic>?;
    final widgetType = xmlAttrs?.firstWhere(
          (attr) => attr['name'] == 'widget',
      orElse: () => {'value': null},
    )['value'];

    final fieldLabel = metadata['pythonAttributes']['string'] ?? fieldName;

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

    if (metadata['type'] == 'boolean') {
      bool boolValue = fieldValue is bool ? fieldValue : false;
      return BooleanFieldWidget(
        value: boolValue,
        onChanged: (newValue) {
          setState(() {
            data[fieldName] = newValue;
            _updateRecord(data['id'], {fieldName: newValue});
          });
        },
        viewType: 'list',
      );
    }
    if (metadata['type'] == 'reference') {
      String referenceValue = fieldValue is String ? fieldValue : '';
      return ReferenceFieldWidget(
        value: referenceValue,
        onTap: () {},
      );
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

  Future<void> _deleteRecord(int id, int index) async {
    try {
      final success = await delete(id);
      if (success && mounted) {
        setState(() {
          widget.dataList.removeAt(index);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Record deleted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete record: $e')),
        );
      }
    }
  }

  Future<void> _refreshDataList() async {
    try {
      final updatedData = await search(
        [],
        fields: _visibleFields,
        limit: 50,
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
    final columnInvisible = xmlAttrs
        ?.firstWhere(
          (attr) => attr['name'] == 'column_invisible',
      orElse: () => {'value': 'False'},
    )['value'];
    final optional = xmlAttrs
        ?.firstWhere(
          (attr) => attr['name'] == 'optional',
      orElse: () => {'value': null},
    )['value'];

    return (columnInvisible != 'True' && columnInvisible != '1') && optional != 'hide';
  }

  bool isFieldVisible(Map<String, dynamic> metadata) {
    return _visibleFields.contains(metadata['name']);
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
                  children: widget.fieldMetadata
                      .where((metadata) {
                    final xmlAttrs = metadata['xmlAttributes'] as List<dynamic>?;
                    final columnInvisible = xmlAttrs
                        ?.firstWhere(
                          (attr) => attr['name'] == 'column_invisible',
                      orElse: () => {'value': 'False'},
                    )['value'];
                    return columnInvisible != 'True' && columnInvisible != '1';
                  })
                      .map((metadata) {
                    final fieldName = metadata['name'] as String;
                    final xmlAttrs = metadata['xmlAttributes'] as List<dynamic>?;
                    final fieldLabel = xmlAttrs
                        ?.firstWhere(
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

  String _getRecordName(Map<String, dynamic> data) {
    if (data.containsKey('name') && data['name'] is String && data['name'].isNotEmpty) {
      return data['name'];
    }
    if (data.containsKey('display_name') && data['display_name'] is String && data['display_name'].isNotEmpty) {
      return data['display_name'];
    }
    for (var metadata in widget.fieldMetadata) {
      if (metadata['type'] == 'many2one') {
        final fieldName = metadata['name'];
        final fieldValue = data[fieldName];
        if (fieldValue is List && fieldValue.length >= 2 && fieldValue[1] is String && fieldValue[1].isNotEmpty) {
          return fieldValue[1];
        }
      }
    }
    return data['id']?.toString() ?? 'Unnamed';
  }

  @override
  Widget build(BuildContext context) {
    final visibleFieldCount = _visibleFields.length;
    final screenWidth = MediaQuery.of(context).size.width;
    final fieldWidth = max(
        120.0,
        screenWidth / (visibleFieldCount <= maxFieldsPerScreen ? visibleFieldCount : maxFieldsPerScreen)
    );

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          widget.title,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: ODOO_COLOR,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FormView(
                    modelName: widget.modelname,
                    recordId: 0,
                    // viewId: widget.viewId,
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
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: _showFieldSelectorDialog,
          ),
        ],
      ),
      body: widget.dataList.isEmpty
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
                    .where((metadata) => isFieldVisible(metadata))
                    .map((metadata) {
                  final xmlAttrs = metadata['xmlAttributes'] as List<dynamic>?;
                  final pythonAttrs = metadata['pythonAttributes'] as Map<String, dynamic>?;
                  final xmlString = xmlAttrs
                      ?.firstWhere(
                        (attr) => attr['name'] == 'string',
                    orElse: () => {'value': null},
                  )['value'];
                  final headerString = xmlString ?? pythonAttrs?['string'] ?? metadata['name'];

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
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              controller: _bodyScrollController,
              child: SizedBox(
                width: fieldWidth * visibleFieldCount,
                child: ReorderableListView(
                  onReorder: (oldIndex, newIndex) {
                    setState(() {
                      if (newIndex > oldIndex) newIndex--;
                      final item = widget.dataList.removeAt(oldIndex);
                      widget.dataList.insert(newIndex, item);
                      for (int i = 0; i < widget.dataList.length; i++) {
                        widget.dataList[i]['sequence'] = i + 1;
                      }
                    });
                  },
                  children: widget.dataList.asMap().entries.map((entry) {
                    final index = entry.key;
                    final data = entry.value as Map<String, dynamic>;
                    final recordId = data['id'] as int?;
                    final recordName = _getRecordName(data);

                    return GestureDetector(
                      key: ValueKey(index),
                      onTap: () {
                        if (recordId != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FormView(
                                modelName: widget.modelname,
                                recordId: recordId,
                                // viewId: widget.viewId,
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
                        height: 100,
                        decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
                        ),
                        child: Row(
                          children: widget.fieldMetadata
                              .where((metadata) => isFieldVisible(metadata))
                              .map((metadata) {
                            final fieldName = metadata['name'];
                            final displayValue = getFieldDisplay(data, fieldName);
                            return SizedBox(
                              width: fieldWidth,
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
                            );
                          }).toList(),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}