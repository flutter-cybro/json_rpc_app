import 'dart:convert'; // For jsonDecode
import 'dart:developer';
import 'package:flutter/material.dart';
import '../controller/odooclient_manager_controller.dart'; // Adjust path as needed
import '../pages/form_view.dart'; // Adjust path as needed
import '../pages/tree_view.dart'; // Adjust path as needed

/// Mixin for loading Odoo window actions via /web/action/load and handling the action.
mixin ActWindowActionMixin<T extends StatefulWidget> on State<T> {
  // Required: Odoo client controller
  OdooClientController get odooClientController;

  /// Loads a window action using /web/action/load and processes it based on target.
  /// [actionId]: The ID of the action to load.
  /// [buildContext]: The BuildContext to use for showing dialogs or navigation.
  /// [context]: Optional context map to pass to the action.
  /// [menuName]: Name of the menu item for the widget title (default: 'Unknown Action').
  /// Returns a Future<bool> indicating whether the action was handled (true for dialogs, false for navigation).
  Future<bool> callWindowAction({
    required String actionId,
    required BuildContext buildContext,
    Map<String, dynamic>? context,
    String menuName = 'Unknown Action',
    String modulename = 'Unknown module',
  }) async {
    try {
      final actionResponse = await odooClientController.client.callRPC(
        '/web/action/load',
        'call',
        {'action_id': int.parse(actionId), 'context': context ?? {}},
      );

      log("actionResponse: $actionResponse");

      if (actionResponse == null || actionResponse.isEmpty) {
        throw Exception('Action not found or empty response for ID: $actionId');
      }

      // Update menuName with the action's name, if available
      final actionName = actionResponse['name'] as String? ?? menuName;

      // Process the action response
      return await processWindowActionResponse(
        actionResponse: actionResponse,
        context: context ?? {},
        menuName: actionName,
        modulename: modulename,
        buildContext: buildContext,
      );
    } catch (e) {
      final errorMessage = 'Error loading window action "$actionId": $e';
      debugPrint(errorMessage);
      ScaffoldMessenger.of(buildContext).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
      return true; // Handled as an error dialog
    }
  }

  /// Processes the action response from /web/action/load and returns a widget or shows a dialog.
  /// [actionResponse]: The response from the /web/action/load call.
  /// [context]: The context map to pass to view fetching.
  /// [menuName]: The name of the menu item for the widget title.
  /// [buildContext]: The BuildContext to use for showing dialogs or navigation.
  /// Returns a Future<bool> indicating whether the action was handled (true for dialogs, false for navigation).
  Future<bool> processWindowActionResponse({
    required Map<String, dynamic> actionResponse,
    required Map<String, dynamic> context,
    required String menuName,
    String modulename = "",
    required BuildContext buildContext,
  }) async {
    try {
      final resModel = (actionResponse['res_model'] as String? ?? actionResponse['model_name'] as String? ?? '');
      final viewMode = actionResponse['view_mode'] as String? ?? '';
      final views = actionResponse['views'] as List<dynamic>? ?? [];
      final bindingViewTypes = actionResponse['binding_view_types'] as String? ?? '';
      final target = actionResponse['target'] as String? ?? 'current';

      log("resModel: $resModel, viewMode: $viewMode, views: $views, bindingViewTypes: $bindingViewTypes, target: $target");

      // Determine viewType, prioritizing view_mode, then views, then binding_view_types
      String viewType = 'list';
      if (viewMode.isNotEmpty) {
        viewType = viewMode.split(',').firstWhere(
              (type) => ['form', 'list', 'kanban', 'calendar'].contains(type),
          orElse: () => 'list',
        );
      } else if (views.isNotEmpty) {
        for (var view in views) {
          if (view is List && view.length >= 2 && view[1] is String) {
            if (['form', 'list'].contains(view[1])) {
              viewType = view[1] as String;
              break;
            }
          }
        }
      } else if (bindingViewTypes.isNotEmpty) {
        // Parse binding_view_types (e.g., 'list,form')
        final viewTypes = bindingViewTypes.split(',').map((e) => e.trim()).toList();
        viewType = viewTypes.firstWhere(
              (type) => ['form', 'list', 'kanban', 'calendar'].contains(type),
          orElse: () => 'list',
        );
      }

      log("Determined viewType: $viewType");

      String formData = '';
      List<Map<String, dynamic>> fieldMetadata = [];

      if (resModel.isEmpty) {
        throw Exception('No res_model or model_name found in action response');
      }

      if (!['current', 'new', 'fullscreen', 'inline', 'main'].contains(target)) {
        debugPrint('Warning: Invalid target value: $target. Defaulting to "current".');
      }

      // Fetch form view data
      try {
        final viewResult = await odooClientController.client.callKw({
          'model': resModel,
          'method': 'get_views',
          'args': [],
          'kwargs': {'views': views.isNotEmpty ? views : [[false, viewType]], 'context': context},
        });
        formData = viewResult['views']['form']?['arch'] as String? ?? '';
      } catch (e) {
        debugPrint('Error fetching form views for $resModel: $e');
        formData = '';
      }

      // Create the widget based on viewType
      Widget targetWidget;
      if (viewType == 'form' || (views.isNotEmpty && views.every((v) => v[1] == 'form'))) {
        int recordId = actionResponse['res_id'] is int ? actionResponse['res_id'] as int : 0;
        Map<String, dynamic>? defaultValues;

        if (recordId == 0) {
          try {
            defaultValues = await odooClientController.client.callKw({
              'model': 'ir.actions.act_window',
              'method': 'get_field_values',
              'args': [[]],
              'kwargs': {
                'modelname': resModel,
                'id': context['active_id'] ?? 0,
              },
            });
            log("Default values: $defaultValues");
          } catch (e) {
            debugPrint('Error fetching default values with get_field_values: $e');
          }
        }

        int? parentId = context['active_id'] as int?;

        targetWidget = FormView(
          modelName: resModel,
          recordId: recordId,
          formData: formData,
          name: menuName,
          moduleName: modulename,
          defaultValues: defaultValues,
          wizard: true,
          parentId: parentId,
        );
      } else {
        try {
          final viewsResult = await odooClientController.client.callKw({
            'model': 'ir.actions.act_window',
            'method': 'fields_view_get',
            'args': [],
            'kwargs': {'view_type': viewType, 'context': {'model_name': resModel}},
          });

          log("viewsResult ($viewType): $viewsResult");
          fieldMetadata = _parseFieldMetadata(viewsResult['fields']);
        } catch (e) {
          debugPrint('Error fetching $viewType view for $resModel with fields_view_get: $e');
          fieldMetadata = [];
        }

        final dataList = await odooClientController.client.callKw({
          'model': resModel,
          'method': 'search_read',
          'args': [_formatDomain(actionResponse['domain'])],
          'kwargs': {
            'fields': fieldMetadata.map((e) => e['name'] as String).toList(),
            'limit': 50,
            'context': {'search_default_my_quotation': 1},
          },
        });

        log("dataList  : $dataList  , resModel : $resModel  , _formatDomain(actionResponse['domain'])  : ${_formatDomain(actionResponse['domain'])}");

        targetWidget = TreeViewScreen(
          title: menuName,
          dataList: dataList ?? [],
          fieldMetadata: fieldMetadata,
          modelname: resModel,
          formdata: formData,
          moduleName: modulename,
        );
      }

      // Handle target
      if (target == 'new') {
        await showDialog(
          context: buildContext,
          builder: (dialogContext) => Dialog(
            child: SizedBox(
              width: MediaQuery.of(buildContext).size.width * 0.8,
              height: MediaQuery.of(buildContext).size.height * 0.6,
              child: Scaffold(
                body: targetWidget,
              ),
            ),
          ),
        );
        return true; // Indicate the action was handled as a dialog
      } else {
        _targetWidget = targetWidget;
        return false; // Indicate navigation is required
      }
    } catch (e) {
      final errorMessage = 'Error processing window action response: $e';
      debugPrint(errorMessage);
      ScaffoldMessenger.of(buildContext).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
      return true; // Handled as an error dialog
    }
  }
  /// Parses field metadata from fields_view_get response.
  List<Map<String, dynamic>> _parseFieldMetadata(dynamic fields) {
    if (fields is! List) return [];
    return fields.map((field) => {
      'name': field['name'] as String?,
      'value': 'No Value',
      'type': field['python_attributes']['type'] ?? 'char',
      'string': field['xml_attributes']['string'] ?? field['name'],
      'widget': field['xml_attributes']['widget'],
      'xmlAttributes': (field['xml_attributes'] as Map?)
          ?.entries
          .map((e) => {'name': e.key, 'value': e.value})
          .toList() ??
          [],
      'pythonAttributes': field['python_attributes'] ?? {},
    }).toList();
  }

  /// Formats Odoo domain strings into a list.
  List<dynamic> _formatDomain(dynamic domain) {
    if (domain is String) {
      try {
        return jsonDecode(domain.replaceAll('(', '[').replaceAll(')', ']').replaceAll("'", '"'));
      } catch (e) {
        debugPrint('Error parsing domain: $e');
        return [];
      }
    }
    return domain is List ? domain : [];
  }

  // Store the target widget for navigation
  Widget? _targetWidget;

  /// Getter for the target widget to be used in navigation
  Widget? get targetWidget => _targetWidget;
}