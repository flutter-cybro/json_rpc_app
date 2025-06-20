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


  Future<bool> processWindowActionResponse({
    required Map<String, dynamic> actionResponse,
    required Map<String, dynamic> context,
    required String menuName,
    String modulename = "",
    required BuildContext buildContext,
  }) async {
    try {
      final actionType = actionResponse['type'] as String? ?? '';
      final resModel = (actionResponse['res_model'] is String ? actionResponse['res_model'] as String? : actionResponse['model_name'] is String ? actionResponse['model_name'] as String? : '');
      final viewMode = actionResponse['view_mode'] as String? ?? '';
      final views = actionResponse['views'] as List<dynamic>? ?? [];
      final bindingViewTypes = actionResponse['binding_view_types'] as String? ?? '';
      final target = actionResponse['target'] as String? ?? 'current';

      log("resModel: $resModel, viewMode: $viewMode, views: $views, bindingViewTypes: $bindingViewTypes, target: $target, actionType: $actionType");

      // Helper function to show SnackBar with right-to-left animation at the top
      void showTopSnackBar(String message) {
        final overlay = Overlay.of(buildContext);
        late OverlayEntry overlayEntry;

        final controller = AnimationController(
          vsync: Navigator.of(buildContext),
          duration: const Duration(milliseconds: 500),
        );
        final animation = Tween<Offset>(
          begin: const Offset(1.0, 0.0), // Start from right
          end: Offset.zero, // End at original position
        ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));

        overlayEntry = OverlayEntry(
          builder: (context) => AnimatedBuilder(
            animation: animation,
            builder: (context, child) {
              return Positioned(
                top: 10.0,
                left: 10.0,
                right: 10.0,
                child: SlideTransition(
                  position: animation,
                  child: Material(
                    elevation: 4.0,
                    borderRadius: BorderRadius.circular(8.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Text(
                        message,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );

        // Insert the overlay entry
        overlay.insert(overlayEntry);
        controller.forward();

        // Remove the overlay after 3 seconds
        Future.delayed(const Duration(seconds: 3), () {
          controller.reverse().then((_) {
            overlayEntry.remove();
            controller.dispose();
          });
        });
      }
      // Handle client actions (e.g., ir.actions.client) separately
      if (actionType == 'ir.actions.client') {
        final errorMessage = 'This action ("$menuName") is a client action and cannot be processed as a window action.';
        debugPrint(errorMessage);
        showTopSnackBar(errorMessage);
        return true; // Handled as an error dialog
      }

      // Check if resModel is valid
      if (resModel == null || resModel.isEmpty) {
        final errorMessage = 'Invalid or missing model for action "$menuName". Please contact support.';
        debugPrint(errorMessage);
        showTopSnackBar(errorMessage);
        return true; // Handled as an error dialog
      }

      // Determine viewType, prioritizing view_mode, then views, then binding_view_types
      String? viewType;
      if (viewMode.isNotEmpty) {
        final viewModes = viewMode.split(',').map((e) => e.trim()).toList();
        viewType = viewModes.contains('list') ? 'list' : viewModes.contains('form') ? 'form' : null;
      }
      else if (views.isNotEmpty) {
        for (var view in views) {
          if (view is List && view.length >= 2 && view[1] is String) {
            if (view[1] == 'list') {
              viewType = 'list';
              break;
            } else if (view[1] == 'form') {
              viewType ??= 'form'; // Set form only if list is not found
            }
          }
        }
      }
      else if (bindingViewTypes.isNotEmpty) {
        final viewTypes = bindingViewTypes.split(',').map((e) => e.trim()).toList();
        viewType = viewTypes.contains('list') ? 'list' : viewTypes.contains('form') ? 'form' : null;
      }

      // If no valid viewType is found, show a popup
      if (viewType == null) {
        final errorMessage = 'No list or form view found for action "$menuName".';
        debugPrint(errorMessage);
        showTopSnackBar(errorMessage);
        return true; // Handled as an error dialog
      }

      String formData = '';
      List<Map<String, dynamic>> fieldMetadata = [];

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

        log("dataList: $dataList, resModel: $resModel, domain: ${_formatDomain(actionResponse['domain'])}");

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
      final errorMessage = 'Unable to process action "$menuName". Please try again or contact support.';
      debugPrint('Error processing window action: $e');
      log('Error processing window action: $e');
      // Use the custom SnackBar function
      final scaffoldMessenger = ScaffoldMessenger.of(buildContext);
      scaffoldMessenger.clearSnackBars();
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(
            errorMessage,
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(
            top: 10.0, // Position at the top
            left: 10.0,
            right: 10.0,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          animation: CurvedAnimation(
            parent: const AlwaysStoppedAnimation(1.0),
            curve: Curves.easeInOut,
          ),
        ),
      );

      // Custom animation for right-to-left slide
      final controller = AnimationController(
        vsync: Navigator.of(buildContext),
        duration: const Duration(milliseconds: 500),
      );
      final animation = Tween<Offset>(
        begin: const Offset(1.0, 0.0), // Start from right
        end: Offset.zero, // End at original position
      ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));

      controller.forward();
      Future.delayed(const Duration(seconds: 3), () {
        controller.dispose();
      });

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