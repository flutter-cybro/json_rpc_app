import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:xml/xml.dart' as xml;
import '../controller/odooclient_manager_controller.dart';
import '../controller/settings_controller.dart';
import '../res/constants/app_colors.dart';
import 'form_view.dart';

class SettingsFormView extends StatefulWidget {
  final String modelName;
  final String formData;
  final String name;
  final int? actionId;
  final moduleName;
  final Map<String, dynamic>? settingsData;
  final Map<String, dynamic>? fieldMetadata;

  const SettingsFormView({
    Key? key,
    this.fieldMetadata,
    required this.modelName,
    required this.formData,
    required this.name,
    this.actionId,
    this.moduleName,
    this.settingsData,
  }) : super(key: key);

  @override
  State<SettingsFormView> createState() => _SettingsFormViewState();
}

class _SettingsFormViewState extends State<SettingsFormView> {
  late SettingsController settingsController;
  Map<String, dynamic>? fieldsResult;
  List<Widget> _formDataWidgets = [];
  bool _isLoading = true;
  Map<String, dynamic> appsData = {};
  Map<String, dynamic> fieldMetadata = {};

  @override
  void initState() {
    super.initState();

    _parseAndCombineData();
    processFormData(
        widget.formData); // Call processFormData with widget.formData
  }

  Map<String, dynamic> separateFormData(String formXml) {
    final document = xml.XmlDocument.parse(formXml);
    final formElement = document.findAllElements('form').firstOrNull;

    if (formElement == null) return {};

    // Main structure with explicit typing
    Map<String, dynamic> structuredData = {
      'form_attributes': formElement.attributes
          .map((attr) => {attr.name.local: attr.value})
          .toList(),
      'apps': <String, dynamic>{}
    };

    // Process each app
    for (var appElement in formElement.findAllElements('app')) {
      final appName = appElement.getAttribute('string') ?? 'Unnamed App';

      final appData = {
        'attributes': appElement.attributes
            .map((attr) => {attr.name.local: attr.value})
            .toList(),
        'blocks': <String, dynamic>{}
      };

      // Process blocks within app
      for (var blockElement in appElement.findAllElements('block')) {
        final blockName = blockElement.getAttribute('title') ?? 'Unnamed Block';

        final blockData = {
          'attributes': blockElement.attributes
              .map((attr) => {attr.name.local: attr.value})
              .toList(),
          'settings': <String, dynamic>{}
        };

        // Process settings within block
        for (var settingElement in blockElement.findAllElements('setting')) {
          final settingId =
              settingElement.getAttribute('id') ?? 'unnamed_setting';

          final settingData = {
            'attributes': settingElement.attributes
                .map((attr) => {attr.name.local: attr.value})
                .toList(),
            'widgets': <Map<String, dynamic>>[],
            // Explicitly typed as List<Map>
            'fields': <Map<String, dynamic>>[],
            // Explicitly typed as List<Map>
            'other_elements': <Map<String, dynamic>>[]
            // Explicitly typed as List<Map>
          };

          // Process all child elements
          for (var child in settingElement.childElements) {
            if (child.name.local == 'widget') {
              settingData['widgets']!.add({
                'name': child.getAttribute('name') ?? '',
                'attributes': child.attributes
                    .map((attr) => {attr.name.local: attr.value})
                    .toList(),
              });
            } else if (child.name.local == 'field') {
              settingData['fields']!.add({
                'name': child.getAttribute('name') ?? '',
                'attributes': child.attributes
                    .map((attr) => {attr.name.local: attr.value})
                    .toList(),
              });
            } else {
              // Handle other elements (span, button, div, etc.)
              settingData['other_elements']!.add({
                'tag': child.name.local,
                'attributes': child.attributes
                    .map((attr) => {attr.name.local: attr.value})
                    .toList(),
                'text': child.text.trim(),
              });
            }
          }

          (blockData['settings'] as Map<String, dynamic>)[settingId] =
              settingData;
        }

        (appData['blocks'] as Map<String, dynamic>)[blockName] = blockData;
      }

      (structuredData['apps'] as Map<String, dynamic>)[appName] = appData;
    }

    return structuredData;
  }

// Example usage:
  void processFormData(String xmlString) {
    final result = separateFormData(xmlString);
    // log('blahhhh');
    // log('Structured Form Data: ${jsonEncode(result)}');
  }

