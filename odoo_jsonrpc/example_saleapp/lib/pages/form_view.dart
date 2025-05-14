import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../controller/odooclient_manager_controller.dart';
import '../mixins/action_mixier.dart';
import '../mixins/button_action_mixin.dart';
import '../mixins/odoo_invisible.dart';
import '../res/constants/app_colors.dart';
import '../res/odoo_res/odoo_data_types/BinaryFieldWidget.dart';
import '../res/odoo_res/odoo_data_types/boolean_field_widget.dart';
import '../res/odoo_res/odoo_data_types/char_field_widget.dart';
import '../res/odoo_res/odoo_data_types/date_field_widget.dart';
import '../res/odoo_res/odoo_data_types/date_time_field_widget.dart';
import '../res/odoo_res/odoo_data_types/float_field_widget.dart';
import '../res/odoo_res/odoo_data_types/html_field_widget.dart';
import '../res/odoo_res/odoo_data_types/integer_field_widget.dart';
import '../res/odoo_res/odoo_data_types/many2many_field_widget.dart';
import '../res/odoo_res/odoo_data_types/many2one_field_widget.dart';
import '../res/odoo_res/odoo_data_types/one2many_field_widget.dart';
import '../res/odoo_res/odoo_data_types/selection_field_widget.dart';
import '../res/odoo_res/odoo_data_types/text_field_widget.dart';
import '../res/odoo_res/odoo_xml_widget/boolean_favorite.dart';
import '../res/odoo_res/odoo_xml_widget/boolean_toggle.dart';
import '../res/odoo_res/odoo_xml_widget/color_picker.dart';
import '../res/odoo_res/odoo_xml_widget/email.dart';
import '../res/odoo_res/odoo_xml_widget/float_time.dart';
import '../res/odoo_res/odoo_xml_widget/image.dart';
import '../res/odoo_res/odoo_xml_widget/phone.dart';
import '../res/odoo_res/odoo_xml_widget/tax_total_custom.dart';
import '../res/odoo_res/odoo_xml_widget/text.dart';
import '../res/odoo_res/odoo_xml_widget/url.dart';
import '../res/utils/actionPopup.dart';

class FormView extends StatefulWidget {
  final String modelName;
  final int recordId;
  final int? viewId;
  final String? formData;
  final String? name;
  final String? moduleName;

  const FormView({
    Key? key,
    required this.modelName,
    required this.recordId,
    this.viewId,
    this.formData,
    this.name,
    this.moduleName,
  }) : super(key: key);

  @override
  State<FormView> createState() => _FormViewState();
}

