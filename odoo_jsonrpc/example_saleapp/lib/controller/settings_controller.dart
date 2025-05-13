import 'dart:convert';
import 'dart:developer';
import 'package:xml/xml.dart' as xml;

class SettingsController {
  final dynamic client;

  SettingsController({required this.client});
  Future<dynamic> callKw(Map<String, dynamic> params) async {
    return await client.callKw(params);
  }
  /// Main method to load settings data based on an action string
  Future<Map<String, dynamic>> loadSettings(String actionString, {String? moduleName}) async {


    try {
      List<String> parts = _parseActionString(actionString);
      if (parts.length != 2) {
        throw Exception("Invalid action format: $actionString");
      }

      String actionType = parts[0];
      int actionId = int.parse(parts[1]);

      if (actionType == "ir.actions.act_window") {
        return await _loadSettingsFromActWindow(actionId, moduleName: moduleName);
      } else {
        throw Exception("Unsupported action type for settings: $actionType");
      }
    } catch (e) {
      log("Error loading settings: $e");
      rethrow;
    }
  }

  /// Parse the action string into type and ID
  List<String> _parseActionString(String actionString) {
    return actionString.split(',');
  }

  /// Load settings data from an ir.actions.act_window action
  Future<Map<String, dynamic>> _loadSettingsFromActWindow(int actionId, {String? moduleName}) async {
    try {
      // Fetch action details from Odoo server
      final actionResult = await client!.callRPC(
        '/web/action/load',
        'call',
        {'action_id': actionId},
      );

      if (actionResult == null || actionResult.isEmpty) {
        throw Exception("Action not found or empty response for ID: $actionId");
      }

      // log('Settings Action Result: $actionResult');

      String? resModel = actionResult['res_model'];
      if (resModel != 'res.config.settings') {
        throw Exception("Expected res.config.settings model, got: $resModel");
      }

      // Fetch the form view architecture
      final viewResult = await client!.callKw({
        'model': resModel,
        'method': 'get_views',
        'args': [],
        'kwargs': {
          'views': actionResult['views'] as List<dynamic>? ?? [],
        },
      });

      final formView = viewResult['views']['form'] as Map<String, dynamic>?;
      String formData = formView?['arch'] as String? ?? '';

      if (formData.isEmpty) {
        throw Exception("No form view architecture found for settings");
      }

      // Parse and extract settings data
      Map<String, dynamic> settingsData = _parseSettingsFormData(formData, moduleName: moduleName);

      // Log the extracted settings data
      // log('Extracted Settings Data: $settingsData');

      return {
        'model': resModel,
        'formData': formData,
        'settingsData': settingsData,
        'context': actionResult['context'] ?? {},
      };
    } catch (e) {
      log("Error loading settings from act_window: $e");
      rethrow;
    }
  }

  /// Parse the form data XML and extract settings details
  Map<String, dynamic> _parseSettingsFormData(String formData, {String? moduleName}) {
    try {
      final document = xml.XmlDocument.parse(formData);
      final formElement = document.findAllElements('form').firstOrNull;

      if (formElement == null || formElement.getAttribute('string') != 'Settings') {
        throw Exception("Invalid or missing settings form in XML");
      }

      Map<String, dynamic> settingsData = {};
      for (var appElement in formElement.findAllElements('app')) {
        final appName = appElement.getAttribute('string') ?? 'Unknown App';

        if (moduleName != null && !appName.toLowerCase().contains(moduleName.toLowerCase())) {
          continue;
        }

        final appData = {
          'app_name': appName,
          'attributes': appElement.attributes
              .where((attr) => attr.name.local != 'string')
              .map((attr) => {attr.name.local: attr.value})
              .toList(),
          'blocks': <String, dynamic>{},
        };

        for (var blockElement in appElement.findAllElements('block')) {
          final blockName = blockElement.getAttribute('title') ?? 'Unknown Block';
          final blockData = {
            'block_name': blockName,
            'attributes': blockElement.attributes
                .where((attr) => attr.name.local != 'title')
                .map((attr) => {attr.name.local: attr.value})
                .toList(),
            'settings': <String, dynamic>{},
          };

          for (var settingElement in blockElement.findAllElements('setting')) {
            final settingId = settingElement.getAttribute('id') ?? 'Unknown Setting';
            String settingString = settingElement.getAttribute('string') ?? settingId;
            final helpText = settingElement.getAttribute('help');
            final documentationUrl = settingElement.getAttribute('documentation'); // Extract documentation attribute

            if (settingString == settingId || settingString.isEmpty) {
              final spanLabel = settingElement.findAllElements('span').firstWhere(
                    (e) => e.getAttribute('class')?.contains('o_form_label') == true,
                orElse: () => xml.XmlElement(xml.XmlName('span')),
              );
              settingString = spanLabel.text.trim().isNotEmpty ? spanLabel.text.trim() : settingId;
            }

            final settingData = {
              'string': settingString,
              'help': helpText,
              'documentation': documentationUrl, // Add documentation to settingData
              'attributes': settingElement.attributes
                  .where((attr) => attr.name.local != 'id' && attr.name.local != 'string' && attr.name.local != 'help' && attr.name.local != 'documentation')
                  .map((attr) => {attr.name.local: attr.value})
                  .toList(),
              'fields': <Map<String, dynamic>>[], // ✅ Fixed typo and initialized list
            };

            for (var fieldElement in settingElement.childElements) {
              if (fieldElement.name.local == 'field' || fieldElement.name.local == 'widget') {
                final fieldData = {
                  'tag': fieldElement.name.local,
                  'name': fieldElement.getAttribute('name') ?? 'Unknown Field',
                  'attributes': fieldElement.attributes
                      .where((attr) => attr.name.local != 'name')
                      .map((attr) => {attr.name.local: attr.value})
                      .toList(),
                };

                // ✅ Ensure 'fields' is a list before adding data
                (settingData['fields'] as List<Map<String, dynamic>>).add(fieldData);
              }
            }

            (blockData['settings'] as Map<String, dynamic>)[settingId] = settingData;
          }

          (appData['blocks'] as Map<String, dynamic>)[blockName] = blockData;
        }

        settingsData[appName] = appData;
      }

      return settingsData;
    } catch (e) {
      log("Error parsing settings form data: $e");
      return {};
    }
  }



  Future<Map<String, dynamic>> fetchFieldMetadata(String modelName, String moduleName) async {
    print('zzzzzzzzzzzzzzzzzzzzzzzzz $moduleName');
    print('zzzzzzzzzzzzzzzzzzzzzzzzz $modelName');
    try {
      final fieldsResult = await client!.callKw({
        'model': 'ir.actions.act_window',
        'method': 'fields_view_get',
        'args': [[]],
        'kwargs': {
          'view_type': 'form',
          'context': {'model_name': modelName},
          'module_name': moduleName
        },
      });
      log('Raw response for***** \n  $fieldsResult \n Raw response for**');

      // log('Raw response for $modelName: $fieldsResult');
      // log('Raw response for  $fieldsResult');
      log('Rrrrrrrrrrrrrrrrrrrrrrr');
      // print(fieldsResult);

      if (fieldsResult is Map<String, dynamic>) {
        return fieldsResult;
      } else {
        log('Unexpected response format: $fieldsResult');
        return {};
      }
    } catch (e) {
      log("Error fetching field metadataaaa: $e");
      return {};
    }
  }


/// Fetch additional field metadata for settings (e.g., field types, labels)

}