  Future<void> _parseAndCombineData() async {
    try {
      if (widget.settingsData != null) {
        appsData = Map<String, dynamic>.from(widget.settingsData!);
      }

      final document = xml.XmlDocument.parse(widget.formData);
      final formElement = document.findAllElements('form').firstOrNull;
      // log('testttttttttttttttttttttttt $formElement');

      if (formElement != null &&
          formElement.getAttribute('string') == 'Settings') {
        _extractSettingsData(formElement);
      }

      setState(() {
        _formDataWidgets = _buildFormWidgets();
        _isLoading = false;
      });
    } catch (e) {
      log('Error parsing and combining data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _extractSettingsData(xml.XmlElement root) {
    Map<String, dynamic> tempAppsData = {};

    for (var element in root.childElements) {
      if (element.name.local == 'app') {
        final appName = element.getAttribute('string') ?? 'Unknown App';

        if (widget.moduleName != null &&
            !appName.toLowerCase().contains(widget.moduleName!.toLowerCase())) {
          continue;
        }

        final appData = tempAppsData[appName] ??
            {
              'app_name': appName,
              'attributes': element.attributes
                  .where((attr) => attr.name.local != 'string')
                  .map((attr) => {attr.name.local: attr.value})
                  .toList(),
              'blocks': <String, dynamic>{},
            };

        for (var block in element.findAllElements('block')) {
          final blockName = block.getAttribute('title') ?? ' ';
          final blockData = appData['blocks'][blockName] ??
              {
                'block_name': blockName,
                'attributes': block.attributes
                    .where((attr) => attr.name.local != 'title')
                    .map((attr) => {attr.name.local: attr.value})
                    .toList(),
                'settings': <String, dynamic>{},
              };

          for (var setting in block.findAllElements('setting')) {
            final settingId = setting.getAttribute('id') ?? 'Unknown Setting';
            String settingString = setting.getAttribute('string') ?? settingId;
            final helpText = setting.getAttribute('help');
            final documentationUrl = setting.getAttribute('documentation');

            if (settingString == settingId || settingString.isEmpty) {
              final spanLabel = setting.findAllElements('span').firstWhere(
                    (e) =>
                        e.getAttribute('class')?.contains('o_form_label') ==
                        true,
                    orElse: () => xml.XmlElement(xml.XmlName('span')),
                  );
              settingString = spanLabel.text.trim().isNotEmpty
                  ? spanLabel.text.trim()
                  : settingId;
            }

            final settingData = blockData['settings'][settingId] ??
                {
                  'string': settingString,
                  'help': helpText,
                  'documentation': documentationUrl,
                  'attributes': setting.attributes
                      .where((attr) =>
                          attr.name.local != 'id' &&
                          attr.name.local != 'string' &&
                          attr.name.local != 'help' &&
                          attr.name.local != 'documentation')
                      .map((attr) => {attr.name.local: attr.value})
                      .toList(),
                  'fields': <Map<String, dynamic>>[],
                  'hasModuleField': false,
                  'buttons': <Map<String, dynamic>>[], // Add buttons list
                };

            for (var subElement in setting.childElements) {
              if (subElement.name.local == 'field' ||
                  subElement.name.local == 'widget') {
                final fieldName =
                    subElement.getAttribute('name') ?? 'Unknown Field';
                final fieldInfo = fieldMetadata[fieldName] ?? {};
                // log('Processing field: $fieldName');
                // log('Field Metadata: ${jsonEncode(fieldMetadata)}');
                if (fieldMetadata.containsKey(fieldName)) {
                  // log('Found metadata for $fieldName: ${fieldMetadata[fieldName]}');
                } else {
                  // log('No metadata found for $fieldName');
                }

                (settingData['fields'] as List<Map<String, dynamic>>).add({
                  'tag': subElement.name.local,
                  'name': fieldName,
                  'type': fieldInfo['type'] ?? 'char',
                  'label': fieldInfo['string'] ?? fieldName,
                  'help': fieldInfo['help'],
                  'attributes': subElement.attributes
                      .where((attr) => attr.name.local != 'name')
                      .map((attr) => {attr.name.local: attr.value})
                      .toList(),
                });
                if (fieldName.startsWith('module_')) {
                  settingData['hasModuleField'] = true;
                }
              } else if (subElement.name.local == 'button') {
                // Extract button details
                (settingData['buttons'] as List<Map<String, dynamic>>).add({
                  'name': subElement.getAttribute('name'),
                  'icon': subElement.getAttribute('icon'),
                  'type': subElement.getAttribute('type'),
                  'string': subElement.getAttribute('string'),
                  'class': subElement.getAttribute('class'),
                });
              }
            }

            (blockData['settings'] as Map<String, dynamic>)[settingId] =
                settingData;
          }

          (appData['blocks'] as Map<String, dynamic>)[blockName] = blockData;
        }

        tempAppsData[appName] = appData;
      }
    }

    tempAppsData.forEach((appName, appData) {
      if (appsData.containsKey(appName)) {
        final existingBlocks =
            appsData[appName]['blocks'] as Map<String, dynamic>;
        final newBlocks = appData['blocks'] as Map<String, dynamic>;
        newBlocks.forEach((blockName, blockData) {
          if (existingBlocks.containsKey(blockName)) {
            final existingSettings =
                existingBlocks[blockName]['settings'] as Map<String, dynamic>;
            final newSettings = blockData['settings'] as Map<String, dynamic>;
            newSettings.forEach((settingId, settingData) {
              existingSettings[settingId] = settingData;
            });
          } else {
            existingBlocks[blockName] = blockData;
          }
        });
      } else {
        appsData[appName] = appData;
      }
    });

    // log('Combined Apps Data: $appsData');
  }

  List<Widget> _buildFormWidgets() {
    List<Widget> widgets = [];
    appsData.forEach((appName, appData) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              ...(appData['blocks'] as Map<String, dynamic>)
                  .entries
                  .map<Widget>((blockEntry) {
                final blockName = blockEntry.key;
                final blockData = blockEntry.value;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12.0, vertical: 6.0),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                      ),
                      child: Text(
                        blockName,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: ODOO_COLOR,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...((blockData['settings'] as Map<String, dynamic>)
                        .entries
                        .map<Widget>((settingEntry) {
                      final settingId = settingEntry.key;
                      final settingData = settingEntry.value;

                      List<String> helpTexts = (settingData['fields']
                              as List<Map<String, dynamic>>)
                          .where((field) => field['help'] != null)
                          .map((field) => '${field['label']}: ${field['help']}')
                          .toList();

                      bool hasModuleField = (settingData['fields']
                              as List<Map<String, dynamic>>)
                          .any((field) => field['name'].startsWith('module_'));

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 4.0, horizontal: 16.0),
                        child: StatefulBuilder(
                          builder: (context, setState) {
                            bool isChecked =
                                settingData['checkboxValue'] ?? false;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    if (hasModuleField) ...[
                                      Checkbox(
                                        value: isChecked,
                                        activeColor: ODOO_COLOR,
                                        onChanged: (bool? value) {
                                          setState(() {
                                            settingData['checkboxValue'] =
                                                value ?? false;
                                          });
                                        },
                                      ),
                                      const SizedBox(width: 8),
                                    ],
                                    Expanded(
                                      child: Text(
                                        settingData['string'],
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                    if (settingData['documentation'] !=
                                        null) ...[
                                      IconButton(
                                        icon: Icon(Icons.link,
                                            size: 20, color: ODOO_COLOR),
                                        onPressed: () async {
                                          final baseUrl =
                                              'https://www.odoo.com/documentation/18.0';
                                          final documentationPath =
                                              settingData['documentation'];
                                          final fullUrl =
                                              '$baseUrl$documentationPath';

                                          if (await canLaunchUrl(
                                              Uri.parse(fullUrl))) {
                                            await launchUrl(Uri.parse(fullUrl),
                                                mode: LaunchMode
                                                    .externalApplication);
                                          } else {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                  content: Text(
                                                      'Could not launch $fullUrl')),
                                            );
                                          }
                                        },
                                        tooltip: 'Open documentation',
                                      ),
                                    ],
                                  ],
                                ),
                                if (settingData['help'] != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    settingData['help'],
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.yellow[700]),
                                  ),
                                ],
                                if (hasModuleField && isChecked) ...[
                                  const SizedBox(height: 8),
                                  ...((settingData['fields']
                                          as List<Map<String, dynamic>>)
                                      .where((field) =>
                                          !field['name'].startsWith('module_'))
                                      .map((field) {
                                    // log('Rendering field: ${field['name']}');
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                            width: 120,
                                            child: Text(
                                              field['label'] ?? field['name'],
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.black87,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: TextField(
                                              obscureText: field['attributes']
                                                      ?.any((attr) =>
                                                          attr['password'] ==
                                                          'True') ??
                                                  false,
                                              decoration: InputDecoration(
                                                border: OutlineInputBorder(),
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 4,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList()),
                                ],
                                if ((settingData['buttons']
                                            as List<Map<String, dynamic>>?)
                                        ?.isNotEmpty ??
                                    false) ...[
                                  const SizedBox(height: 8),
                                  ...(settingData['buttons']
                                          as List<Map<String, dynamic>>)
                                      .map<Widget>((button) {
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 4.0),
                                      child: TextButton(
                                        onPressed: () async {
                                          log('Button clicked: ${button['name']} - ${button['type']}');
                                          if (button['type'] == 'object') {
                                            // Call Odoo to get the action details
                                            final settingsController =
                                                SettingsController(
                                                    client:
                                                        OdooClientController()
                                                            .client);
                                            print(
                                                '\n\n settingsController11111111111111 $settingsController ');
                                            try {
                                              final actionResult =
                                                  await settingsController
                                                      .callKw({
                                                'model': widget.modelName,
                                                'method': button['name'],
                                                'args': [],
                                                'kwargs': {},
                                              });

                                              log('Action result: $actionResult');

                                              if (actionResult
                                                      is Map<String, dynamic> &&
                                                  actionResult
                                                      .containsKey('type')) {
                                                final actionType =
                                                    actionResult['type'];
                                                if (actionType ==
                                                    'ir.actions.act_window') {
                                                  final views = actionResult[
                                                              'views']
                                                          as List<dynamic>? ??
                                                      [];
                                                  final resModel =
                                                      actionResult['res_model']
                                                              as String? ??
                                                          widget.modelName;
                                                  final resId =
                                                      actionResult['res_id']
                                                              as int? ??
                                                          0;

                                                  // Check if any view is of type 'form'
                                                  bool isFormView = views.any(
                                                      (view) =>
                                                          view is List &&
                                                          view[1] == 'form');
                                                  if (isFormView) {
                                                    // Navigate to FormView
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            FormView(
                                                          modelName: resModel,
                                                          recordId: resId,
                                                          name: button[
                                                                  'string'] ??
                                                              'Form View',
                                                        ),
                                                      ),
                                                    );
                                                  } else {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      SnackBar(
                                                          content: Text(
                                                              'No form view available for this action')),
                                                    );
                                                  }
                                                }
                                              } else {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                      content: Text(
                                                          'Unexpected action result')),
                                                );
                                              }
                                            } catch (e) {
                                              log('Error calling button method: $e');
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                    content: Text(
                                                        'Error executing action: $e')),
                                              );
                                            }
                                          }
                                        },
                                        style: TextButton.styleFrom(
                                          foregroundColor: ODOO_COLOR,
                                          padding: EdgeInsets.zero,
                                          alignment: Alignment.centerLeft,
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            if (button['icon'] != null) ...[
                                              Icon(
                                                button['icon'] ==
                                                        'oi-arrow-right'
                                                    ? Icons.arrow_forward
                                                    : Icons.arrow_forward,
                                                size: 16,
                                                color: ODOO_COLOR,
                                              ),
                                              const SizedBox(width: 4),
                                            ],
                                            Text(
                                              button['string'] ??
                                                  'Unnamed Button',
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color: ODOO_COLOR),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ],
                                if (helpTexts.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    'Help on Settings:',
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black54),
                                  ),
                                  ...helpTexts.map((help) => Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 2.0),
                                        child: Text(
                                          help,
                                          style: const TextStyle(
                                              fontSize: 12, color: Colors.grey),
                                        ),
                                      )),
                                ],
                              ],
                            );
                          },
                        ),
                      );
                    })).toList(),
                  ],
                );
              }).toList(),
            ],
          ),
        ),
      );
    });

    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        ),
        title: Text(
          appsData.isNotEmpty ? appsData.keys.first : widget.name,
          style: TextStyle(color: WHITE_COLOR),
        ),
        backgroundColor: ODOO_COLOR,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : appsData.isEmpty
              ? const Center(child: Text('No settings found for this module'))
              : SingleChildScrollView(
                  child: Column(
                    children: _formDataWidgets,
                  ),
                ),
    );
  }
}