class _FormViewState extends State<FormView>
    with
        ActWindowActionMixin<FormView>,
        ButtonActionMixin<FormView>,
        InvisibleConditionMixin {
  List<Map<String, dynamic>> settingsSections = [];
  Map<String, dynamic>? _defaultValues;
  late final OdooClientController _odooClientController;
  dynamic _fieldData;
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic> configSettingsDefaults = {};
  late Map<String, dynamic> allPythonFields;
  Map<String, dynamic> configSettingsValues = {};
  Map<String, dynamic> _recordState = {};
  List<Map<String, dynamic>> bodyField = [];
  List<Map<String, dynamic>> headerButtons = [];
  List<Map<String, dynamic>> notebookPages = [];
  List<Map<String, dynamic>> smartButtons = [];
  List<Map<String, dynamic>> wizardData = [];
  List<Map<String, dynamic>> footerButtons = [];
  Set<String> _expandedBlocks = {};
  int? _companyId;
  int? tempRecordId;

  // Implement the recordState getter required by InvisibleConditionMixin
  @override
  Map<String, dynamic> get recordState => _recordState;

  bool _isSettingsForm() {
    print(
        'ohhhhhh ${widget.formData?.contains('class="oe_form_configuration"')}');
    return widget.formData?.contains('class="oe_form_configuration"') ?? false;
  }

  @override
  OdooClientController get odooClient => _odooClientController;

  @override
  OdooClientController get odooClientController => _odooClientController;

  @override
  int? get recordId => widget.recordId;

  @override
  String get modelName => widget.modelName;

  @override
  void initState() {
    super.initState();
    print("name of modulename : ${widget.modelName}");
    if (widget.recordId == 0) {
      tempRecordId = DateTime.now().millisecondsSinceEpoch;
    }
    log("form Data  :  ${widget.formData}");
    _odooClientController = OdooClientController();
    _initializeFormData();
    if (widget.formData != null) {
      _fetchFormFields();
      setState(() {
        _fieldData = widget.formData;
      });
    } else {
      _fetchFormFields();
    }
  }

  Future<void> _initializeFormData() async {
    try {
      if (!_odooClientController.isInitialized) {
        await _odooClientController.initialize();
      }

      await Future.wait([
        _fetchCompanyId(),
        _fetchFields(),
        _fetchDefaultValues(),
      ]);

      if (widget.recordId == 0 && _defaultValues != null) {
        setState(() {
          _recordState = Map<String, dynamic>.from(_defaultValues!);
        });
      } else if (widget.recordId != 0) {
        await _loadRecordState();
      }
    } catch (e) {
      setState(() {
        _error = 'Error initializing form data: $e';
      });
    }
  }

  Future<void> _fetchDefaultValues() async {
    try {
      final fieldsResponse = await _odooClientController.client.callKw({
        'model': widget.modelName,
        'method': 'fields_get',
        'args': [],
        'kwargs': {},
      });

      if (fieldsResponse is Map<String, dynamic>) {
        final fields = fieldsResponse.keys.toList();
        final defaultValuesResponse =
        await _odooClientController.client.callKw({
          'model': widget.modelName,
          'method': 'default_get',
          'args': [fields],
          'kwargs': {},
        });

        if (defaultValuesResponse is Map<String, dynamic>) {
          setState(() {
            _defaultValues = defaultValuesResponse;
          });
        } else {
          log('No default values returned for ${widget.modelName}');
        }
      } else {
        log('No fields returned for ${widget.modelName}');
      }
    } catch (e) {
      log('Error fetching default values: $e');
    }
  }

  Future<void> _fetchFields() async {
    final fieldsResponse = await _odooClientController.client.callKw({
      'model': widget.modelName,
      'method': 'fields_get',
      'args': [],
      'kwargs': {},
    });

    setState(() {
      allPythonFields = fieldsResponse as Map<String, dynamic>;
    });
  }

  Future<void> _fetchCompanyId() async {
    try {
      if (!_odooClientController.isInitialized) {
        await _odooClientController.initialize();
      }

      final userId = _odooClientController.userId ??
          (throw Exception(
              'User is not authenticated or userId is unavailable'));

      final userResponse = await _odooClientController.client.callKw({
        'model': 'res.users',
        'method': 'read',
        'args': [userId],
        'kwargs': {
          'fields': ['company_id']
        },
      });

      if (userResponse is List && userResponse.isNotEmpty) {
        final userData = userResponse.first as Map<String, dynamic>;
        final companyId = _extractCompanyId(userData);
        _updateCompanyId(companyId);
      } else {
        _handleFallback('Empty or invalid response');
      }
    } catch (e) {
      _handleFallback('Error fetching company ID: $e');
    }
  }

  int? _extractCompanyId(Map<String, dynamic> userData) {
    final companyIdData = userData['company_id'];
    if (companyIdData is List && companyIdData.length >= 2) {
      return companyIdData[0] as int?;
    }
    return null;
  }

  Future<void> _saveSettings() async {
    if (widget.modelName != 'res.config.settings') {
      _showErrorSnackBar('This form does not support settings configuration.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final valuesToSave = <String, dynamic>{};
    String? moduleToInstall;

    for (final entry in _recordState.entries) {
      final fieldName = entry.key;
      final value = entry.value;

      if (fieldName == 'id' || fieldName == '__last_update') continue;

      if (fieldName.startsWith('module_') && value == true) {
        moduleToInstall = fieldName.replaceFirst('module_', '');
      }
      valuesToSave[fieldName] = value;
    }

    valuesToSave['company_id'] = _companyId ?? 1;
    log('valuesToSave : $valuesToSave');
    final saveResult = await _odooClientController.client.callKw({
      'model': 'res.config.settings',
      'method': 'set_values',
      'args': [],
      'kwargs': {
        'context': {'active_id': widget.recordId},
        'values': valuesToSave,
      },
    });
    log('saveResult : $saveResult');

    if (saveResult == null || saveResult == true) {
      if (moduleToInstall != null) {
        await _installModule(moduleToInstall);
      } else {
        _showSuccessSnackBar('Settings saved successfully.');
      }

      await _loadRecordState();
      await _printConfigSettingsValues();
    } else {
      _showErrorSnackBar('Failed to save settings');
    }
  }

  Future<void> _installModule(String moduleName) async {
    try {
      setState(() {
        _isLoading = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        _buildSnackBar(
          message: 'Installing module $moduleName...',
          backgroundColor: Colors.blue,
        ),
      );

      final installResult = await _odooClientController.client.callKw({
        'model': 'ir.module.module',
        'method': 'button_immediate_install',
        'args': [],
        'kwargs': {
          'context': {'module_name': moduleName},
        },
      });

      if (installResult == true) {
        _showSuccessSnackBar('Module $moduleName installed successfully!');
        await _fetchFormFields();
      } else {
        _showErrorSnackBar('Failed to install module $moduleName');
      }
    } catch (e) {
      log('Error installing module: $e');
      _showErrorSnackBar('Failed to install module: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<bool> _handleModuleInstallUninstall(
      String fieldName, bool fieldValue, bool currentValue) async {
    setState(() {
      _isLoading = true;
    });
    try {
      log('Calling install_uninstall_apps_settings with fieldName: $fieldName, fieldValue: $fieldValue');

      final result = await _odooClientController.client.callKw({
        'model': 'ir.actions.act_window',
        'method': 'install_uninstall_apps_settings',
        'args': [[]],
        'kwargs': {
          'field_name': fieldName,
          'field_value': fieldValue,
        },
      });

      if (result == true || result == null) {
        _showSuccessSnackBar(fieldValue
            ? 'Module installation initiated.'
            : 'Module uninstallation initiated.');

        await _fetchFormFields();
        await _loadRecordState();
        await _printConfigSettingsValues();

        return true;
      } else {
        _showErrorSnackBar(
            'Failed to ${fieldValue ? 'install' : 'uninstall'} module.');
        _updateFieldValue(fieldName, currentValue);
        return false;
      }
    } catch (e) {
      log('Error in install_uninstall_apps_settings for $fieldName: $e');
      _showErrorSnackBar('Error: $e');
      _updateFieldValue(fieldName, currentValue);
      return false;
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _updateCompanyId(int? companyId) {
    setState(() {
      _companyId = companyId ?? 1;
    });
  }

  void _handleFallback(String errorMessage) {
    log(errorMessage);
    setState(() {
      _companyId = 1;
    });
  }

  Future<void> _loadRecordState() async => await _callKwWithErrorHandling(
    method: 'read',
    args: [
      [widget.recordId],
    ],
    kwargs: {'fields': allPythonFields.keys.toList()},
    onSuccess: (response) {
      if (response is List && response.isNotEmpty) {
        setState(() {
          _recordState = Map<String, dynamic>.from(response.first);
        });
      }
    },
    errorMessage: 'Error loading record state',
  );

  Future<void> _updateFieldValue(String fieldName, dynamic value) async {
    setState(() => _recordState[fieldName] = value);
    if (widget.modelName == 'res.config.settings') return;
    final fieldType = allPythonFields[fieldName]?['type'] ?? 'char';
    final isOne2Many = fieldType == 'one2many';
    final hasRecordId = widget.recordId != 0;

    if (!hasRecordId || isOne2Many) {
      _showSuccessSnackBar('$fieldName updated successfully');
      return;
    }

    await _callKwWithErrorHandling(
      method: 'write',
      args: [
        [widget.recordId],
        {fieldName: value},
      ],
      onSuccess: (_) async {
        await _fetchFormFields();

        _showSuccessSnackBar('$fieldName updated successfully');
      },
      onError: () async {
        await _loadRecordState();
        _showErrorSnackBar('Failed to update $fieldName');
      },
      errorMessage: 'Error updating field value',
    );
  }

  Future<void> _callKwWithErrorHandling({
    required String method,
    List<dynamic> args = const [],
    Map<String, dynamic> kwargs = const {},
    void Function(dynamic)? onSuccess,
    String? errorMessage,
    Future<void> Function()? onError,
    bool showSnackBar = false,
  }) async {
    try {
      print("widget.modelName  : ${widget.modelName}");
      final response = await _odooClientController.client.callKw({
        'model': widget.modelName,
        'method': method,
        'args': args,
        'kwargs': kwargs,
      });
      onSuccess?.call(response);
    } catch (e) {
      log('$errorMessage: $e');
      if (showSnackBar) _showErrorSnackBar('$errorMessage: $e');
      await onError?.call();
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      _buildSnackBar(
        message: message,
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      _buildSnackBar(
        message: message,
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _fetchFormFields() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      if (!_odooClientController.isInitialized) {
        await _odooClientController.initialize();
      }

      final method = widget.modelName == 'res.config.settings'
          ? 'fields_view_get'
          : 'get_all_fields_in_form_view';
      final response = await _odooClientController.client.callKw({
        'model': 'ir.actions.act_window',
        'method': method,
        'args': widget.modelName == 'res.config.settings' ? [] : [[]],
        'kwargs': widget.modelName == 'res.config.settings'
            ? {
          'view_type': 'form',
          'view_id': widget.viewId,
          'context': {
            'model_name': widget.modelName,
            'company_id': _companyId ?? 1
          },
          'module_name': 'sale',
        }
            : {
          'model': widget.modelName,
          'record_id': widget.recordId,
          'formData': widget.formData,
        },
      });

      if (response == null || (response is Map && response.isEmpty)) {
        setState(() {
          _error = 'No form data received from server';
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _fieldData = response;
        _parseResponseData();
        _isLoading = false;
      });

      if (widget.modelName == 'res.config.settings') {
        await _printConfigSettingsValues();
      }
    } catch (e) {
      setState(() {
        _error = 'Error fetching form fields: $e';
        log(_error!);
        _isLoading = false;
      });
    }
  }

  Future<void> _printConfigSettingsValues() async {
    try {
      final fieldsResponse = await _odooClientController.client.callKw({
        'model': 'res.config.settings',
        'method': 'fields_get',
        'args': [],
        'kwargs': {},
      });

      if (fieldsResponse is Map<String, dynamic>) {
        final fields = fieldsResponse.keys.toList();
        final valuesResponse = await _odooClientController.client.callKw({
          'model': 'res.config.settings',
          'method': 'default_get',
          'args': [fields],
          'kwargs': {},
        });

        if (valuesResponse is Map<String, dynamic>) {
          setState(() {
            configSettingsValues = valuesResponse;
          });
          log('=== res.config.settings Parameters ===');
          valuesResponse.forEach((key, value) {});
          log('==============res.config.settings Parameters==============');
        } else {
          log('No values returned for res.config.settings');
        }
      } else {
        log('No fields returned for res.config.settings');
      }
    } catch (e) {
      log('Error fetching res.config.settings values: $e');
    }
  }

  bool _isVisible(dynamic val) {
    return !parseInvisibleValue(val); // Use mixin's parseInvisibleValue
  }

  void _parseResponseData() async {
    if (recordId != 0) {
      await _loadRecordState();
    }

    if (_fieldData == null || _fieldData is! Map<String, dynamic>) {
      return;
    }

    final Map<String, dynamic> responseData =
    _fieldData as Map<String, dynamic>;
    log('\n\n **********  $_recordState \n\n');
    print(responseData.containsKey('apps_data'));
    print('********** ');

    if (_isSettingsForm() && responseData.containsKey('apps_data')) {
      log("jimster : ${responseData['apps_data']}");
      final appsRaw = responseData['apps_data'] as Map<String, dynamic>;
      print(
          'Unexpected type for apps_data: ${responseData['apps_data'].runtimeType}');

      setState(() {
        settingsSections = appsRaw.entries
            .where((entry) {
          if (widget.moduleName != null && widget.moduleName!.isNotEmpty) {
            final appData = entry.value as Map<String, dynamic>;
            final appModule = appData['app_name'] as String?;
            log("appModule  : $appModule");
            log("moduleName  : ${widget.moduleName}");
            if (widget.moduleName == "Settings" &&
                appModule == "General Settings") {
              return true;
            }
            return appModule == widget.moduleName;
          }
          return true;
        })
            .map((entry) {
          log("entry of the appdata  : $entry");
          final appKey = entry.key;
          final appData = entry.value as Map<String, dynamic>;

          final appName = (appData['app_name'] as String?)?.trim() ??
              (appData['attributes']?['data-string'] as String?)?.trim() ??
              appKey;

          log("appName  : $appName");

          final logo = appData['attributes']?['logo'] as String?;

          final blocks = (appData['blocks'] as Map<String, dynamic>?)
              ?.entries
              .map((blockEntry) {
            final blockMap =
            blockEntry.value as Map<String, dynamic>;
            final blockTitle =
                blockMap['block_name'] as String? ?? '';
            final blockName =
                blockMap['attributes']?['name'] as String? ??
                    blockTitle;

            final settings = (blockMap['settings']
            as Map<String, dynamic>?)
                ?.entries
                .map((settingEntry) {
              final settingMap = settingEntry.value
              as Map<String, dynamic>;
              final settingId = settingEntry.key;

              final fields = (settingMap['fields']
              as List<dynamic>?)
                  ?.map((field) {
                final fieldMap =
                field as Map<String, dynamic>;
                final fieldName =
                    fieldMap['name'] as String? ??
                        'unknown_field';
                final fieldType =
                    allPythonFields[fieldName]
                    ?['type'] as String? ??
                        'char';
                final xmlAttributes = fieldMap[
                'attributes']
                as Map<String, dynamic>? ??
                    {};
                final modelFieldDetails = fieldMap[
                'model_field_details']
                as Map<String, dynamic>? ??
                    {};

                final invisible =
                parseInvisibleValue(
                    xmlAttributes[
                    'invisible']);
                final readonly =
                parseInvisibleValue(
                    xmlAttributes['readonly'] ??
                        modelFieldDetails[
                        'readonly'] ??
                        false);
                final widget =
                xmlAttributes['widget']
                as String?;
                final fieldString =
                    (modelFieldDetails['label']
                    ?['string']
                    as String?) ??
                        modelFieldDetails[
                        'field_description']
                        as String? ??
                        fieldName;

                return {
                  'name': fieldName,
                  'type': fieldType,
                  'invisible': invisible,
                  'readonly': readonly,
                  'widget': widget,
                  'string': fieldString,
                };
              })
                  .where((field) =>
                  _isVisible(field['invisible']))
                  .toList() ??
                  [];

              return {
                'id': settingId,
                'fields': fields,
                'widget': settingMap['widget'] as String?,
                'invisible': parseInvisibleValue(
                    settingMap['attributes']?['invisible']),
                'settingsMap': settingMap,
              };
            })
                .where((setting) =>
            setting['invisible'] != true &&
                setting['invisible'] != 1)
                .toList() ??
                [];

            return {
              'title': blockTitle,
              'name': blockName,
              'settings': settings,
              'invisible': parseInvisibleValue(
                  blockMap['attributes']?['invisible']),
            };
          })
              .where((block) =>
          block['invisible'] != true && block['invisible'] != 1)
              .toList() ??
              [];

          return {
            'name': appName,
            'logo': logo,
            'blocks': blocks,
            'invisible':
            parseInvisibleValue(appData['attributes']?['invisible']),
          };
        })
            .where((app) => app['invisible'] != true && app['invisible'] != 1)
            .toList();
      });
    } else {
      print("entered in the else case");
      if (responseData.containsKey('smart_buttons')) {
        final List<dynamic> smartButtonsData =
        responseData['smart_buttons'] as List<dynamic>;
        setState(() {
          smartButtons = smartButtonsData.map((button) {
            final buttonMap = button as Map<String, dynamic>;
            final attributes = buttonMap['attributes'] as Map<String, dynamic>;
            final smartButtonFields =
                (buttonMap['smart_button_fields'] as List<dynamic>?) ?? [];
            final fieldNames = smartButtonFields
                .map((field) =>
            (field as Map<String, dynamic>)['name'] as String)
                .toList();
            final invisible = parseInvisibleValue(attributes['invisible']);
            print(
                "invisible  : ${attributes['invisible']}  parsed invisible : ${invisible}");
            final attributeString = attributes['string'] as String?;
            final pythonString =
            buttonMap['field_python_attributes']?['string'] as String?;
            final displayString =
            (attributeString == null || attributeString.trim().isEmpty)
                ? (pythonString ?? 'Unnamed')
                : attributeString;

            return {
              'name': attributes['name'] as String? ??
                  buttonMap['smart_button_name'] as String? ??
                  'unnamed_button',
              'string': displayString,
              'type': attributes['type'] as String? ?? 'object',
              'class': attributes['class'] as String? ?? 'default',
              'color':
              _getButtonColor(attributes['class'] as String? ?? 'default'),
              'icon': attributes['icon'] as String?,
              'invisible': invisible,
              'field_names': fieldNames,
            };
          }).toList();
        });
      }

      if (responseData.containsKey('body_fields')) {
        final List<dynamic> bodyFields =
        responseData['body_fields'] as List<dynamic>;
        setState(() {
          bodyField = bodyFields.map((field) {
            final fieldMap = field as Map<String, dynamic>;
            final fieldName =
                fieldMap['main_field_name'] as String? ?? 'unknown_field';
            final fieldType =
                allPythonFields[fieldName]?['type'] as String? ?? 'char';
            final xmlAttributes =
                fieldMap['xml_attributes'] as Map<String, dynamic>? ?? {};
            final pythonAttributes =
            fieldMap['python_attributes'] as Map<String, dynamic>?;
            final invisible = parseInvisibleValue(xmlAttributes
                .containsKey('invisible')
                ? xmlAttributes['invisible']
                : (pythonAttributes != null &&
                pythonAttributes.containsKey('invisible')
                ? pythonAttributes['invisible']
                : null));

            print(
                "invisible  in body : ${fieldName}  ${xmlAttributes.containsKey('invisible') ? xmlAttributes['invisible'] : (pythonAttributes != null && pythonAttributes.containsKey('invisible') ? pythonAttributes['invisible'] : null)}  parsed invisible : ${invisible}");
            final readonly = parseInvisibleValue(xmlAttributes['readonly'] ??
                (pythonAttributes != null &&
                    pythonAttributes.containsKey('readonly')
                    ? pythonAttributes['readonly']
                    : false));
            final fieldString =
                allPythonFields[fieldName]?['string'] as String? ?? fieldName;
            final subFieldName = fieldMap['sub_field_name'] as String?;

            return {
              'main_field_name': fieldName,
              'type': fieldType,
              'invisible': invisible,
              'string': fieldString,
              'widget': xmlAttributes['widget'],
              'readonly': readonly,
              'sub_field_name': subFieldName,
            };
          }).toList();
        });
      }

      if (responseData.containsKey('header_buttons')) {
        final List<dynamic> headerButtonsData =
        responseData['header_buttons'] as List<dynamic>;
        setState(() {
          headerButtons = headerButtonsData.map((button) {
            log("headerButtonsData  : $button");
            final buttonMap = button as Map<String, dynamic>;

            dynamic attributesRaw = buttonMap['attributes'];

            Map<String, dynamic> attributes;
            if (attributesRaw is String) {
              try {
                String fixedJson = attributesRaw
                    .replaceAll("True", "true")
                    .replaceAll("False", "false")
                    .replaceAll(': "', ': "TEMP_QUOTE_START')
                    .replaceAll('"', '\\"')
                    .replaceAll('TEMP_QUOTE_START', '"')
                    .replaceAll("'", '"');
                attributes = jsonDecode(fixedJson) as Map<String, dynamic>;
              } catch (e) {
                try {
                  attributes = _parseAttributesManually(attributesRaw);
                } catch (e2) {
                  attributes = {};
                }
              }
            } else if (attributesRaw is Map<String, dynamic>) {
              attributes = attributesRaw;
            } else {
              attributes = {};
            }

            final invisible = parseInvisibleValue(attributes['invisible']);

            log("name  : ${attributes['name']}  , string  : ${attributes['string']} , $invisible");

            return {
              'name': attributes['name'] as String? ?? 'unnamed_button',
              'string': attributes['string'] as String? ?? 'Unnamed',
              'type': attributes['type'] as String? ?? 'object',
              'class': attributes['class'] as String? ?? 'default',
              'color':
              _getButtonColor(attributes['class'] as String? ?? 'default'),
              'invisible': invisible,
            };
          }).toList();
        });
      }

      if (responseData.containsKey('notebook_fields')) {
        final notebookSections =
        responseData['notebook_fields'] as List<dynamic>;
        setState(() {
          notebookPages = notebookSections
              .map((page) {
            final pageMap = page as Map<String, dynamic>;
            final xmlAttrs =
                pageMap['xml_attributes'] as Map<String, dynamic>? ?? {};

            final pageInvisible = parseInvisibleValue(xmlAttrs['invisible']);

            if (pageInvisible == true || pageInvisible == 1) {
              return null;
            }

            final fields = (pageMap['fields'] as List<dynamic>)
                .map((field) {
              final fieldMap = field as Map<String, dynamic>;
              final fieldName =
                  fieldMap['main_field_name'] as String? ??
                      'unknown_field';

              if (fieldName == 'unknown_field' ||
                  fieldName == 'custom_value' ||
                  fieldName ==
                      'custom_product_template_attribute_value_id' ||
                  fieldName == 'unknown_field') {
                return null;
              }

              final xmlAttrs =
                  fieldMap['xml_attributes'] as Map<String, dynamic>? ??
                      {};
              final fieldType =
                  allPythonFields[fieldName]?['type'] as String? ??
                      'char';

              final invisible = parseInvisibleValue(xmlAttrs['invisible']);
              final invisibleColumn = parseInvisibleValue(
                  xmlAttrs['invisible_column']);
              final optional = xmlAttrs['optional'] as String?;

              final modeFields =
                  (fieldMap['mode_fields'] as List<dynamic>?)
                      ?.map((mf) {
                    final mfMap = mf as Map<String, dynamic>;
                    final mfName =
                    mfMap['mode_field_name'] as String;
                    final mfXmlAttrs = mfMap['xml_attributes']
                    as Map<String, dynamic>? ??
                        {};
                    final mfPythonAttrs =
                        mfMap['python_attributes']
                        as Map<String, dynamic>? ??
                            {};

                    final mfInvisible = parseInvisibleValue(
                        mfXmlAttrs['invisible']);
                    final mfInvisibleCol = parseInvisibleValue(
                        mfXmlAttrs['column_invisible']);
                    final mfOptional = mfXmlAttrs['optional']
                    as String?;

                    final mfType = allPythonFields[mfName]
                    ?['type'] as String? ??
                        'char';
                    final mfDomain = mfXmlAttrs['domain'] ??
                        mfPythonAttrs['domain'] ??
                        allPythonFields[mfName]?['domain'] ??
                        '[]';
                    final mfOptions = mfXmlAttrs['options'] ??
                        mfPythonAttrs['options'] ??
                        allPythonFields[mfName]?['options'];

                    if (mfInvisible != true &&
                        mfInvisible != 1 &&
                        mfInvisibleCol != true &&
                        mfInvisibleCol != 1) {
                      return {
                        'name': mfName,
                        'type': mfType,
                        'domain': mfDomain,
                        'options': mfOptions,
                        'optional': mfOptional,
                      };
                    }
                    return null;
                  })
                      .whereType<Map<String, dynamic>>()
                      .toList() ??
                      [];

              final fieldDef = {
                'name': fieldName,
                'type': fieldType,
                'string':
                allPythonFields[fieldName]?['string'] as String? ??
                    fieldName,
                'widget': xmlAttrs['widget'],
                'options': xmlAttrs['options'],
                'readonly': xmlAttrs['readonly'] ??
                    allPythonFields[fieldName]?['readonly'] ??
                    false,
                'invisible': invisible,
                'invisible_column': invisibleColumn,
                'optional': optional,
                'mode_fields': modeFields,
                if (fieldType == 'one2many') ...{
                  'relation_model': allPythonFields[fieldName]
                  ?['relation'] as String? ??
                      '',
                  'relation_field': allPythonFields[fieldName]
                  ?['relation_field'] as String? ??
                      '',
                  'mode_fields': () {
                    List<Map<String, dynamic>> updatedModeFields =
                    List.from(modeFields);

                    if (responseData
                        .containsKey('get_all_mode_fields')) {
                      final allModeFields =
                      responseData['get_all_mode_fields']
                      as Map<String, dynamic>;
                      final modeFieldKey = fieldName;
                      final parentKey = notebookSections.firstWhere(
                              (page) =>
                              (page as Map<String, dynamic>)['fields']
                                  .any((f) =>
                              (f as Map<String, dynamic>)[
                              'main_field_name'] ==
                                  fieldName),
                          orElse: () => null)?['page_name'] as String?;

                      if (parentKey != null &&
                          allModeFields.containsKey(parentKey)) {
                        final relationData = allModeFields[parentKey]
                        as Map<String, dynamic>;
                        if (relationData.containsKey(modeFieldKey)) {
                          final additionalFieldsData =
                          relationData[modeFieldKey]
                          as Map<String, dynamic>;
                          final additionalFields =
                          additionalFieldsData['fields']
                          as List<dynamic>;

                          for (var additionalField
                          in additionalFields) {
                            final additionalFieldMap =
                            additionalField as Map<String, dynamic>;
                            final additionalFieldName =
                            additionalFieldMap['name'] as String;
                            final additionalXmlAttrs =
                                additionalFieldMap['xml_attributes']
                                as Map<String, dynamic>? ??
                                    {};
                            final additionalPythonAttrs =
                                additionalFieldMap['python_attributes']
                                as Map<String, dynamic>? ??
                                    {};

                            final additionalInvisible =
                            parseInvisibleValue(
                                additionalXmlAttrs['invisible']);
                            final additionalInvisibleCol =
                            parseInvisibleValue(additionalXmlAttrs[
                            'column_invisible']);
                            final additionalType =
                                additionalPythonAttrs['type']
                                as String? ??
                                    'char';
                            final additionalOptional = additionalXmlAttrs[
                            'optional']
                            as String?;

                            if (additionalInvisible != true &&
                                additionalInvisible != 1 &&
                                additionalInvisibleCol != true &&
                                additionalInvisibleCol != 1) {
                              updatedModeFields.add({
                                'name': additionalFieldName,
                                'type': additionalType,
                                'domain': additionalXmlAttrs[
                                'domain'] ??
                                    additionalPythonAttrs['domain'] ??
                                    '[]',
                                'options': additionalXmlAttrs[
                                'options'] ??
                                    additionalPythonAttrs['options'],
                                'optional': additionalOptional,
                              });
                            }
                          }
                        }
                      }
                    }
                    return updatedModeFields;
                  }(),
                },
              };

              if (fieldType == 'one2many') {}

              return fieldDef;
            })
                .whereType<Map<String, dynamic>>()
                .toList();

            return {
              'name': pageMap['page_string'] as String? ??
                  pageMap['page_name'] as String? ??
                  'Unnamed',
              'fields': fields,
              'invisible': pageInvisible,
            };
          })
              .whereType<Map<String, dynamic>>()
              .toList();
        });
      }

      if (responseData.containsKey('wizard_data')) {
        final List<dynamic> wizardFields =
        responseData['wizard_data'] as List<dynamic>;
        log("wizardFields  : $wizardFields");
        setState(() {
          wizardData = wizardFields
              .where((field) {
            final fieldMap = field as Map<String, dynamic>;
            final fieldName =
                fieldMap['main_field_name'] as String? ?? 'unknown';
            return fieldName.isNotEmpty && fieldName != 'unknown';
          })
              .map((field) {
            log("field kimster : $field");
            final fieldMap = field as Map<String, dynamic>;
            final fieldName =
                fieldMap['main_field_name'] as String? ?? 'unknown';

            final xmlAttributes =
                fieldMap['xml_attributes'] as Map<String, dynamic>? ?? {};
            final pythonAttributes =
                fieldMap['python_attributes'] as Map<String, dynamic>? ??
                    {};
            final fieldType = pythonAttributes['type'] as String? ?? 'char';
            final invisible = parseInvisibleValue(xmlAttributes['invisible']);
            print("invisible count $fieldName: $invisible");
            final readonly = parseInvisibleValue(xmlAttributes['readonly'] ??
                pythonAttributes['readonly'] ??
                false);
            final required = parseInvisibleValue(xmlAttributes['required'] ??
                pythonAttributes['required'] ??
                false);
            final fieldString =
                pythonAttributes['string'] as String? ?? fieldName;
            final widget = xmlAttributes['widget'] as String?;
            final options =
                xmlAttributes['options'] ?? pythonAttributes['options'];

            log("fieldString : $fieldString , widget : $widget , options : $options , required : $required , readonly : $readonly  , invisible : $invisible , fieldType : $fieldType , pythonAttributes : $pythonAttributes , xmlAttributes : $xmlAttributes , fieldName : $fieldName");

            return {
              'name': fieldName,
              'type': fieldType,
              'string': fieldString,
              'invisible': invisible,
              'readonly': readonly,
              'required': required,
              'widget': widget,
              'options': options,
            };
          })
              .where((field) =>
          field['invisible'] != true && field['invisible'] != 1)
              .toList();

          footerButtons = [];
          for (var field in wizardFields) {
            final fieldMap = field as Map<String, dynamic>;
            if (fieldMap.containsKey('footer')) {
              print("inside the footer");
              final List<dynamic> footerButtonsData =
              fieldMap['footer'] as List<dynamic>;
              log("footerButtonsData: $footerButtonsData");
              footerButtons.addAll(footerButtonsData.map((button) {
                final buttonMap = button as Map<String, dynamic>;
                final attributes =
                    buttonMap['attributes'] as Map<String, dynamic>? ?? {};
                final invisible = parseInvisibleValue(attributes['invisible']);
                return {
                  'name': buttonMap['name'] as String?,
                  'type': buttonMap['type'] as String?,
                  'string': buttonMap['string'] as String? ?? 'Unnamed',
                  'class': buttonMap['class'] as String? ?? 'default',
                  'color': _getButtonColor(
                      buttonMap['class'] as String? ?? 'default'),
                  'invisible': invisible,
                  'special': attributes['special'] as String?,
                  'hotkey': attributes['data-hotkey'] as String?,
                };
              }).toList());
            }
          }
          log("Parsed footerButtons: $footerButtons");
        });
      }
    }
  }

  Map<String, dynamic> _parseAttributesManually(String attributesStr) {
    Map<String, dynamic> result = {};
    if (attributesStr.startsWith('{') && attributesStr.endsWith('}')) {
      String content =
      attributesStr.substring(1, attributesStr.length - 1).trim();
      List<String> pairs = [];
      int startIndex = 0;
      int nestLevel = 0;
      bool inQuotes = false;
      String quoteChar = '';

      for (int i = 0; i < content.length; i++) {
        String char = content[i];
        if ((char == '"' || char == "'") &&
            (i == 0 || content[i - 1] != '\\')) {
          if (!inQuotes) {
            inQuotes = true;
            quoteChar = char;
          } else if (char == quoteChar) {
            inQuotes = false;
          }
        }
        if (!inQuotes) {
          if (char == '{' || char == '[')
            nestLevel++;
          else if (char == '}' || char == ']')
            nestLevel--;
          else if (char == ',' && nestLevel == 0) {
            pairs.add(content.substring(startIndex, i).trim());
            startIndex = i + 1;
          }
        }
        if (i == content.length - 1)
          pairs.add(content.substring(startIndex).trim());
      }

      for (String pair in pairs) {
        List<String> keyValue = pair.split(':');
        if (keyValue.length >= 2) {
          String key = keyValue[0].trim();
          if ((key.startsWith('"') && key.endsWith('"')) ||
              (key.startsWith("'") && key.endsWith("'"))) {
            key = key.substring(1, key.length - 1);
          }
          String valueStr = keyValue.sublist(1).join(':').trim();
          dynamic value;
          if ((valueStr.startsWith('"') && valueStr.endsWith('"')) ||
              (valueStr.startsWith("'") && valueStr.endsWith("'"))) {
            value = valueStr.substring(1, valueStr.length - 1);
          } else if (valueStr == "True" || valueStr == "true") {
            value = true;
          } else if (valueStr == "False" || valueStr == "false") {
            value = false;
          } else if (valueStr.startsWith('{') && valueStr.endsWith('}')) {
            try {
              value = _parseAttributesManually(valueStr);
            } catch (e) {
              value = valueStr;
            }
          } else {
            try {
              value = num.parse(valueStr);
            } catch (e) {
              value = valueStr;
            }
          }
          result[key] = value;
        }
      }
    }
    return result;
  }

  Color _getButtonColor(String className) {
    switch (className) {
      case 'oe_highlight':
        return Colors.blue;
      case 'btn-primary':
        return Colors.green;
      case 'btn-danger':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  SnackBar _buildSnackBar({
    required String message,
    Duration duration = const Duration(seconds: 3),
    Color backgroundColor = Colors.grey,
    TextStyle textStyle = const TextStyle(color: Colors.white),
    SnackBarAction? action,
  }) {
    return SnackBar(
      content: Text(
        message,
        style: textStyle,
      ),
      duration: duration,
      backgroundColor: backgroundColor,
      action: action,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
    );
  }

  void _showHeaderButtonsMenu() {
    final visibleButtons = headerButtons.where((button) {
      final invisible = button['invisible'];
      return invisible != true && invisible != 'True' && invisible != 1;
    }).toList();

    if (visibleButtons.isEmpty) {
      return;
    }

    showMenu<Map<String, dynamic>>(
      context: context,
      position: const RelativeRect.fromLTRB(1, 80, 0, 0),
      items: visibleButtons
          .map((button) => PopupMenuItem<Map<String, dynamic>>(
        value: button,
        child: Container(
          width: double.infinity,
          padding:
          const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          decoration: BoxDecoration(
            color: button['color'] as Color,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Text(
            button['string'] ?? 'Unnamed',
            style: TextStyle(
              color: (button['color'] as Color).computeLuminance() > 0.5
                  ? Colors.black
                  : Colors.white,
            ),
          ),
        ),
      ))
          .toList(),
      elevation: 0,
    ).then((selected) {
      if (selected != null) {
        print("button details in _showHeaderButtonsMenu : ${selected}");
        _onButtonPressed(selected['name'], selected['type']);
      }
    });
  }

  void _onButtonPressed(String? name, String? type) async {
    if (name == null || type == null) return;

    log('Button pressed: name=$name, type=$type');

    final success = await handleButtonAction(
      buttonData: {
        'name': name,
        'type': type,
        'context': {'active_id': widget.recordId}
      },
      buildContext: context,
    );

    if (success && mounted) {
      _loadRecordState();
    }
  }

  Widget _buildSmartButtons() {
    final visibleButtons = smartButtons.where((button) {
      final invisible = button['invisible'];
      final fieldNames = button['field_names'] as List<String>? ?? [];

      if (invisible == true || invisible == 'True' || invisible == 1) {
        return false;
      }

      if (fieldNames.isEmpty) {
        return true;
      }

      for (String fieldName in fieldNames) {
        final fieldValue = _recordState[fieldName];
        if (fieldValue == null) {
          return false;
        } else if (fieldValue is num) {
          return fieldValue != 0;
        } else if (fieldValue is List) {
          return fieldValue.isNotEmpty;
        } else if (fieldValue is String) {
          return fieldValue.isNotEmpty;
        } else if (fieldValue is bool) {
          return fieldValue;
        }
      }

      return true;
    }).toList();

    if (visibleButtons.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: visibleButtons.map((button) {
            final fieldNames = button['field_names'] as List<String>? ?? [];
            final displayValue = fieldNames.isNotEmpty
                ? ' (${fieldNames.map((name) => _recordState[name] ?? 'N/A').join(', ')})'
                : '';

            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: ElevatedButton.icon(
                onPressed: () {
                  print("button details : ${button}");
                  _onButtonPressed(button['name'], button['type']);
                },
                icon: button['icon'] != null
                    ? Icon(_getIconFromFaClass(button['icon'] as String))
                    : const Icon(Icons.touch_app),
                label: Text('${button['string'] ?? 'Unnamed'}$displayValue'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: button['color'] as Color,
                  foregroundColor:
                  (button['color'] as Color).computeLuminance() > 0.5
                      ? Colors.black
                      : Colors.white,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  IconData _getIconFromFaClass(String faClass) {
    switch (faClass) {
      case 'fa-puzzle-piece':
        return Icons.extension;
      case 'fa-check-square-o':
        return Icons.check_box;
      case 'fa-check':
        return Icons.check;
      case 'fa-truck':
        return Icons.local_shipping;
      case 'fa-shopping-basket':
        return Icons.shopping_basket;
      case 'fa-pencil-square-o':
        return Icons.edit;
      case 'fa-credit-card':
        return Icons.credit_card;
      default:
        return Icons.touch_app;
    }
  }

  Future<void> _saveNewRecord() async {
    try {
      final recordData = Map<String, dynamic>.from(_recordState);
      recordData['company_id'] = _companyId ?? 1;

      for (var fieldName in _recordState.keys) {
        final fieldType = allPythonFields[fieldName]?['type'] ?? 'char';
        if (fieldType == 'one2many' && _recordState[fieldName] is List) {
          final one2ManyData = _recordState[fieldName] as List<dynamic>;
          recordData[fieldName] = one2ManyData
              .map((item) {
            if (item is Map<String, dynamic>) {
              return [0, 0, item];
            } else if (item is int) {
              return [4, item, 0];
            } else {
              log('Unexpected one2many item type for $fieldName: $item');
              return null;
            }
          })
              .where((item) => item != null)
              .toList();
        }
      }

      final newId = await _odooClientController.client.callKw({
        'model': widget.modelName,
        'method': 'create',
        'args': [recordData],
        'kwargs': {},
      });

      if (newId is int && newId > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          _buildSnackBar(
            message: 'Record created successfully',
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          _buildSnackBar(
            message: 'Failed to create record',
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      log('Error creating record: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        _buildSnackBar(
          message: 'Error creating record: $e',
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildSettingsSections() {
    if (settingsSections.isEmpty) {
      return const Center(child: Text('No settings available'));
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: settingsSections.length,
      separatorBuilder: (context, index) => const SizedBox(height: 32),
      itemBuilder: (context, appIndex) {
        final app = settingsSections[appIndex];
        final appName = app['name'] as String;
        final logo = app['logo'] as String?;
        final blocks = (app['blocks'] as List<dynamic>)
            .whereType<Map<String, dynamic>>()
            .toList();

        List<Map<String, dynamic>> groupedBlocks = [];
        for (var block in blocks) {
          final blockTitle = block['title'] as String? ?? '';
          if (blockTitle == '' && groupedBlocks.isNotEmpty) {
            final lastBlock = groupedBlocks.last;
            final lastBlockSettings =
            (lastBlock['settings'] as List<dynamic>).toList();
            final currentBlockSettings =
            (block['settings'] as List<dynamic>).toList();
            lastBlock['settings'] = [
              ...lastBlockSettings,
              ...currentBlockSettings
            ];
          } else {
            groupedBlocks.add(Map<String, dynamic>.from(block));
          }
        }

        return Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (logo != null) Image.network(logo, width: 40, height: 40),
                  if (logo != null) const SizedBox(width: 12),
                  Text(
                    appName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),

              ...groupedBlocks.map((block) {
                final blockName = block['title'] as String? ?? 'Settings';
                final blockKey = '$appName-$blockName';
                final settings = (block['settings'] as List<dynamic>)
                    .whereType<Map<String, dynamic>>()
                    .toList();

                final isNamedBlock = blockName != '';
                final isExpanded =
                isNamedBlock ? _expandedBlocks.contains(blockKey) : true;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isNamedBlock)
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            if (isExpanded) {
                              _expandedBlocks.remove(blockKey);
                            } else {
                              _expandedBlocks.add(blockKey);
                            }
                          });
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: isExpanded
                                ? ODOO_COLOR.withOpacity(0.3)
                                : ODOO_COLOR.withOpacity(0.1),
                            border: const Border(
                              bottom: BorderSide(color: Colors.grey, width: 1),
                            ),
                          ),
                          child: Row(
                            children: [
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  blockName,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: isExpanded
                                        ? ODOO_COLOR.withOpacity(0.5)
                                        : ODOO_COLOR,
                                  ),
                                ),
                              ),
                              Icon(
                                isExpanded
                                    ? Icons.expand_less
                                    : Icons.expand_more,
                                color: isExpanded ? ODOO_COLOR : Colors.black54,
                              ),
                            ],
                          ),
                        ),
                      ),

                    if (!isNamedBlock || isExpanded)
                      ...settings.map((setting) {
                        final settingTitle = setting['settingsMap']
                        ?['attributes']?['string'] as String? ??
                            '';
                        final helpText = setting['settingsMap']?['attributes']
                        ?['help'] as String?;
                        final fields = (setting['fields'] as List<dynamic>)
                            .whereType<Map<String, dynamic>>()
                            .toList();

                        return Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: ODOO_COLOR.withOpacity(0),
                            borderRadius: BorderRadius.circular(8),
                            border:
                            Border.all(color: Colors.grey[200]!, width: 1),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (settingTitle.isNotEmpty)
                                  Text(
                                    settingTitle,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black,
                                    ),
                                  ),
                                if (helpText != null) ...[
                                  const SizedBox(height: 6),
                                  Text(
                                    helpText,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 8),
                                ...fields.map((field) {
                                  final fieldName = field['name'] as String?;
                                  return Column(
                                    children: [
                                      if (fieldName != null)
                                        _buildFieldWidget(
                                          fieldName,
                                          fieldData: field,
                                        ),
                                      const SizedBox(height: 16),
                                      if ((setting['settingsMap']?['buttons']
                                      as List?)
                                          ?.isNotEmpty ??
                                          false)
                                        ...((setting['settingsMap']!['buttons']
                                        as List)
                                            .whereType<Map<String, dynamic>>()
                                            .map((btn) {
                                          final btnString =
                                              btn['string'] as String? ??
                                                  'Unnamed Button';
                                          final btnName =
                                          btn['name']?.toString();
                                          final btnType =
                                          btn['type']?.toString();
                                          final btnInvisible = btn['attributes']
                                          ?['invisible'] as String?;

                                          bool isVisible = true;
                                          if (btnInvisible != null &&
                                              btnInvisible.isNotEmpty) {
                                            if (btnInvisible.contains(
                                                'group_cash_rounding')) {
                                              final fieldValue = _recordState[
                                              'group_cash_rounding'] ??
                                                  false;
                                              isVisible =
                                              btnInvisible.startsWith('not')
                                                  ? !fieldValue
                                                  : fieldValue;
                                            }
                                          }

                                          if (!isVisible)
                                            return const SizedBox();

                                          return Padding(
                                            padding:
                                            const EdgeInsets.only(top: 8.0),
                                            child: InkWell(
                                              onTap: () async {
                                                if (btnName != null &&
                                                    btnType != null) {
                                                  final success =
                                                  await handleButtonAction(
                                                    buttonData: {
                                                      'name': btnName,
                                                      'type': btnType,
                                                      'context': {
                                                        'active_id':
                                                        widget.recordId,
                                                        'active_model':
                                                        widget.modelName,
                                                      },
                                                    },
                                                    buildContext: context,
                                                  );
                                                  if (success) {
                                                    await _loadRecordState();
                                                  }
                                                } else {
                                                  log('Button missing name or type: $btn');
                                                }
                                              },
                                              child: Row(
                                                children: [
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    btnString,
                                                    style: TextStyle(
                                                      color: ODOO_COLOR,
                                                      fontSize: 14.0,
                                                      fontWeight:
                                                      FontWeight.w500,
                                                      decoration: TextDecoration
                                                          .underline,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        })),
                                    ],
                                  );
                                }),
                              ],
                            ),
                          ),
                        );
                      }),
                  ],
                );
              }),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    bool _isSettingsForm() {
      return widget.formData?.contains('class="oe_form_configuration"') ??
          false;
    }

    final visibleHeaderButtons = headerButtons.where((button) {
      final invisible = button['invisible'];
      return invisible != true && invisible != 'True' && invisible != 1;
    }).toList();
    String appBarTitle;
    if (widget.modelName == 'res.config.settings' &&
        widget.moduleName != null &&
        widget.moduleName!.isNotEmpty) {
      if (widget.moduleName == 'Settings') {
        appBarTitle = 'General Settings';
      } else {
        appBarTitle = '${widget.moduleName!} Settings';
      }
    } else {
      appBarTitle = widget.name != null && widget.name!.isNotEmpty
          ? widget.name!
          : 'Form View';
    }
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: ODOO_COLOR,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        ),
        title: Text(
          appBarTitle,
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          if (widget.recordId == 0)
            IconButton(
              icon: const Icon(Icons.save, color: Colors.white),
              onPressed: _saveNewRecord,
            ),
          if (visibleHeaderButtons.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              onPressed: _showHeaderButtonsMenu,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
          child:
          Text(_error!, style: const TextStyle(color: Colors.red)))
          : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_isSettingsForm()) _buildSettingsSections(),
            if (!_isSettingsForm()) ...[
              if (smartButtons.isNotEmpty) _buildSmartButtons(),
              if (bodyField.isNotEmpty || wizardData.isNotEmpty)
                _buildMainFields(),
              if (notebookPages.isNotEmpty) _buildNotebookSection(),
              if (footerButtons.isNotEmpty) _buildFooterButtons(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFooterButtons() {
    final visibleButtons = footerButtons.where((button) {
      final invisible = button['invisible'];
      return invisible != true && invisible != 'True' && invisible != 1;
    }).toList();

    if (visibleButtons.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        Color getTextColor(Color? backgroundColor) {
          if (backgroundColor == null) return Colors.white;
          return backgroundColor.computeLuminance() > 0.5
              ? Colors.black
              : Colors.white;
        }

        if (constraints.maxWidth < 600) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: visibleButtons.map((button) {
                final buttonColor = button['color'] as Color?;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      if (button['special'] == 'cancel') {
                        Navigator.pop(context);
                      } else {
                        _onButtonPressed(button['name'], button['type']);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonColor,
                      foregroundColor: getTextColor(buttonColor),
                      minimumSize: const Size.fromHeight(48),
                    ),
                    child: Text(
                      button['string'] ?? 'Unnamed',
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Wrap(
            alignment: WrapAlignment.end,
            spacing: 8.0,
            runSpacing: 8.0,
            children: visibleButtons.map((button) {
              final buttonColor = button['color'] as Color?;
              return ElevatedButton(
                onPressed: () {
                  if (button['special'] == 'cancel') {
                    Navigator.pop(context);
                  } else {
                    _onButtonPressed(button['name'], button['type']);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,
                  foregroundColor: getTextColor(buttonColor),
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                child: Text(button['string'] ?? 'Unnamed'),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildMainFields() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...bodyField.where((field) {
                final invisible = field['invisible'];
                return invisible != true &&
                    invisible != 'True' &&
                    invisible != 1;
              }).map((field) => _buildFieldWidget(field['main_field_name'],
                  fieldData: field)),
              if (bodyField.isEmpty)
                ...wizardData.where((field) {
                  final invisible = field['invisible'];
                  return invisible != true &&
                      invisible != 'True' &&
                      invisible != 1;
                }).map((field) =>
                    _buildFieldWidget(field['name'], fieldData: field)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotebookSection() {
    return DefaultTabController(
      length: notebookPages.length,
      child: Column(
        children: [
          Container(
            color: Colors.grey[200],
            child: TabBar(
              isScrollable: true,
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.grey[600],
              indicatorColor: Colors.blue,
              tabs: notebookPages
                  .map((page) => Tab(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(page['name'] ?? 'Unnamed',
                      style: const TextStyle(fontSize: 16)),
                ),
              ))
                  .toList(),
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: TabBarView(
              children: notebookPages.map((page) {
                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: (page['fields'] as List<Map<String, dynamic>>)
                      .where((field) {
                    final invisible = field['invisible'];
                    return invisible != true &&
                        invisible != 'True' &&
                        invisible != 1;
                  })
                      .map((field) =>
                      _buildFieldWidget(field['name'], fieldData: field))
                      .toList(),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldWidget(String fieldName,
      {Map<String, dynamic>? fieldData}) {
    final relational_field = fieldData?['name'];
    final label = fieldData?['string'] ??
        allPythonFields[fieldName]?['string'] ??
        fieldName;
    final rawValue = _recordState[fieldName];
    final type =
        fieldData?['type'] ?? allPythonFields[fieldName]?['type'] ?? 'char';
    final widgetType = fieldData?['widget'];

    List<dynamic> valueToOne2Many(dynamic val) {
      if (val is List) return val;
      return [];
    }

    bool valueToBool(dynamic val) {
      if (val is bool) return val;
      if (val is String) {
        final lowerVal = val.toLowerCase();
        return lowerVal == 'true' || lowerVal == '1';
      }
      return false;
    }

    DateTime? valueToDateTime(dynamic val) {
      if (val is DateTime) return val;
      if (val is String && val.isNotEmpty) {
        try {
          return DateTime.parse(val);
        } catch (e) {
          log("Error parsing DateTime for $fieldName: $e");
          return null;
        }
      }
      return null;
    }

    DateTime? valueToDate(dynamic val) {
      if (val is DateTime) return val;
      if (val is String && val.isNotEmpty) {
        try {
          return DateTime.parse(val);
        } catch (e) {
          log("Error parsing Date for $fieldName: $e");
          return null;
        }
      }
      return null;
    }

    List<dynamic> valueToMany2Many(dynamic val) {
      if (val is List) return val;
      return [];
    }

    int? valueToMany2One(dynamic val) {
      if (val is int) return val;
      if (val is List && val.isNotEmpty) return val[0] as int?;
      return null;
    }

    String? valueToSelection(dynamic val) {
      if (val == null) return null;
      return val.toString();
    }

    final value = type == 'boolean'
        ? valueToBool(rawValue ??
        configSettingsValues[fieldName] ??
        false)
        : (type == 'datetime'
        ? valueToDateTime(rawValue)
        : (type == 'date'
        ? valueToDate(rawValue)
        : (type == 'many2many'
        ? valueToMany2Many(rawValue)
        : (type == 'one2many'
        ? valueToOne2Many(rawValue)
        : (type == 'many2one'
        ? valueToMany2One(rawValue)
        : (type == 'selection'
        ? valueToSelection(rawValue)
        : rawValue))))));
    Future<List<Map<String, dynamic>>> fetchRelationOptions(
        String relation) async {
      if (relation == 'unknown' || relation.isEmpty) {
        return [];
      }
      try {
        final response = await _odooClientController.client.callKw({
          'model': relation,
          'method': 'search_read',
          'args': [[]],
          'kwargs': {
            'fields': ['id', 'name'],
            'limit': 100,
          },
        });
        return (response as List)
            .map((item) =>
        {'id': item['id'] as int, 'name': item['name'] as String})
            .toList();
      } catch (e) {
        return [];
      }
    }

    if (widgetType != null) {
      if (widgetType == 'account-tax-totals-field' && type == 'binary') {
        return TaxTotalsFieldWidget(
          name: label,
          value: rawValue,
        );
      }
      if (widgetType == 'boolean_toggle' && type == 'boolean') {
        return BooleanToggleFieldWidget(name: label, value: value);
      }

      if (widgetType == 'image' && type == 'binary') {
        final isReadonly = fieldData?['readonly'] ??
            allPythonFields[fieldName]?['readonly'] ??
            false;
        return ImageFieldWidget(
          name: label,
          value: value?.toString() ?? '',
          onChanged: isReadonly
              ? null
              : (newValue) => _updateFieldValue(fieldName, newValue),
          isReadonly: isReadonly,
          viewType: 'form',
        );
      }

      if (widgetType == 'email' && type == 'char') {
        return EmailFieldWidget(
          name: label,
          value: value?.toString() ?? '',
          onChanged: (newValue) => _updateFieldValue(fieldName, newValue),
        );
      }
      if (widgetType == 'url' && type == 'char') {
        return UrlFieldWidget(
          name: label,
          value: value?.toString() ?? '',
          onChanged: (newValue) => _updateFieldValue(fieldName, newValue),
        );
      }
      if (widgetType == 'text' && type == 'char') {
        return TextXmlFieldWidget(
          name: label,
          value: value?.toString() ?? '',
          onChanged: (newValue) => _updateFieldValue(fieldName, newValue),
        );
      }
      if (widgetType == 'phone' && type == 'char') {
        return PhoneFieldWidget(
          name: label,
          value: value?.toString() ?? '',
          onChanged: (newValue) => _updateFieldValue(fieldName, newValue),
        );
      }
      if (widgetType == 'float_time' && type == 'float') {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: FloatTimeFieldWidget(
            name: label,
            value: value is num ? value.toDouble() : 0.0,
            onChanged: (newValue) => _updateFieldValue(fieldName, newValue),
          ),
        );
      }
    }
    if (widgetType == 'documentation_link') {
      final path = fieldData?['path'] ?? '';
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: InkWell(
          onTap: () {
            log('Opening documentation: $path');
          },
          child: Row(
            children: [
              const Icon(Icons.help_outline, size: 20),
              const SizedBox(width: 8),
              Text(
                'Documentation',
                style: const TextStyle(color: Colors.blue, fontSize: 14.0),
              ),
            ],
          ),
        ),
      );
    }
    if (widgetType == 'res_config_invite_users') {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style:
              const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0),
            ),
            ElevatedButton(
              onPressed: () =>
                  _onButtonPressed('action_invite_users', 'action'),
              child: const Text('Invite Users'),
            ),
          ],
        ),
      );
    }
    switch (type) {
      case 'char':
        String defaultValue = '';
        if (value == null ||
            value.toString().isEmpty ||
            value.toString() == 'false') {
          if (configSettingsValues.containsKey(fieldName)) {
            defaultValue = configSettingsValues[fieldName]?.toString() ?? '';
          } else if (_defaultValues != null &&
              _defaultValues!.containsKey(fieldName)) {
            defaultValue = _defaultValues![fieldName]?.toString() ?? '';
          }
        }

        final effectiveValue = (value != null && value.toString() != 'false')
            ? value.toString()
            : defaultValue;

        if (fieldName == 'email') {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: EmailFieldWidget(
              name: label,
              value: effectiveValue,
              onChanged: (newValue) => _updateFieldValue(fieldName, newValue),
            ),
          );
        }
        if (fieldName == 'website') {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: UrlFieldWidget(
              name: label,
              value: effectiveValue,
              onChanged: (newValue) => _updateFieldValue(fieldName, newValue),
            ),
          );
        }
        if (fieldName == 'phone' || fieldName == 'mobile') {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: PhoneFieldWidget(
              name: label,
              value: effectiveValue,
              onChanged: (newValue) => _updateFieldValue(fieldName, newValue),
            ),
          );
        }
        final readonlyValue = fieldData?['readonly'] ??
            allPythonFields[fieldName]?['readonly'] ??
            false;
        final isReadonly = readonlyValue is bool
            ? readonlyValue
            : readonlyValue.toString().toLowerCase() == 'true';

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: CharFieldWidget(
            name: label,
            value: effectiveValue,
            onChanged: isReadonly
                ? null
                : (newValue) => _updateFieldValue(fieldName, newValue),
          ),
        );
      case 'many2one':
        final relation = allPythonFields[fieldName]?['relation'] ?? 'unknown';
        final readonlyValue = fieldData?['readonly'] ??
            allPythonFields[fieldName]?['readonly'] ??
            false;
        final isReadonly = readonlyValue is bool
            ? readonlyValue
            : readonlyValue.toString().toLowerCase() == 'true';

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: fetchRelationOptions(relation),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }
              if (snapshot.hasError || !snapshot.hasData) {
                return const Text('Error loading options',
                    style: TextStyle(color: Colors.red));
              }
              final options = snapshot.data!;

              int? currentValue = value;


              if (currentValue == null &&
                  _defaultValues != null &&
                  _defaultValues!.containsKey(fieldName)) {
                final defaultRaw = _defaultValues![fieldName];
                final defaultId = (defaultRaw is List && defaultRaw.isNotEmpty)
                    ? defaultRaw[0]
                    : defaultRaw;

                if (defaultId is int &&
                    options.any((option) => option['id'] == defaultId)) {
                  currentValue = defaultId;
                  if (!isReadonly) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _updateFieldValue(fieldName, currentValue);
                    });
                  }
                }
              }

              return Many2OneFieldWidget(
                name: label,
                value: currentValue,
                options: options,
                onValueChanged: isReadonly
                    ? (v) {}
                    : (newValue) => _updateFieldValue(fieldName, newValue),
                readonly: isReadonly,
              );
            },
          ),
        );
      case 'selection':
        final selectionOptions = allPythonFields[fieldName]?['selection'] ?? [];
        final readonlyValue = fieldData?['readonly'] ??
            allPythonFields[fieldName]?['readonly'] ??
            false;
        final isReadonly = readonlyValue is bool
            ? readonlyValue
            : readonlyValue.toString().toLowerCase() == 'true';

        String? defaultValue;
        if (value == null && selectionOptions.isNotEmpty) {
          if (_defaultValues != null &&
              _defaultValues!.containsKey(fieldName)) {
            defaultValue = _defaultValues![fieldName]?.toString();
            if (defaultValue != null &&
                !selectionOptions
                    .any((option) => option[0].toString() == defaultValue)) {
              defaultValue = null;
            }
          }
          if (defaultValue == null && selectionOptions.isNotEmpty) {
            defaultValue = selectionOptions[0][0].toString();
          }
          if (defaultValue != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _updateFieldValue(fieldName, defaultValue);
            });
          }
        }

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: SelectionFieldWidget(
            name: label,
            value: value as String? ?? defaultValue,
            options: selectionOptions,
            onChanged: isReadonly
                ? null
                : (newValue) => _updateFieldValue(fieldName, newValue),
            readonly: isReadonly,
          ),
        );
      case 'binary':
        final isReadonly = fieldData?['readonly'] ??
            allPythonFields[fieldName]?['readonly'] ??
            false;
        String? validatedValue;
        if (rawValue != null) {
          try {
            if (rawValue is String && rawValue.isNotEmpty) {
              base64Decode(rawValue);
              validatedValue = rawValue;
            }
          } on FormatException catch (e) {
            print("Invalid base64 data for $fieldName: $rawValue - Error: $e");
            validatedValue = null;
          }
        }
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: BinaryFieldWidget(
            name: label,
            value: validatedValue,
            onChanged: (newValue) => _updateFieldValue(fieldName, newValue),
          ),
        );
      case 'selection':
        final selectionOptions = allPythonFields[fieldName]?['selection'] ?? [];
        final readonlyValue = fieldData?['readonly'] ??
            allPythonFields[fieldName]?['readonly'] ??
            false;
        final isReadonly = readonlyValue is bool
            ? readonlyValue
            : readonlyValue.toString().toLowerCase() == 'true';
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: SelectionFieldWidget(
            name: label,
            value: value as String?,
            options: selectionOptions,
            onChanged: isReadonly
                ? null
                : (newValue) => _updateFieldValue(fieldName, newValue),
            readonly: isReadonly,
          ),
        );
      case 'date':
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: DateFieldWidget(
            name: label,
            value: value as DateTime?,
            onChanged: (newValue) => _updateFieldValue(
                fieldName, DateFormat('yyyy-MM-dd').format(newValue)),
          ),
        );
      case 'datetime':
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: DateTimeFieldWidget(
            name: label,
            value: value as DateTime?,
            onChanged: (newValue) =>
                _updateFieldValue(fieldName, newValue.toIso8601String()),
          ),
        );

      case 'boolean':
        final readonlyValue = fieldData?['readonly'] ??
            allPythonFields[fieldName]?['readonly'] ??
            false;
        final isReadonly = readonlyValue is bool
            ? readonlyValue
            : readonlyValue.toString().toLowerCase() == 'true';
        final isModuleField = fieldName.startsWith('module_');
        final isUpgradeBoolean = widgetType == 'upgrade_boolean';
        bool defaultValue = false;
        if (value == null || value == false) {
          if (configSettingsValues.containsKey(fieldName)) {
            defaultValue = valueToBool(configSettingsValues[fieldName]);
          } else if (_defaultValues != null &&
              _defaultValues!.containsKey(fieldName)) {
            defaultValue = valueToBool(_defaultValues![fieldName]);
          }
        }


        final effectiveValue = value is bool ? value : defaultValue;

        void handleBooleanChange(bool newValue) async {
          final previousValue = effectiveValue;

          setState(() {
            recordState[fieldName] = newValue;
          });

          if (isModuleField) {
            if (newValue) {
              final confirmed = await showDialog<bool>(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Feature Setup Required'),
                    content: const Text(
                      'This will install the required module. Save this page and install the module to continue.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(false);
                        },
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(true);
                        },
                        child: const Text('Save & Install'),
                      ),
                    ],
                  );
                },
              );

              if (confirmed == true) {
                final success = await _handleModuleInstallUninstall(
                    fieldName, newValue, previousValue);
                if (!success) {
                  setState(() {
                    recordState[fieldName] = previousValue;
                  });
                }
              } else {
                setState(() {
                  recordState[fieldName] = previousValue;
                });
              }
            } else {
              final confirmed = await showDialog<bool>(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Confirm Disable'),
                    content: const Text(
                      'Disabling this option will also uninstall the following modules.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(false);
                        },
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(true);
                        },
                        child: const Text('Confirm'),
                      ),
                    ],
                  );
                },
              );

              if (confirmed == true) {

                final success = await _handleModuleInstallUninstall(
                    fieldName, newValue, previousValue);
                if (!success) {
                  setState(() {
                    recordState[fieldName] = previousValue;
                  });
                }
              } else {

                setState(() {
                  recordState[fieldName] = previousValue;
                });
              }
            }
          } else if (isUpgradeBoolean) {
            if (newValue) {

              final confirmed = await showDialog<bool>(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Upgrade to Odoo Enterprise'),
                    content: const Text(
                      'Get this feature and much more with Odoo Enterprise!',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(false);
                        },
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(true);
                        },
                        child: const Text('Upgrade'),
                      ),
                    ],
                  );
                },
              );

              setState(() {
                recordState[fieldName] = previousValue;
              });

              if (confirmed == true) {
                log('Upgrade initiated for $fieldName');
              }
            } else {
              final confirmed = await showDialog<bool>(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Disable Enterprise Feature'),
                    content: const Text(
                      'Disabling this option will remove access to Odoo Enterprise features.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(false);
                        },
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(true);
                        },
                        child: const Text('Confirm'),
                      ),
                    ],
                  );
                },
              );

              if (confirmed == true) {

                await _updateFieldValue(fieldName, newValue);
              } else {

                setState(() {
                  recordState[fieldName] = previousValue;
                });
              }
            }
          } else {

            await _updateFieldValue(fieldName, newValue);
          }
        }

        if (widgetType == 'boolean_favorite') {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 150,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8.0, right: 8.0),
                    child: Text(
                      '$label:',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14.0,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: isReadonly
                        ? null
                        : () {
                            handleBooleanChange(!effectiveValue);
                          },
                    child: BooleanFavoriteWidget(isFavorite: effectiveValue),
                  ),
                ),
              ],
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: BooleanFieldWidget(
            value: effectiveValue,
            label: label,
            viewType: 'form',
            onChanged: isReadonly ? null : handleBooleanChange,
          ),
        );

      case 'char':
        if (fieldName == 'email') {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: EmailFieldWidget(
              name: label,
              value: value?.toString() ?? '',
              onChanged: (newValue) => _updateFieldValue(fieldName, newValue),
            ),
          );
        }
        if (fieldName == 'website') {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: UrlFieldWidget(
              name: label,
              value: value?.toString() ?? '',
              onChanged: (newValue) => _updateFieldValue(fieldName, newValue),
            ),
          );
        }
        if (fieldName == 'phone' || fieldName == 'mobile') {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: PhoneFieldWidget(
              name: label,
              value: value?.toString() ?? '',
              onChanged: (newValue) => _updateFieldValue(fieldName, newValue),
            ),
          );
        }
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: CharFieldWidget(
            name: label,
            value: value?.toString() != 'false' ? value.toString() : '',
            onChanged: (newValue) => _updateFieldValue(fieldName, newValue),
          ),
        );
      case 'many2one':
        final relation = allPythonFields[fieldName]?['relation'] ?? 'unknown';
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: fetchRelationOptions(relation),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }
              if (snapshot.hasError || !snapshot.hasData) {
                return const Text('Error loading options',
                    style: TextStyle(color: Colors.red));
              }
              final options = snapshot.data!;
              return Many2OneFieldWidget(
                name: label,
                value: value,
                options: options,
                onValueChanged: (newValue) =>
                    _updateFieldValue(fieldName, newValue),
              );
            },
          ),
        );
      case 'many2many':
        final relation = allPythonFields[fieldName]?['relation'] ?? 'unknown';
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 150,
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0, right: 8.0),
                  child: Text(
                    '$label:',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14.0),
                  ),
                ),
              ),
              Expanded(
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: fetchRelationOptions(relation),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }
                    if (snapshot.hasError || !snapshot.hasData) {
                      return const Text('Error loading options',
                          style: TextStyle(color: Colors.red));
                    }
                    final options = snapshot.data!;
                    return Many2ManyFieldWidget(
                      name: label,
                      values: value as List<dynamic>,
                      options: options,
                      onValuesChanged: (newValues) =>
                          _updateFieldValue(fieldName, newValues),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      case 'text':
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: TextFieldWidget(
            name: label,
            value: value?.toString() ?? '',
            onChanged: (newValue) => _updateFieldValue(fieldName, newValue),
          ),
        );
      case 'integer':
        int defaultValue = 0;
        if (value == null || value == 0) {
          if (configSettingsValues.containsKey(fieldName)) {
            defaultValue = configSettingsValues[fieldName] is int
                ? configSettingsValues[fieldName]
                : int.tryParse(configSettingsValues[fieldName].toString()) ?? 0;
          } else if (_defaultValues != null &&
              _defaultValues!.containsKey(fieldName)) {
            defaultValue = _defaultValues![fieldName] is int
                ? _defaultValues![fieldName]
                : int.tryParse(_defaultValues![fieldName].toString()) ?? 0;
          }
        }

        final effectiveValue = value is int ? value : defaultValue;
        final readonlyValue = fieldData?['readonly'] ??
            allPythonFields[fieldName]?['readonly'] ??
            false;
        final isReadonly = readonlyValue is bool
            ? readonlyValue
            : readonlyValue.toString().toLowerCase() == 'true';

        if (fieldName == 'color') {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 150,
                  child: Text(
                    '$label:',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14.0),
                  ),
                ),
                Expanded(
                  child: ColorPickerWidget(
                    initialColorValue: effectiveValue,
                    viewType: 'form',
                    onChanged: isReadonly
                        ? null
                        : (newValue) => _updateFieldValue(fieldName, newValue),
                  ),
                ),
              ],
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: IntegerFieldWidget(
            name: label,
            value: effectiveValue,
            onChanged: isReadonly
                ? null
                : (newValue) => _updateFieldValue(fieldName, newValue),
            readonly: isReadonly,
          ),
        );
      case 'float':
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: FloatFieldWidget(
            name: label,
            value: value is num ? value.toDouble() : 0.0,
          ),
        );
      case 'html':
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: HtmlFieldWidget(
            name: label,
            value: value?.toString() ?? '',
          ),
        );
      case 'one2many':
        print("relational_field  : ${relational_field}");
        return One2ManyFieldWidget(
          mainModel: widget.modelName,
          fieldName: fieldName,
          name: label,
          relationModel: fieldData?['relation_model'] as String? ?? '',
          relationField: fieldData?['relation_field'] as String? ?? '',
          mainRecordId: widget.recordId,
          tempRecordId: tempRecordId,
          client: _odooClientController.client,
          onUpdate: (values) => _updateFieldValue(fieldName, values),
          relatedFields: (fieldData?['mode_fields'] as List?)
                  ?.map((f) => {
                        'name': f['name'] as String,
                        'type': f['type'] as String? ?? 'char',
                        'domain': f['domain'] as String? ?? '[]',
                        'options': f['options'],
                        'optional': f['optional'],
                      })
                  .toList() ??
              [],
        );
      default:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 150,
                child: Text(
                  '$label',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14.0),
                ),
              ),
              Expanded(
                child: Text(
                  _formatFieldValue(value, type),
                  style: const TextStyle(fontSize: 14.0),
                ),
              ),
            ],
          ),
        );
    }
  }

  String _formatFieldValue(dynamic value, String type) {
    if (value == null) return 'N/A';
    switch (type) {
      case 'char':
        print("value : ${value.toString()}");
        return value.toString();
      case 'text':
        return value.toString();
      case 'boolean':
        return value == true ? 'Yes' : 'No';
      case 'integer':
      case 'float':
        return value.toString();
      case 'many2one':
        return value is List && value.length >= 2
            ? value[1].toString()
            : (value?.toString() ?? 'N/A');
      case 'many2many':
      case 'one2many':
        return value is List
            ? value.map((v) => v.toString()).join(', ')
            : value.toString();
      case 'selection':
      case 'datetime':
      case 'date':
        return value.toString();
      default:
        print("default : ${value.toString()}");
        return value.toString();
    }
  }
}
