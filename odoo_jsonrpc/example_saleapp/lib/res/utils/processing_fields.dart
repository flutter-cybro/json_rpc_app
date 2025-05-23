// import 'package:flutter/material.dart';
//
// Widget _buildFieldWidget(String fieldName,
//     {Map<String, dynamic>? fieldData}) {
//   final relational_field = fieldData?['name'];
//   final label = fieldData?['string'] ??
//       allPythonFields[fieldName]?['string'] ??
//       fieldName;
//   final rawValue = _recordState[fieldName];
//   final type =
//       fieldData?['type'] ?? allPythonFields[fieldName]?['type'] ?? 'char';
//   final widgetType = fieldData?['widget'];
//
//   List<dynamic> valueToOne2Many(dynamic val) {
//     if (val is List) return val;
//     return [];
//   }
//
//   bool valueToBool(dynamic val) {
//     if (val is bool) return val;
//     if (val is String) {
//       final lowerVal = val.toLowerCase();
//       return lowerVal == 'true' || lowerVal == '1';
//     }
//     return false;
//   }
//
//   DateTime? valueToDateTime(dynamic val) {
//     if (val is DateTime) return val;
//     if (val is String && val.isNotEmpty) {
//       try {
//         return DateTime.parse(val);
//       } catch (e) {
//         log("Error parsing DateTime for $fieldName: $e");
//         return null;
//       }
//     }
//     return null;
//   }
//
//   DateTime? valueToDate(dynamic val) {
//     if (val is DateTime) return val;
//     if (val is String && val.isNotEmpty) {
//       try {
//         return DateTime.parse(val);
//       } catch (e) {
//         log("Error parsing Date for $fieldName: $e");
//         return null;
//       }
//     }
//     return null;
//   }
//
//   List<dynamic> valueToMany2Many(dynamic val) {
//     if (val is List) return val;
//     return [];
//   }
//
//   int? valueToMany2One(dynamic val) {
//     if (val is int) return val;
//     if (val is List && val.isNotEmpty) return val[0] as int?;
//     return null;
//   }
//
//   String? valueToSelection(dynamic val) {
//     if (val == null) return null;
//     return val.toString();
//   }
//
//   final value = type == 'boolean'
//       ? valueToBool(rawValue ?? configSettingsValues[fieldName] ?? false)
//       : (type == 'datetime'
//       ? valueToDateTime(rawValue)
//       : (type == 'date'
//       ? valueToDate(rawValue)
//       : (type == 'many2many'
//       ? valueToMany2Many(rawValue)
//       : (type == 'one2many'
//       ? valueToOne2Many(rawValue)
//       : (type == 'many2one'
//       ? valueToMany2One(rawValue)
//       : (type == 'selection'
//       ? valueToSelection(rawValue)
//       : rawValue))))));
//   Future<List<Map<String, dynamic>>> fetchRelationOptions(
//       String relation) async {
//     if (relation == 'unknown' || relation.isEmpty) {
//       return [];
//     }
//     try {
//       final response = await _odooClientController.client.callKw({
//         'model': relation,
//         'method': 'search_read',
//         'args': [[]],
//         'kwargs': {
//           'fields': ['id', 'name'],
//           'limit': 100,
//         },
//       });
//       return (response as List)
//           .map((item) =>
//       {'id': item['id'] as int, 'name': item['name'] as String})
//           .toList();
//     } catch (e) {
//       return [];
//     }
//   }
//
//   if (widgetType != null) {
//     if (widgetType == 'account-tax-totals-field' && type == 'binary') {
//       return TaxTotalsFieldWidget(
//         name: label,
//         value: rawValue,
//       );
//     }
//     if (widgetType == 'boolean_toggle' && type == 'boolean') {
//       return BooleanToggleFieldWidget(name: label, value: value);
//     }
//
//     if (widgetType == 'image' && type == 'binary') {
//       final isReadonly = fieldData?['readonly'] ??
//           allPythonFields[fieldName]?['readonly'] ??
//           false;
//       return ImageFieldWidget(
//         name: label,
//         value: value?.toString() ?? '',
//         onChanged: isReadonly
//             ? null
//             : (newValue) => _updateFieldValue(fieldName, newValue),
//         isReadonly: isReadonly,
//         viewType: 'form',
//       );
//     }
//
//     if (widgetType == 'email' && type == 'char') {
//       return EmailFieldWidget(
//         name: label,
//         value: value?.toString() ?? '',
//         onChanged: (newValue) => _updateFieldValue(fieldName, newValue),
//       );
//     }
//     if (widgetType == 'url' && type == 'char') {
//       return UrlFieldWidget(
//         name: label,
//         value: value?.toString() ?? '',
//         onChanged: (newValue) => _updateFieldValue(fieldName, newValue),
//       );
//     }
//     if (widgetType == 'text' && type == 'char') {
//       return TextXmlFieldWidget(
//         name: label,
//         value: value?.toString() ?? '',
//         onChanged: (newValue) => _updateFieldValue(fieldName, newValue),
//       );
//     }
//     if (widgetType == 'phone' && type == 'char') {
//       return PhoneFieldWidget(
//         name: label,
//         value: value?.toString() ?? '',
//         onChanged: (newValue) => _updateFieldValue(fieldName, newValue),
//       );
//     }
//     if (widgetType == 'float_time' && type == 'float') {
//       return Padding(
//         padding: const EdgeInsets.symmetric(vertical: 8.0),
//         child: FloatTimeFieldWidget(
//           name: label,
//           value: value is num ? value.toDouble() : 0.0,
//           onChanged: (newValue) => _updateFieldValue(fieldName, newValue),
//         ),
//       );
//     }
//   }
//   if (widgetType == 'documentation_link') {
//     final path = fieldData?['path'] ?? '';
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: InkWell(
//         onTap: () {
//           log('Opening documentation: $path');
//         },
//         child: Row(
//           children: [
//             const Icon(Icons.help_outline, size: 20),
//             const SizedBox(width: 8),
//             Text(
//               'Documentation',
//               style: const TextStyle(color: Colors.blue, fontSize: 14.0),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//   if (widgetType == 'res_config_invite_users') {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             label,
//             style:
//             const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0),
//           ),
//           ElevatedButton(
//             onPressed: () =>
//                 _onButtonPressed('action_invite_users', 'action'),
//             child: const Text('Invite Users'),
//           ),
//         ],
//       ),
//     );
//   }
//   switch (type) {
//     case 'char':
//       String defaultValue = '';
//       if (value == null ||
//           value.toString().isEmpty ||
//           value.toString() == 'false') {
//         if (configSettingsValues.containsKey(fieldName)) {
//           defaultValue = configSettingsValues[fieldName]?.toString() ?? '';
//         } else if (_defaultValues != null &&
//             _defaultValues!.containsKey(fieldName)) {
//           defaultValue = _defaultValues![fieldName]?.toString() ?? '';
//         }
//       }
//
//       final effectiveValue = (value != null && value.toString() != 'false')
//           ? value.toString()
//           : defaultValue;
//
//       if (fieldName == 'email') {
//         return Padding(
//           padding: const EdgeInsets.symmetric(vertical: 8.0),
//           child: EmailFieldWidget(
//             name: label,
//             value: effectiveValue,
//             onChanged: (newValue) => _updateFieldValue(fieldName, newValue),
//           ),
//         );
//       }
//       if (fieldName == 'website') {
//         return Padding(
//           padding: const EdgeInsets.symmetric(vertical: 8.0),
//           child: UrlFieldWidget(
//             name: label,
//             value: effectiveValue,
//             onChanged: (newValue) => _updateFieldValue(fieldName, newValue),
//           ),
//         );
//       }
//       if (fieldName == 'phone' || fieldName == 'mobile') {
//         return Padding(
//           padding: const EdgeInsets.symmetric(vertical: 8.0),
//           child: PhoneFieldWidget(
//             name: label,
//             value: effectiveValue,
//             onChanged: (newValue) => _updateFieldValue(fieldName, newValue),
//           ),
//         );
//       }
//       final readonlyValue = fieldData?['readonly'] ??
//           allPythonFields[fieldName]?['readonly'] ??
//           false;
//       final isReadonly = readonlyValue is bool
//           ? readonlyValue
//           : readonlyValue.toString().toLowerCase() == 'true';
//
//       return Padding(
//         padding: const EdgeInsets.symmetric(vertical: 8.0),
//         child: CharFieldWidget(
//           name: label,
//           value: effectiveValue,
//           onChanged: isReadonly
//               ? null
//               : (newValue) => _updateFieldValue(fieldName, newValue),
//         ),
//       );
//     case 'many2one':
//       final relation = allPythonFields[fieldName]?['relation'] ?? 'unknown';
//       final readonlyValue = fieldData?['readonly'] ??
//           allPythonFields[fieldName]?['readonly'] ??
//           false;
//       final isReadonly = readonlyValue is bool
//           ? readonlyValue
//           : readonlyValue.toString().toLowerCase() == 'true';
//
//       return Padding(
//         padding: const EdgeInsets.symmetric(vertical: 8.0),
//         child: FutureBuilder<List<Map<String, dynamic>>>(
//           future: fetchRelationOptions(relation),
//           builder: (context, snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return const CircularProgressIndicator();
//             }
//             if (snapshot.hasError || !snapshot.hasData) {
//               return const Text('Error loading options',
//                   style: TextStyle(color: Colors.red));
//             }
//             final options = snapshot.data!;
//
//             int? currentValue = value;
//
//             if (currentValue == null &&
//                 _defaultValues != null &&
//                 _defaultValues!.containsKey(fieldName)) {
//               final defaultRaw = _defaultValues![fieldName];
//               final defaultId = (defaultRaw is List && defaultRaw.isNotEmpty)
//                   ? defaultRaw[0]
//                   : defaultRaw;
//
//               if (defaultId is int &&
//                   options.any((option) => option['id'] == defaultId)) {
//                 currentValue = defaultId;
//                 if (!isReadonly) {
//                   WidgetsBinding.instance.addPostFrameCallback((_) {
//                     _updateFieldValue(fieldName, currentValue);
//                   });
//                 }
//               }
//             }
//
//             return Many2OneFieldWidget(
//               name: label,
//               value: currentValue,
//               options: options,
//               onValueChanged: isReadonly
//                   ? (v) {}
//                   : (newValue) => _updateFieldValue(fieldName, newValue),
//               readonly: isReadonly,
//             );
//           },
//         ),
//       );
//     case 'selection':
//       print("second selection field");
//       final selectionOptions = allPythonFields[fieldName]?['selection'] ?? [];
//       final readonlyValue = fieldData?['readonly'] ??
//           allPythonFields[fieldName]?['readonly'] ??
//           false;
//       final isReadonly = readonlyValue is bool
//           ? readonlyValue
//           : readonlyValue.toString().toLowerCase() == 'true';
//
//       String? defaultValue;
//       if (value == null && selectionOptions.isNotEmpty) {
//         if (_defaultValues != null &&
//             _defaultValues!.containsKey(fieldName)) {
//           defaultValue = _defaultValues![fieldName]?.toString();
//           if (defaultValue != null &&
//               !selectionOptions
//                   .any((option) => option[0].toString() == defaultValue)) {
//             defaultValue = null;
//           }
//         }
//         if (defaultValue == null && selectionOptions.isNotEmpty) {
//           defaultValue = selectionOptions[0][0].toString();
//         }
//         if (defaultValue != null) {
//           WidgetsBinding.instance.addPostFrameCallback((_) {
//             _updateFieldValue(fieldName, defaultValue);
//           });
//         }
//       }
//
//       return Padding(
//         padding: const EdgeInsets.symmetric(vertical: 8.0),
//         child: SelectionFieldWidget(
//           name: label,
//           value: value as String? ?? defaultValue,
//           options: selectionOptions,
//           onChanged: isReadonly
//               ? null
//               : (newValue) => _updateFieldValue(fieldName, newValue),
//           readonly: isReadonly,
//         ),
//       );
//     case 'binary':
//       final isReadonly = fieldData?['readonly'] ??
//           allPythonFields[fieldName]?['readonly'] ??
//           false;
//       String? validatedValue;
//       if (rawValue != null) {
//         try {
//           if (rawValue is String && rawValue.isNotEmpty) {
//             base64Decode(rawValue);
//             validatedValue = rawValue;
//           }
//         } on FormatException catch (e) {
//           print("Invalid base64 data for $fieldName: $rawValue - Error: $e");
//           validatedValue = null;
//         }
//       }
//       return Padding(
//         padding: const EdgeInsets.symmetric(vertical: 8.0),
//         child: BinaryFieldWidget(
//           name: label,
//           value: validatedValue,
//           onChanged: (newValue) => _updateFieldValue(fieldName, newValue),
//         ),
//       );
//
//     case 'date':
//       print("fieldname : $fieldName");
//       return Padding(
//         padding: const EdgeInsets.symmetric(vertical: 8.0),
//         child: DateFieldWidget(
//           name: label,
//           value: value as DateTime?,
//           onChanged: (newValue) => _updateFieldValue(
//               fieldName, DateFormat('yyyy-MM-dd').format(newValue)),
//         ),
//       );
//     case 'datetime':
//       print("datetime fieldname: $fieldName");
//       final readonlyValue = fieldData?['readonly'] ??
//           allPythonFields[fieldName]?['readonly'] ??
//           false;
//       final isReadonly = readonlyValue is bool
//           ? readonlyValue
//           : readonlyValue.toString().toLowerCase() == 'true';
//       return Padding(
//         padding: const EdgeInsets.symmetric(vertical: 8.0),
//         child: DateTimeFieldWidget(
//           name: label,
//           value: value as DateTime?,
//           onChanged: isReadonly
//               ? null
//               : (newValue) =>
//               _updateFieldValue(fieldName, newValue.toIso8601String()),
//           readonly: isReadonly,
//         ),
//       );
//
//     case 'boolean':
//       final readonlyValue = fieldData?['readonly'] ??
//           allPythonFields[fieldName]?['readonly'] ??
//           false;
//       final isReadonly = readonlyValue is bool
//           ? readonlyValue
//           : readonlyValue.toString().toLowerCase() == 'true';
//       final isModuleField = fieldName.startsWith('module_');
//       final isUpgradeBoolean = widgetType == 'upgrade_boolean';
//       bool defaultValue = false;
//       if (value == null || value == false) {
//         if (configSettingsValues.containsKey(fieldName)) {
//           defaultValue = valueToBool(configSettingsValues[fieldName]);
//         } else if (_defaultValues != null &&
//             _defaultValues!.containsKey(fieldName)) {
//           defaultValue = valueToBool(_defaultValues![fieldName]);
//         }
//       }
//
//       final effectiveValue = value is bool ? value : defaultValue;
//
//       void handleBooleanChange(bool newValue) async {
//         final previousValue = effectiveValue;
//
//         setState(() {
//           recordState[fieldName] = newValue;
//         });
//
//         if (isModuleField) {
//           if (newValue) {
//             final confirmed = await showDialog<bool>(
//               context: context,
//               barrierDismissible: false,
//               builder: (BuildContext context) {
//                 return AlertDialog(
//                   title: const Text('Feature Setup Required'),
//                   content: const Text(
//                     'This will install the required module. Save this page and install the module to continue.',
//                   ),
//                   actions: [
//                     TextButton(
//                       onPressed: () {
//                         Navigator.of(context).pop(false);
//                       },
//                       child: const Text('Cancel'),
//                     ),
//                     TextButton(
//                       onPressed: () {
//                         Navigator.of(context).pop(true);
//                       },
//                       child: const Text('Save & Install'),
//                     ),
//                   ],
//                 );
//               },
//             );
//
//             if (confirmed == true) {
//               final success = await _handleModuleInstallUninstall(
//                   fieldName, newValue, previousValue);
//               if (!success) {
//                 setState(() {
//                   recordState[fieldName] = previousValue;
//                 });
//               }
//             } else {
//               setState(() {
//                 recordState[fieldName] = previousValue;
//               });
//             }
//           } else {
//             final confirmed = await showDialog<bool>(
//               context: context,
//               barrierDismissible: false,
//               builder: (BuildContext context) {
//                 return AlertDialog(
//                   title: const Text('Confirm Disable'),
//                   content: const Text(
//                     'Disabling this option will also uninstall the following modules.',
//                   ),
//                   actions: [
//                     TextButton(
//                       onPressed: () {
//                         Navigator.of(context).pop(false);
//                       },
//                       child: const Text('Cancel'),
//                     ),
//                     TextButton(
//                       onPressed: () {
//                         Navigator.of(context).pop(true);
//                       },
//                       child: const Text('Confirm'),
//                     ),
//                   ],
//                 );
//               },
//             );
//
//             if (confirmed == true) {
//               final success = await _handleModuleInstallUninstall(
//                   fieldName, newValue, previousValue);
//               if (!success) {
//                 setState(() {
//                   recordState[fieldName] = previousValue;
//                 });
//               }
//             } else {
//               setState(() {
//                 recordState[fieldName] = previousValue;
//               });
//             }
//           }
//         } else if (isUpgradeBoolean) {
//           if (newValue) {
//             final confirmed = await showDialog<bool>(
//               context: context,
//               barrierDismissible: false,
//               builder: (BuildContext context) {
//                 return AlertDialog(
//                   title: const Text('Upgrade to Odoo Enterprise'),
//                   content: const Text(
//                     'Get this feature and much more with Odoo Enterprise!',
//                   ),
//                   actions: [
//                     TextButton(
//                       onPressed: () {
//                         Navigator.of(context).pop(false);
//                       },
//                       child: const Text('Cancel'),
//                     ),
//                     TextButton(
//                       onPressed: () {
//                         Navigator.of(context).pop(true);
//                       },
//                       child: const Text('Upgrade'),
//                     ),
//                   ],
//                 );
//               },
//             );
//
//             setState(() {
//               recordState[fieldName] = previousValue;
//             });
//
//             if (confirmed == true) {
//               log('Upgrade initiated for $fieldName');
//             }
//           } else {
//             final confirmed = await showDialog<bool>(
//               context: context,
//               barrierDismissible: false,
//               builder: (BuildContext context) {
//                 return AlertDialog(
//                   title: const Text('Disable Enterprise Feature'),
//                   content: const Text(
//                     'Disabling this option will remove access to Odoo Enterprise features.',
//                   ),
//                   actions: [
//                     TextButton(
//                       onPressed: () {
//                         Navigator.of(context).pop(false);
//                       },
//                       child: const Text('Cancel'),
//                     ),
//                     TextButton(
//                       onPressed: () {
//                         Navigator.of(context).pop(true);
//                       },
//                       child: const Text('Confirm'),
//                     ),
//                   ],
//                 );
//               },
//             );
//
//             if (confirmed == true) {
//               await _updateFieldValue(fieldName, newValue);
//             } else {
//               setState(() {
//                 recordState[fieldName] = previousValue;
//               });
//             }
//           }
//         } else {
//           await _updateFieldValue(fieldName, newValue);
//         }
//       }
//
//       if (widgetType == 'boolean_favorite') {
//         return Padding(
//           padding: const EdgeInsets.symmetric(vertical: 8.0),
//           child: Row(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               SizedBox(
//                 width: 150,
//                 child: Padding(
//                   padding: const EdgeInsets.only(top: 8.0, right: 8.0),
//                   child: Text(
//                     '$label:',
//                     style: const TextStyle(
//                       fontWeight: FontWeight.bold,
//                       fontSize: 14.0,
//                     ),
//                   ),
//                 ),
//               ),
//               Expanded(
//                 child: GestureDetector(
//                   onTap: isReadonly
//                       ? null
//                       : () {
//                     handleBooleanChange(!effectiveValue);
//                   },
//                   child: BooleanFavoriteWidget(isFavorite: effectiveValue),
//                 ),
//               ),
//             ],
//           ),
//         );
//       }
//
//       return Padding(
//         padding: const EdgeInsets.symmetric(vertical: 8.0),
//         child: BooleanFieldWidget(
//           value: effectiveValue,
//           label: label,
//           viewType: 'form',
//           onChanged: isReadonly ? null : handleBooleanChange,
//         ),
//       );
//
//     case 'char':
//       if (fieldName == 'email') {
//         return Padding(
//           padding: const EdgeInsets.symmetric(vertical: 8.0),
//           child: EmailFieldWidget(
//             name: label,
//             value: value?.toString() ?? '',
//             onChanged: (newValue) => _updateFieldValue(fieldName, newValue),
//           ),
//         );
//       }
//       if (fieldName == 'website') {
//         return Padding(
//           padding: const EdgeInsets.symmetric(vertical: 8.0),
//           child: UrlFieldWidget(
//             name: label,
//             value: value?.toString() ?? '',
//             onChanged: (newValue) => _updateFieldValue(fieldName, newValue),
//           ),
//         );
//       }
//       if (fieldName == 'phone' || fieldName == 'mobile') {
//         return Padding(
//           padding: const EdgeInsets.symmetric(vertical: 8.0),
//           child: PhoneFieldWidget(
//             name: label,
//             value: value?.toString() ?? '',
//             onChanged: (newValue) => _updateFieldValue(fieldName, newValue),
//           ),
//         );
//       }
//       return Padding(
//         padding: const EdgeInsets.symmetric(vertical: 8.0),
//         child: CharFieldWidget(
//           name: label,
//           value: value?.toString() != 'false' ? value.toString() : '',
//           onChanged: (newValue) => _updateFieldValue(fieldName, newValue),
//         ),
//       );
//     case 'many2one':
//       final relation = allPythonFields[fieldName]?['relation'] ?? 'unknown';
//       return Padding(
//         padding: const EdgeInsets.symmetric(vertical: 2),
//         child: FutureBuilder<List<Map<String, dynamic>>>(
//           future: fetchRelationOptions(relation),
//           builder: (context, snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return const CircularProgressIndicator();
//             }
//             if (snapshot.hasError || !snapshot.hasData) {
//               return const Text('Error loading options',
//                   style: TextStyle(color: Colors.red));
//             }
//             final options = snapshot.data!;
//             return Many2OneFieldWidget(
//               name: label,
//               value: value,
//               options: options,
//               onValueChanged: (newValue) =>
//                   _updateFieldValue(fieldName, newValue),
//             );
//           },
//         ),
//       );
//     case 'many2many':
//       final relation = allPythonFields[fieldName]?['relation'] ?? 'unknown';
//       return Padding(
//         padding: const EdgeInsets.symmetric(vertical: 8.0),
//         child: Row(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             SizedBox(
//               width: 150,
//               child: Padding(
//                 padding: const EdgeInsets.only(top: 8.0, right: 8.0),
//                 child: Text(
//                   '$label:',
//                   style: const TextStyle(
//                       fontWeight: FontWeight.bold, fontSize: 14.0),
//                 ),
//               ),
//             ),
//             Expanded(
//               child: FutureBuilder<List<Map<String, dynamic>>>(
//                 future: fetchRelationOptions(relation),
//                 builder: (context, snapshot) {
//                   if (snapshot.connectionState == ConnectionState.waiting) {
//                     return const CircularProgressIndicator();
//                   }
//                   if (snapshot.hasError || !snapshot.hasData) {
//                     return const Text('Error loading options',
//                         style: TextStyle(color: Colors.red));
//                   }
//                   final options = snapshot.data!;
//                   return Many2ManyFieldWidget(
//                     name: label,
//                     values: value as List<dynamic>,
//                     options: options,
//                     onValuesChanged: (newValues) =>
//                         _updateFieldValue(fieldName, newValues),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       );
//     case 'text':
//       return Padding(
//         padding: const EdgeInsets.symmetric(vertical: 8.0),
//         child: TextFieldWidget(
//           name: label,
//           value: value?.toString() ?? '',
//           onChanged: (newValue) => _updateFieldValue(fieldName, newValue),
//         ),
//       );
//     case 'integer':
//       int defaultValue = 0;
//       if (value == null || value == 0) {
//         if (configSettingsValues.containsKey(fieldName)) {
//           defaultValue = configSettingsValues[fieldName] is int
//               ? configSettingsValues[fieldName]
//               : int.tryParse(configSettingsValues[fieldName].toString()) ?? 0;
//         } else if (_defaultValues != null &&
//             _defaultValues!.containsKey(fieldName)) {
//           defaultValue = _defaultValues![fieldName] is int
//               ? _defaultValues![fieldName]
//               : int.tryParse(_defaultValues![fieldName].toString()) ?? 0;
//         }
//       }
//
//       final effectiveValue = value is int ? value : defaultValue;
//       final readonlyValue = fieldData?['readonly'] ??
//           allPythonFields[fieldName]?['readonly'] ??
//           false;
//       final isReadonly = readonlyValue is bool
//           ? readonlyValue
//           : readonlyValue.toString().toLowerCase() == 'true';
//
//       if (fieldName == 'color') {
//         return Padding(
//           padding: const EdgeInsets.symmetric(vertical: 8.0),
//           child: Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               SizedBox(
//                 width: 150,
//                 child: Text(
//                   '$label:',
//                   style: const TextStyle(
//                       fontWeight: FontWeight.bold, fontSize: 14.0),
//                 ),
//               ),
//               Expanded(
//                 child: ColorPickerWidget(
//                   initialColorValue: effectiveValue,
//                   viewType: 'form',
//                   onChanged: isReadonly
//                       ? null
//                       : (newValue) => _updateFieldValue(fieldName, newValue),
//                 ),
//               ),
//             ],
//           ),
//         );
//       }
//
//       return Padding(
//         padding: const EdgeInsets.symmetric(vertical: 8.0),
//         child: IntegerFieldWidget(
//           name: label,
//           value: effectiveValue,
//           onChanged: isReadonly
//               ? null
//               : (newValue) => _updateFieldValue(fieldName, newValue),
//           readonly: isReadonly,
//         ),
//       );
//     case 'float':
//       return Padding(
//         padding: const EdgeInsets.symmetric(vertical: 8.0),
//         child: FloatFieldWidget(
//           name: label,
//           value: value is num ? value.toDouble() : 0.0,
//         ),
//       );
//     case 'html':
//       return Padding(
//         padding: const EdgeInsets.symmetric(vertical: 8.0),
//         child: HtmlFieldWidget(
//           name: label,
//           value: value?.toString() ?? '',
//         ),
//       );
//     case 'one2many':
//       print("relational_field  : ${relational_field}");
//       return One2ManyFieldWidget(
//         // readonly: true,
//         mainModel: widget.modelName,
//         fieldName: fieldName,
//         name: label,
//         relationModel: fieldData?['relation_model'] as String? ?? '',
//         relationField: fieldData?['relation_field'] as String? ?? '',
//         mainRecordId: widget.recordId,
//         tempRecordId: tempRecordId,
//         client: _odooClientController.client,
//         onUpdate: (values) => _updateFieldValue(fieldName, values),
//         relatedFields: (fieldData?['mode_fields'] as List?)
//             ?.map((f) => {
//           'name': f['name'] as String,
//           'type': f['type'] as String? ?? 'char',
//           'domain': f['domain'] as String? ?? '[]',
//           'options': f['options'],
//           'optional': f['optional'],
//         })
//             .toList() ??
//             [],
//       );
//     default:
//       return Padding(
//         padding: const EdgeInsets.symmetric(vertical: 8.0),
//         child: Row(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             SizedBox(
//               width: 150,
//               child: Text(
//                 '$label',
//                 style: const TextStyle(
//                     fontWeight: FontWeight.bold, fontSize: 14.0),
//               ),
//             ),
//             Expanded(
//               child: Text(
//                 _formatFieldValue(value, type),
//                 style: const TextStyle(fontSize: 14.0),
//               ),
//             ),
//           ],
//         ),
//       );
//   }
// }