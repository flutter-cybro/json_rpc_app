import 'dart:developer';
import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../models/local_nodel/one2many_data.dart';
import '../../../services/isar_service.dart';
import 'many2many_field_widget.dart';
import 'many2one_field_widget.dart';

class One2ManyFieldWidget extends StatefulWidget {
  final String name;
  final String mainModel;
  final String relationModel;
  final String relationField;
  final String fieldName;
  final int mainRecordId;
  final int? tempRecordId;
  final dynamic client;
  final Function(List<dynamic>) onUpdate;
  final List<Map<String, dynamic>> relatedFields;
  final String viewType;
  final bool readonly;

  const One2ManyFieldWidget({
    required this.name,
    required this.relationModel,
    required this.relationField,
    required this.fieldName,
    required this.mainRecordId,
    this.tempRecordId,
    required this.client,
    required this.onUpdate,
    required this.relatedFields,
    this.viewType = 'form',
    required this.mainModel,
    this.readonly = false,
  });

  @override
  _One2ManyFieldWidgetState createState() => _One2ManyFieldWidgetState();
}

class _One2ManyFieldWidgetState extends State<One2ManyFieldWidget> {
  List<Map<String, dynamic>> relatedRecords = [];
  List<Map<String, dynamic>> allFieldNames = [];
  Map<int, List<Map<String, dynamic>>> many2manyOptions = {};
  Map<String, List<Map<String, dynamic>>> many2oneOptions = {};
  bool isLoading = true;
  String? errorMessage;
  late IsarService isarService;

  @override
  void initState() {
    super.initState();
    isarService = IsarService();
    if (widget.mainRecordId == 0 && widget.tempRecordId != null) {
      _fetchLocalRecords();
    } else {
      _fetchRelatedRecords();
    }
    print("name  :  ${widget.name}");
    print("mainModel  :  ${widget.mainModel}");
    print("relationModel  :  ${widget.relationModel}");
    print("relationField  :  ${widget.relationField}");
    print("mainRecordId  :  ${widget.mainRecordId}");
    print("relationField  :  ${widget.relatedFields}");
  }

  Future<void> _fetchLocalRecords() async {
    if (widget.tempRecordId == null) return;
    setState(() => isLoading = true);
    try {
      final localRecords = await isarService.getRecordsByTempId(
        widget.tempRecordId!,
        fieldName: widget.fieldName,
      );
      setState(() {
        relatedRecords = localRecords
            .map((record) => jsonDecode(record.data) as Map<String, dynamic>)
            .toList();
        isLoading = false;
      });

      await _fetchFieldDefinitionsAndOptions();
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load local data: $e';
      });
    }
  }

  Future<void> _fetchFieldDefinitionsAndOptions() async {
    try {
      // Fetch field definitions
      final fieldNames = widget.relatedFields.map((f) => f['name']).toList();
      final fieldsResponse = await widget.client.callKw({
        'model': widget.relationModel,
        'method': 'fields_get',
        'args': [
          fieldNames,
          ['domain', 'relation', 'type', 'string']
        ],
        'kwargs': {},
      });

      if (fieldsResponse is Map<String, dynamic>) {
        allFieldNames = fieldsResponse.entries.map((entry) {
          // Handle domain field which can be either String or List
          dynamic domain = entry.value['domain'];
          String domainString = '[]';
          if (domain is String) {
            domainString = domain;
          } else if (domain is List) {
            domainString = jsonEncode(domain);
          }

          return {
            'name': entry.key as String,
            'type': entry.value['type'] as String?,
            'string': entry.value['string'] as String? ?? entry.key,
            'relation': entry.value['relation'] as String?,
            'domain': domainString, // Ensure domain is always a string
          };
        }).toList();
      } else {
        throw Exception("Failed to fetch field definitions");
      }

      // Fetch many2many and many2one options
      for (var field in widget.relatedFields) {
        final fieldDef = allFieldNames.firstWhere(
          (f) => f['name'] == field['name'],
          orElse: () => <String, dynamic>{
            'name': field['name'],
            'type': field['type'] ?? 'char',
            'string': field['name'],
            'domain': field['domain'],
          },
        );

        if (fieldDef['type'] == 'many2many' && fieldDef['relation'] != null) {
          final relatedModel = fieldDef['relation'] as String;
          final domain = field['domain'] == '[]'
              ? fieldDef['domain']
              : (field['domain'] ?? fieldDef['domain'] ?? '[]');
          final parsedDomain =
              await _resolveDomainVariables(domain, widget.relationModel);

          log("parent_model : ${widget.mainModel} \n"
              "parent_record_id : ${widget.mainRecordId}\n"
              "domain : ${domain}\n"
              "field_relation_model : ${relatedModel}\n"
              "parent_relational_model : ${widget.relationModel}\n");

          if (widget.mainModel == 'product.template') {
            for (var record in relatedRecords) {
              final parentRelationRecord = record['id'] ?? record.hashCode;

              try {
                final optionsResponse = await widget.client.callKw({
                  'model': 'ir.actions.act_window',
                  'method': 'get_domain_condition_values',
                  'args': [[]],
                  'kwargs': {
                    'parent_model': widget.mainModel,
                    'parent_record_id': widget.mainRecordId,
                    'domain': domain,
                    'target_model': relatedModel,
                    'field_relation_model': false,
                    'parent_relational_model': widget.relationModel,
                    'parent_relation_record': parentRelationRecord,
                  },
                });

                List<Map<String, dynamic>> recordOptions = [];
                if (optionsResponse is List<dynamic>) {
                  recordOptions = optionsResponse
                      .map((record) => Map<String, dynamic>.from(record))
                      .toList();
                } else if (optionsResponse is Map<String, dynamic>) {
                  if (optionsResponse['result'] is List<dynamic>) {
                    recordOptions = (optionsResponse['result'] as List<dynamic>)
                        .map((record) => Map<String, dynamic>.from(record))
                        .toList();
                  } else if (optionsResponse['records'] is List<dynamic>) {
                    recordOptions =
                        (optionsResponse['records'] as List<dynamic>)
                            .map((record) => Map<String, dynamic>.from(record))
                            .toList();
                  }
                }

                recordOptions = recordOptions.fold<List<Map<String, dynamic>>>(
                  [],
                  (uniqueList, option) {
                    if (!uniqueList.any((item) => item['id'] == option['id'])) {
                      uniqueList.add(option);
                    }
                    return uniqueList;
                  },
                );

                many2manyOptions[parentRelationRecord] = recordOptions;
                log("Assigned ${recordOptions.length} options to many2manyOptions[$parentRelationRecord]");
              } catch (e) {
                log("Error fetching many2many options for record $parentRelationRecord: $e");
                many2manyOptions[parentRelationRecord] = [];
              }
            }
          } else {
            final optionsResponse = await widget.client.callKw({
              'model': 'ir.actions.act_window',
              'method': 'get_domain_condition_values',
              'args': [[]],
              'kwargs': {
                'parent_model': widget.mainModel,
                'parent_record_id': widget.mainRecordId,
                'domain': domain,
                'field_relation_model': relatedModel,
              },
            });

            print("optionsResponse  :$optionsResponse");

            List<Map<String, dynamic>> aggregatedOptions = [];
            if (optionsResponse is List<dynamic>) {
              aggregatedOptions = optionsResponse
                  .map((record) => Map<String, dynamic>.from(record))
                  .toList();
            } else if (optionsResponse is Map<String, dynamic>) {
              if (optionsResponse['result'] is List<dynamic>) {
                aggregatedOptions = (optionsResponse['result'] as List<dynamic>)
                    .map((record) => Map<String, dynamic>.from(record))
                    .toList();
              } else if (optionsResponse['records'] is List<dynamic>) {
                aggregatedOptions =
                    (optionsResponse['records'] as List<dynamic>)
                        .map((record) => Map<String, dynamic>.from(record))
                        .toList();
              }
            }

            if (relatedRecords.isNotEmpty) {
              for (var record in relatedRecords) {
                final recordId = record['id'] ?? record.hashCode;
                many2manyOptions[recordId] = aggregatedOptions;
                log("Assigned ${aggregatedOptions.length} options to many2manyOptions[$recordId]");
              }
            } else {
              many2manyOptions[0] = aggregatedOptions;
              log("Assigned ${aggregatedOptions.length} options to many2manyOptions[0]");
            }
          }
        } else if (fieldDef['type'] == 'many2one' &&
            fieldDef['relation'] != null) {
          final relatedModel = fieldDef['relation'] as String;
          final domain = field['domain'] ?? '[]';

          final optionsResponse = await widget.client.callKw({
            'model': relatedModel,
            'method': 'search_read',
            'args': [],
            'kwargs': {
              'fields': ['id', 'name'],
            },
          });

          if (optionsResponse is List<dynamic>) {
            many2oneOptions[field['name']] = optionsResponse
                .map((record) => Map<String, dynamic>.from(record))
                .toList();
          }
        }
      }

      setState(() => isLoading = false);
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load field definitions or options: $e';
      });
    }
  }

  Future<void> _fetchRelatedRecords() async {
    try {
      if (widget.mainRecordId == 0) {
        return _fetchLocalRecords();
      }
      final fieldNames = widget.relatedFields.map((f) => f['name']).toList();
      final fieldsResponse = await widget.client.callKw({
        'model': widget.relationModel,
        'method': 'fields_get',
        'args': [
          fieldNames,
          ['domain', 'relation', 'type', 'string']
        ],
        'kwargs': {},
      });

      if (fieldsResponse is Map<String, dynamic>) {
        allFieldNames = fieldsResponse.entries.map((entry) {
          // Handle domain field which can be either String or List
          dynamic domain = entry.value['domain'];
          String domainString = '[]';
          if (domain is String) {
            domainString = domain;
          } else if (domain is List) {
            domainString = jsonEncode(domain);
          }

          return {
            'name': entry.key as String,
            'type': entry.value['type'] as String?,
            'string': entry.value['string'] as String? ?? entry.key,
            'relation': entry.value['relation'] as String?,
            'domain': domainString, // Ensure domain is always a string
          };
        }).toList();
      } else {
        throw Exception("Failed to fetch field definitions");
      }

      final validFieldNames = allFieldNames.map((f) => f['name']).toList();
      final recordsResponse = await widget.client.callKw({
        'model': widget.relationModel,
        'method': 'search_read',
        'args': [],
        'kwargs': {
          'domain': [
            [widget.relationField, '=', widget.mainRecordId]
          ],
          'fields': validFieldNames.isNotEmpty
              ? validFieldNames
              : widget.relatedFields.map((f) => f['name']).toList(),
        },
      });

      if (recordsResponse is List<dynamic>) {
        relatedRecords = recordsResponse
            .map((record) => Map<String, dynamic>.from(record))
            .toList();
        for (var record in relatedRecords) {
          print(
              "Relation Model ID: ${record['id']} for ${widget.relationModel}");
        }
      } else {
        throw Exception("Failed to fetch related records");
      }

      for (var field in widget.relatedFields) {
        final fieldDef = allFieldNames.firstWhere(
          (f) => f['name'] == field['name'],
          orElse: () => <String, String?>{
            'name': field['name'] as String?,
            'type': field['type'] as String? ?? 'char',
            'string': field['name'] as String?,
            'domain': field['domain'],
          },
        );

        if (fieldDef['type'] == 'many2many' && fieldDef['relation'] != null) {
          final relatedModel = fieldDef['relation'] as String;
          final domain = field['domain'] == '[]'
              ? fieldDef['domain']
              : (field['domain'] ?? fieldDef['domain'] ?? '[]');
          final parsedDomain =
              await _resolveDomainVariables(domain, widget.relationModel);

          if (widget.mainModel == 'product.template') {
            for (var record in relatedRecords) {
              final parentRelationRecord = record['id'];

              log("parent_model : ${widget.mainModel} \n"
                  "parent_record_id : ${widget.mainRecordId}\n"
                  "domain : ${domain}\n"
                  "field_relation_model : ${relatedModel}\n"
                  "parent_relational_model : ${widget.relationModel}\n"
                  "parent_relation_record : ${parentRelationRecord ?? 'No related records'}");

              try {
                final optionsResponse = await widget.client.callKw({
                  'model': 'ir.actions.act_window',
                  'method': 'get_domain_condition_values',
                  'args': [[]],
                  'kwargs': {
                    'parent_model': widget.mainModel,
                    'parent_record_id': widget.mainRecordId,
                    'domain': domain,
                    'target_model': relatedModel,
                    'field_relation_model': false,
                    'parent_relational_model': widget.relationModel,
                    'parent_relation_record': parentRelationRecord,
                  },
                });

                print("optionsResponse type: ${optionsResponse.runtimeType}");
                print("optionsResponse value: $optionsResponse");

                List<Map<String, dynamic>> recordOptions = [];

                if (optionsResponse is List<dynamic>) {
                  recordOptions = optionsResponse
                      .map((record) => Map<String, dynamic>.from(record))
                      .toList();
                } else if (optionsResponse is Map<String, dynamic>) {
                  if (optionsResponse['result'] is List<dynamic>) {
                    recordOptions = (optionsResponse['result'] as List<dynamic>)
                        .map((record) => Map<String, dynamic>.from(record))
                        .toList();
                  } else if (optionsResponse['records'] is List<dynamic>) {
                    recordOptions =
                        (optionsResponse['records'] as List<dynamic>)
                            .map((record) => Map<String, dynamic>.from(record))
                            .toList();
                  } else {
                    final listKeys = optionsResponse.keys.where((key) =>
                        optionsResponse[key] is List<dynamic> &&
                        (optionsResponse[key] as List).isNotEmpty &&
                        (optionsResponse[key] as List).first is Map);

                    if (listKeys.isNotEmpty) {
                      final firstListKey = listKeys.first;
                      recordOptions = (optionsResponse[firstListKey]
                              as List<dynamic>)
                          .map((record) => Map<String, dynamic>.from(record))
                          .toList();
                    } else {
                      log("Could not find list data in optionsResponse for ${field['name']}");
                    }
                  }
                }

                log("Retrieved ${recordOptions.length} options for record ID ${parentRelationRecord}");

                recordOptions = recordOptions.fold<List<Map<String, dynamic>>>(
                  [],
                  (uniqueList, option) {
                    if (!uniqueList.any((item) => item['id'] == option['id'])) {
                      uniqueList.add(option);
                    }
                    return uniqueList;
                  },
                );

                if (parentRelationRecord != null) {
                  many2manyOptions[parentRelationRecord] = recordOptions;
                  log("Assigned ${recordOptions.length} options to many2manyOptions[${parentRelationRecord}]");
                }
              } catch (e) {
                log("Error fetching options for record ID ${parentRelationRecord}: $e");
                many2manyOptions[parentRelationRecord] = [];
              }
            }
          } else {
            final optionsResponse = await widget.client.callKw({
              'model': 'ir.actions.act_window',
              'method': 'get_domain_condition_values',
              'args': [[]],
              'kwargs': {
                'parent_model': widget.mainModel,
                'parent_record_id': widget.mainRecordId,
                'domain': domain,
                'field_relation_model': relatedModel,
              },
            });

            print(
                "Non-product.template optionsResponse type: ${optionsResponse.runtimeType}");
            print(
                "Non-product.template optionsResponse value: $optionsResponse");

            List<Map<String, dynamic>> aggregatedOptions = [];
            if (optionsResponse is List<dynamic>) {
              aggregatedOptions = optionsResponse
                  .map((record) => Map<String, dynamic>.from(record))
                  .toList();
            } else if (optionsResponse is Map<String, dynamic>) {
              if (optionsResponse['result'] is List<dynamic>) {
                aggregatedOptions = (optionsResponse['result'] as List<dynamic>)
                    .map((record) => Map<String, dynamic>.from(record))
                    .toList();
              } else if (optionsResponse['records'] is List<dynamic>) {
                aggregatedOptions =
                    (optionsResponse['records'] as List<dynamic>)
                        .map((record) => Map<String, dynamic>.from(record))
                        .toList();
              } else {
                log("Unexpected optionsResponse format: $optionsResponse");
                aggregatedOptions = [];
              }
            } else {
              log("Unexpected optionsResponse type: ${optionsResponse.runtimeType}");
              aggregatedOptions = [];
            }

            if (relatedRecords.isNotEmpty) {
              for (var record in relatedRecords) {
                many2manyOptions[record['id']] = aggregatedOptions;
                log("Assigned ${aggregatedOptions.length} options to many2manyOptions[${record['id']}] (non-product.template)");
              }
            } else {
              many2manyOptions[0] =
                  aggregatedOptions; // Fallback for no records
              log("Assigned ${aggregatedOptions.length} options to many2manyOptions[0] (no records)");
            }
          }
        } else if (fieldDef['type'] == 'many2one' &&
            fieldDef['relation'] != null) {
          final relatedModel = fieldDef['relation'] as String;
          final domain = field['domain'] ?? '[]';

          final optionsResponse = await widget.client.callKw({
            'model': relatedModel,
            'method': 'search_read',
            'args': [],
            'kwargs': {
              'fields': ['id', 'name'],
            },
          });

          if (optionsResponse is List<dynamic>) {
            many2oneOptions[field['name']] = optionsResponse
                .map((record) => Map<String, dynamic>.from(record))
                .toList();
          }
        }
      }

      setState(() => isLoading = false);
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load data: $e';
        log(errorMessage!);
      });
    }
  }

  Future<String> _resolveDomainVariables(String domain, String model) async {
    print("_resolveDomainVariables  $domain");
    RegExp variablePattern = RegExp(
      r"\[\s*\['(.+?)'\s*,\s*'='\s*,\s*(?:'(.+?)'|([^'\]\s]+))\s*\]\s*\]",
      caseSensitive: false,
    );

    Iterable<RegExpMatch> matches = variablePattern.allMatches(domain);
    print("Found ${matches.length} matches");

    final replacements = <String, String>{};

    for (var match in matches) {
      String fieldName = match.group(1)!.trim();
      String variableName = (match.group(2) ?? match.group(3)!).trim();

      print("Resolving: field=$fieldName, variable=$variableName");

      try {
        final response = await widget.client.callKw({
          'model': model,
          'method': 'search_read',
          'args': [],
          'kwargs': {
            'fields': [fieldName],
            'domain': [],
            'limit': 1,
          },
        });

        if (response is List && response.isNotEmpty) {
          final resolvedValue = response.first[fieldName]?.toString();
          if (resolvedValue != null) {
            replacements["'$variableName'"] = "'$resolvedValue'";
            replacements[variableName] = "'$resolvedValue'";
          }
        }
      } catch (e) {
        print("Error resolving variable $variableName: $e");
      }
    }

    replacements.forEach((key, value) {
      domain = domain.replaceAll(key, value);
    });

    print("Resolved domain: $domain");
    return domain;
  }

  Future<void> _showAddRecordDialog() async {
    Map<String, dynamic> newRecord = {
      widget.relationField: widget.mainRecordId,
    };

    Map<String, TextEditingController> controllers = {};
    Map<String, List<dynamic>> selectedMany2Many = {};
    Map<String, int?> selectedMany2One = {};
    Map<String, String?> validationErrors = {};

    for (var field in widget.relatedFields) {
      final fieldDef = allFieldNames.firstWhere(
            (f) => f['name'] == field['name'],
        orElse: () => <String, dynamic>{
          'name': field['name'],
          'type': field['type'] ?? 'char',
          'string': field['name'],
        },
      );
      switch (fieldDef['type']) {
        case 'many2many':
          newRecord[field['name']] = [];
          selectedMany2Many[field['name']] = [];
          validationErrors[field['name']] = null;
          break;
        case 'many2one':
          final fieldName = field['name'] == 'product_template_id' ? 'product_id' : field['name'];
          newRecord[fieldName] = null;
          selectedMany2One[fieldName] = null;
          validationErrors[fieldName] = null;
          break;
        default:
          newRecord[field['name']] = '';
          controllers[field['name']] = TextEditingController();
          // Set default quantity to empty for product_uom_qty
          if (widget.relationModel == 'sale.order.line' && field['name'] == 'product_uom_qty') {
            controllers[field['name']]!.text = '';
          }
      }
    }

    final isSaleOrderLine = widget.relationModel == 'sale.order.line';
    List<Map<String, dynamic>> visibleFields = widget.relatedFields
        .where((field) => field['optional'] != 'hide')
        .map((field) {
      if (field['name'] == 'product_template_id') {
        return {...field, 'name': 'product_id'};
      }
      return field;
    }).toList();

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              insetPadding: const EdgeInsets.all(16),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 600,
                  maxHeight: MediaQuery.of(context).size.height * 0.8,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Add New Record',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: visibleFields.map((field) {
                            final fieldDef = allFieldNames.firstWhere(
                                  (f) => f['name'] == (field['name'] == 'product_template_id' ? 'product_id' : field['name']),
                              orElse: () => <String, dynamic>{
                                'name': field['name'] == 'product_template_id' ? 'product_id' : field['name'],
                                'type': field['type'] ?? 'char',
                                'string': field['name'],
                              },
                            );

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildFormField(
                                    field: fieldDef,
                                    fieldDef: fieldDef,
                                    controllers: controllers,
                                    selectedMany2Many: selectedMany2Many,
                                    selectedMany2One: selectedMany2One,
                                    validationErrors: validationErrors,
                                    setState: setState, // Pass setState for updating dialog
                                    newRecord: newRecord, // Pass newRecord for updates
                                  ),
                                  if (validationErrors[fieldDef['name']] != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Text(
                                        validationErrors[fieldDef['name']]!,
                                        style: const TextStyle(
                                          color: Colors.red,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: () async {
                              bool isValid = _validateForm(
                                controllers,
                                selectedMany2Many,
                                selectedMany2One,
                                validationErrors,
                                setState,
                              );

                              if (!isValid) {
                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                  Scrollable.ensureVisible(
                                    context,
                                    alignment: 0.1,
                                    duration: const Duration(milliseconds: 300),
                                  );
                                });
                                return;
                              }

                              await _saveNewRecord(
                                newRecord,
                                controllers,
                                selectedMany2Many,
                                selectedMany2One,
                                context,
                              );
                            },
                            child: const Text('Save'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  bool _validateForm(
    Map<String, TextEditingController> controllers,
    Map<String, List<dynamic>> selectedMany2Many,
    Map<String, int?> selectedMany2One,
    Map<String, String?> validationErrors,
    void Function(void Function()) setState,
  ) {
    bool isValid = true;

    setState(() {
      for (var field in widget.relatedFields) {
        validationErrors[field['name']] = null;
      }
    });

    for (var field in widget.relatedFields) {
      final fieldDef = allFieldNames.firstWhere(
        (f) => f['name'] == field['name'],
        orElse: () => <String, String?>{
          'name': field['name'] as String?,
          'type': field['type'] as String? ?? 'char',
        },
      );

      bool isRequired =
          field['required'] == true || fieldDef['required'] == true;
      final fieldName = fieldDef['string'] ?? field['name'];

      switch (fieldDef['type']) {
        case 'many2many':
          if (isRequired && selectedMany2Many[field['name']]!.isEmpty) {
            setState(() {
              validationErrors[field['name']] = '$fieldName is required';
            });
            isValid = false;
          }
          break;
        case 'many2one':
          if (isRequired && selectedMany2One[field['name']] == null) {
            setState(() {
              validationErrors[field['name']] = '$fieldName is required';
            });
            isValid = false;
          }
          break;
        default:
          if (isRequired &&
              (controllers[field['name']]?.text.isEmpty ?? true)) {
            setState(() {
              validationErrors[field['name']] = '$fieldName is required';
            });
            isValid = false;
          }
      }
    }

    return isValid;
  }

  Widget _buildFormField({
    required Map<String, dynamic> field,
    required Map<String, dynamic> fieldDef,
    required Map<String, TextEditingController> controllers,
    required Map<String, List<dynamic>> selectedMany2Many,
    required Map<String, int?> selectedMany2One,
    required Map<String, String?> validationErrors,
    required void Function(void Function()) setState, // For updating dialog
    required Map<String, dynamic> newRecord, // For updating newRecord
  }) {
    if (fieldDef['type'] == 'many2many') {
      return StatefulBuilder(
        builder: (context, setState) {
          final options = many2manyOptions[
          relatedRecords.isNotEmpty ? relatedRecords.first['id'] : 0] ??
              [];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                fieldDef['string'] ?? field['name'] ?? '',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if (options.isEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.orange[700]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'No options available for selection',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ),
                    ],
                  ),
                )
              else
                DropdownButtonFormField<int>(
                  isExpanded: true,
                  items: options
                      .map((option) => DropdownMenuItem<int>(
                    value: option['id'],
                    child: Text(option['name'] ?? 'Unknown'),
                  ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null &&
                        !selectedMany2Many[field['name']]!.contains(value)) {
                      setState(() {
                        selectedMany2Many[field['name']]!.add(value);
                        validationErrors[field['name']] = null;
                      });
                    }
                  },
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    errorText: validationErrors[field['name']],
                  ),
                  value: null,
                  hint: Text('Select ${fieldDef['string'] ?? field['name']}'),
                ),
              if (selectedMany2Many[field['name']]!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: selectedMany2Many[field['name']]!.map((id) {
                    final option = options.firstWhere(
                          (opt) => opt['id'] == id,
                      orElse: () => {'name': 'Unknown'},
                    );
                    return Chip(
                      label: Text(option['name']),
                      deleteIcon: const Icon(Icons.close, size: 16),
                      onDeleted: () {
                        setState(() {
                          selectedMany2Many[field['name']]!.remove(id);
                        });
                      },
                    );
                  }).toList(),
                ),
              ],
            ],
          );
        },
      );
    } else if (fieldDef['type'] == 'many2one') {
      return StatefulBuilder(
        builder: (context, setState) {
          return DropdownButtonFormField<int?>(
            isExpanded: true,
            value: selectedMany2One[field['name']],
            items: [
              DropdownMenuItem<int?>(
                value: null,
                child: Text('Select ${fieldDef['string'] ?? field['name'] ?? ''}'),
              ),
              ...(many2oneOptions[field['name']] ?? [])
                  .map((option) => DropdownMenuItem<int?>(
                value: option['id'] as int?,
                child: Text(option['name'] ?? 'Unknown'),
              ))
            ],
            onChanged: (value) {
              setState(() {
                selectedMany2One[field['name']] = value;
                validationErrors[field['name']] = null;
                // Set product_uom_qty to 1 when product_id is selected in sale.order.line
                if (widget.relationModel == 'sale.order.line' &&
                    field['name'] == 'product_id' &&
                    value != null) {
                  if (controllers.containsKey('product_uom_qty')) {
                    controllers['product_uom_qty']!.text = '1';
                    newRecord['product_uom_qty'] = '1';
                    log("Set product_uom_qty to 1 in dialog for product_id: $value");
                  } else {
                    log("Warning: product_uom_qty controller not found");
                  }
                }
              });
            },
            decoration: InputDecoration(
              labelText: fieldDef['string'] ?? field['name'],
              border: const OutlineInputBorder(),
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              errorText: validationErrors[field['name']],
            ),
          );
        },
      );
    } else {
      return TextFormField(
        controller: controllers[field['name']],
        decoration: InputDecoration(
          labelText: fieldDef['string'] ?? field['name'],
          border: const OutlineInputBorder(),
        ),
      );
    }
  }

  void _onMany2OneValueChanged(
      String fieldName, int recordIndex, dynamic newValue) async {
    log("fieldName: $fieldName, recordIndex: $recordIndex, newValue: $newValue");
    int? finalValue = newValue;

    // Handle product variants for sale.order.line product_id
    if (widget.relationModel == 'sale.order.line' &&
        fieldName == 'product_id' &&
        newValue != null) {
      final variants = await _fetchProductVariants(newValue);
      if (variants.length > 1) {
        final selectedVariantId = await _showVariantSelectionDialog(variants);
        finalValue = selectedVariantId ?? newValue;
      }
    }

    setState(() {
      relatedRecords[recordIndex][fieldName] = finalValue;
      // Set quantity to 1 if product_id is selected in sale.order.line
      if (widget.relationModel == 'sale.order.line' &&
          fieldName == 'product_id' &&
          finalValue != null) {
        if (allFieldNames.any((f) => f['name'] == 'product_uom_qty')) {
          relatedRecords[recordIndex]['product_uom_qty'] = 1;
          log("Set product_uom_qty to 1 for recordIndex: $recordIndex");
        } else {
          log("Warning: product_uom_qty field not found in allFieldNames");
        }
      }
    });

    try {
      final recordId = relatedRecords[recordIndex]['id'];
      log("relatedRecords[recordIndex]['id']: $recordId");

      if (recordId == null) {
        // New record: create with product_id and quantity
        final createData = {
          widget.relationField: widget.mainRecordId,
          fieldName: finalValue,
        };
        // Include quantity for sale.order.line product_id
        if (widget.relationModel == 'sale.order.line' &&
            fieldName == 'product_id' &&
            finalValue != null &&
            allFieldNames.any((f) => f['name'] == 'product_uom_qty')) {
          createData['product_uom_qty'] = 1;
        }

        final createResponse = await widget.client.callKw({
          'model': widget.relationModel,
          'method': 'create',
          'args': [createData],
          'kwargs': {},
        });

        if (createResponse is int) {
          setState(() {
            relatedRecords[recordIndex]['id'] = createResponse;
          });
          widget.onUpdate(relatedRecords);
          return;
        } else {
          log("Failed to create new record: $createResponse");
          throw Exception("Failed to create new record: $createResponse");
        }
      }

      // Existing record: update with product_id and quantity
      final updateData = {fieldName: finalValue};
      // Include quantity for sale.order.line product_id
      if (widget.relationModel == 'sale.order.line' &&
          fieldName == 'product_id' &&
          finalValue != null &&
          allFieldNames.any((f) => f['name'] == 'product_uom_qty')) {
        updateData['product_uom_qty'] = 1;
      }

      final response = await widget.client.callKw({
        'model': widget.relationModel,
        'method': 'write',
        'args': [
          [recordId],
          updateData,
        ],
        'kwargs': {},
      });

      if (response == true) {
        widget.onUpdate(relatedRecords);
      } else {
        throw Exception("Unexpected response from backend: $response");
      }
    } catch (e) {
      log("Failed to update record in backend: many2one $e");
      setState(() {
        errorMessage = 'Failed to update record in backend: $e';
      });
      widget.onUpdate(relatedRecords);
    }
  }

  Future<void> _saveNewRecord(
    Map<String, dynamic> newRecord,
    Map<String, TextEditingController> controllers,
    Map<String, List<dynamic>> selectedMany2Many,
    Map<String, int?> selectedMany2One,
    BuildContext context,
  ) async {
    log("selectedMany2Many : $selectedMany2Many");
    for (var field in widget.relatedFields) {
      final fieldDef = allFieldNames.firstWhere(
        (f) => f['name'] == field['name'],
        orElse: () => <String, dynamic>{
          'name': field['name'],
          'type': field['type'] ?? 'char',
        },
      );
      if (fieldDef['type'] == 'many2many') {
        newRecord[field['name']] = selectedMany2Many[field['name']];
      } else if (fieldDef['type'] == 'many2one') {
        newRecord[field['name']] = selectedMany2One[field['name']];
      } else {
        newRecord[field['name']] = controllers[field['name']]?.text ?? '';
      }
    }

    if (widget.mainRecordId == 0) {
      final isarRecord = One2ManyRecord()
        ..tempRecordId = widget.tempRecordId!
        ..mainModel = widget.mainModel
        ..mainRecordId = widget.mainRecordId
        ..relationModel = widget.relationModel
        ..relationField = widget.relationField
        ..fieldName = widget.fieldName
        ..data = jsonEncode(newRecord)
        ..isSynced = false;

      try {
        await isarService.saveRecord(isarRecord);
        setState(() {
          relatedRecords.add(newRecord);
        });
        widget.onUpdate(relatedRecords);
        Navigator.of(context).pop();
      } catch (e) {
        setState(() {
          errorMessage = 'Failed to save locally: $e';
        });
      }
    } else {
      // Save to Odoo
      setState(() {
        relatedRecords.add(newRecord);
      });

      try {
        final createResponse = await widget.client.callKw({
          'model': widget.relationModel,
          'method': 'create',
          'args': [newRecord],
          'kwargs': {},
        });

        if (createResponse is int) {
          setState(() {
            newRecord['id'] = createResponse;
            final field = widget.relatedFields.firstWhere(
              (f) => f['type'] == 'many2many',
              orElse: () => {},
            );
            if (field.isNotEmpty) {
              final relatedModel = allFieldNames.firstWhere(
                  (f) => f['name'] == field['name'])['relation'] as String;
              final domain = field['domain'] ?? '[]';
              many2manyOptions[createResponse] =
                  many2manyOptions[relatedRecords.first['id']] ?? [];
            }
          });
        } else {
          throw Exception("Failed to create new record: $createResponse");
        }
      } catch (e) {
        setState(() {
          errorMessage = 'Failed to add record: $e';
          relatedRecords.remove(newRecord);
        });
      }

      widget.onUpdate(relatedRecords);
      Navigator.of(context).pop();

    }
  }


  Future<void> _deleteRecord(int recordIndex) async {
    final record = relatedRecords[recordIndex];
    final recordId = record['id'];

    setState(() {
      relatedRecords.removeAt(recordIndex);
      many2manyOptions.remove(recordId);
    });

    if (widget.mainRecordId == 0) {
      try {
        final localRecords =
            await isarService.getRecordsByTempId(widget.tempRecordId!);
        final toDelete = localRecords.firstWhere(
          (r) =>
              jsonDecode(r.data)['id'] == recordId ||
              jsonDecode(r.data) == record,
          orElse: () => throw Exception('Record not found in Isar'),
        );
        await isarService.deleteRecord(toDelete.id);
      } catch (e) {
        setState(() {
          errorMessage = 'Failed to delete local record: $e';
          relatedRecords.insert(recordIndex, record);
          if (recordId != null) many2manyOptions[recordId] = [];
        });
      }
    } else if (recordId != null) {

      try {
        final deleteResponse = await widget.client.callKw({
          'model': widget.relationModel,
          'method': 'unlink',
          'args': [
            [recordId]
          ],
          'kwargs': {},
        });

        if (deleteResponse != true) {
          throw Exception("Failed to delete record: $deleteResponse");
        }
      } catch (e) {
        String errorMsg = 'Failed to delete record: $e';

        if (e.toString().contains('OdooException')) {
          final match =
              RegExp(r'arguments: \[([^\]]+)\]').firstMatch(e.toString());
          if (match != null && match.group(1) != null) {
            errorMsg = match.group(1)!;
          }
        }

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            // title: const Text('Error'),
            content: Text(errorMsg),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        setState(() {
          log('Error: $e');
          relatedRecords.insert(recordIndex, record);
          many2manyOptions[recordId] = []; // Restore if needed
        });
      }
    }

    widget.onUpdate(relatedRecords);
  }

  void _onMany2ManyValuesChanged(
      String fieldName, int recordIndex, List<dynamic> newValues) async {
    setState(() {
      relatedRecords[recordIndex][fieldName] = newValues;
    });

    try {
      final recordId = relatedRecords[recordIndex]['id'];
      if (recordId == null) {
        final createResponse = await widget.client.callKw({
          'model': widget.relationModel,
          'method': 'create',
          'args': [
            {
              widget.relationField: widget.mainRecordId,
              fieldName: newValues,
            },
          ],
          'kwargs': {},
        });
        if (createResponse is int) {
          setState(() {
            relatedRecords[recordIndex]['id'] = createResponse;
          });
          widget.onUpdate(relatedRecords);
          return;
        } else {
          throw Exception("Failed to create new record: $createResponse");
        }
      }

      final updateData = {fieldName: newValues};

      final response = await widget.client.callKw({
        'model': widget.relationModel,
        'method': 'write',
        'args': [
          [recordId],
          updateData
        ],
        'kwargs': {},
      });

      if (response == true) {
        widget.onUpdate(relatedRecords);
      } else {
        throw Exception("Unexpected response from backend: $response");
      }
    } catch (e) {
      log("Failed to update record in backend: many2many$e");
      setState(() {
        errorMessage = 'Failed to update record in backend: $e';
      });
      widget.onUpdate(relatedRecords);
    }
  }



  Future<List<Map<String, dynamic>>> _fetchProductVariants(
      int productId) async {
    try {
      final variantsResponse = await widget.client.callKw({
        'model': 'product.product',
        'method': 'search_read',
        'args': [],
        'kwargs': {
          'domain': [
            ['product_tmpl_id', '=', productId]
          ],
          'fields': ['id', 'name', 'default_code'],
        },
      });

      if (variantsResponse is List<dynamic>) {
        log("variantsResponse  :  ${variantsResponse.length}");
        return variantsResponse
            .map((record) => Map<String, dynamic>.from(record))
            .toList();
      } else {
        return [];
      }
    } catch (e) {
      log("Error fetching product variants: $e");
      return [];
    }
  }

  Future<int?> _showVariantSelectionDialog(
      List<Map<String, dynamic>> variants) async {
    int? selectedVariantId;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Product Variant'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: variants.map((variant) {
                return ListTile(
                  title: Text(variant['name'] ?? 'Unknown'),
                  subtitle: variant['default_code'] != null
                      ? Text('Code: ${variant['default_code']}')
                      : null,
                  onTap: () {
                    selectedVariantId = variant['id'];
                    Navigator.of(context).pop();
                  },
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );

    return selectedVariantId;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.name,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                ),
                if (!widget.readonly) // Add button only shown if not readonly
                  ElevatedButton.icon(
                    onPressed: _showAddRecordDialog,
                    // icon: const Icon(Icons.add),
                    label: const Text('Add'),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else if (errorMessage != null)
              Center(
                child: Text(
                  errorMessage!,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Colors.red),
                ),
              )
            else if (relatedRecords.isEmpty)
              Center(
                child: Text(
                  'No records found',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              )
            else
              _buildDataTable(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDataTable(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Check if the relation model is 'sale.order.line' and modify fields accordingly
        final isSaleOrderLine = widget.relationModel == 'sale.order.line';
        List<Map<String, dynamic>> visibleFields = widget.relatedFields
            .where((field) => field['optional'] != 'hide')
            .toList();

        log("visibleFields   before: $visibleFields");

        if (isSaleOrderLine) {
          visibleFields = visibleFields.map((field) {
            // Replace product_template_id with product_id
            if (field['name'] == 'product_template_id') {
              return {
                ...field,
                'name': 'product_id',
                'type': 'many2one',
                'relation': 'product.product',
              };
            }
            return field;
          }).toList();
        }
        log("visibleFields   : $visibleFields");

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: DataTable(
              columnSpacing: 24,
              dataRowHeight: widget.viewType == 'tree' ? 48 : 120,
              headingRowColor: MaterialStateProperty.all(
                  Theme.of(context).primaryColor.withOpacity(0.05)),
              columns: [
                DataColumn(
                  label: Text(
                    'ID',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                ...visibleFields.map((field) {
                  final fieldDef = allFieldNames.firstWhere(
                    (f) => f['name'] == field['name'],
                    orElse: () => <String, String?>{
                      'name': field['name'] as String?,
                      'string': field['name'] as String?,
                      'type': field['type'] as String? ?? 'char',
                    },
                  );
                  return DataColumn(
                    label: Text(
                      fieldDef['string'] ?? field['name'] ?? '',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }),
                if (!widget.readonly)
                  const DataColumn(
                    label: Text(
                      'Actions',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
              rows: relatedRecords.asMap().entries.map((entry) {
                final recordIndex = entry.key;
                final record = entry.value;
                return DataRow(
                  cells: [
                    DataCell(Text(record['id']?.toString() ?? '')),
                    ...visibleFields.map((field) {
                      // For sale.order.line, use product_id instead of product_template_id
                      final fieldName =
                          isSaleOrderLine && field['name'] == 'product_id'
                              ? 'product_id'
                              : field['name'];
                      final value = record[fieldName];
                      final fieldDef = allFieldNames.firstWhere(
                        (f) => f['name'] == field['name'],
                        orElse: () => <String, String?>{
                          'name': field['name'] as String?,
                          'type': field['type'] as String? ?? 'char',
                          'string': field['name'] as String?,
                        },
                      );

                      switch (fieldDef['type']) {
                        case 'many2many':
                          final options = many2manyOptions[record['id']] ?? [];
                          log("Rendering Many2ManyFieldWidget for ${field['name']} with options: ${options.length}, values: ${value is List ? value.length : 'not a list'}");

                          if (options.isEmpty) {
                            return DataCell(
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.info_outline, color: Colors.orange[700], size: 16),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'No options available',
                                        style: TextStyle(color: Colors.grey[700]),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }

                          return DataCell(
                            widget.readonly
                                ? Text(
                              (value as List<dynamic>?)?.map((id) {
                                final option = options.firstWhere(
                                      (opt) => opt['id'] == id,
                                  orElse: () => {'name': 'Unknown'},
                                );
                                return option['name'] ?? 'Unknown';
                              }).join(', ') ??
                                  '',
                              style: Theme.of(context).textTheme.bodyMedium,
                            )
                                : Many2ManyFieldWidget(
                              name: fieldDef['string'] ?? field['name'] ?? '',
                              values: value is List<dynamic> ? value : [],
                              options: options,
                              onValuesChanged: (newValues) => _onMany2ManyValuesChanged(
                                  field['name']!, recordIndex, newValues),
                              viewType: 'tree',
                            ),
                          );
                        case 'many2one':
                          return DataCell(
                            Many2OneFieldWidget(
                              name: fieldDef['string'] ?? field['name'] ?? '',
                              value: value,
                              options: many2oneOptions[field['name']] ?? [],
                              onValueChanged: (newValue) => _onMany2OneValueChanged(field['name']!, recordIndex, newValue),
                              viewType: 'tree',
                              readonly: widget.readonly,
                            ),
                          );
                        default:
                          return DataCell(
                            Text(
                              value?.toString() ?? '',
                              style: Theme.of(context).textTheme.bodyMedium,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                      }
                    }),
                    if (!widget.readonly)
                      DataCell(
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteRecord(recordIndex),
                          tooltip: 'Delete Record',
                        ),
                      ),
                  ],
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}
