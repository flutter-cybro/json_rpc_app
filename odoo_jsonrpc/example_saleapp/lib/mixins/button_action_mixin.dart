import 'dart:developer';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:xml/xml.dart';
import '../controller/odooclient_manager_controller.dart';
import '../pages/form_view.dart';
import '../pages/tree_view.dart';
import 'action_mixier.dart';

/// Abstract mixin to handle Odoo button actions (e.g., object, action, act_window).
mixin ButtonActionMixin<T extends StatefulWidget> on State<T>, ActWindowActionMixin<T> {
  // Abstract getter for OdooClientController (must be implemented by the widget)
  OdooClientController get odooClient;

  // Optional: Getter for the current record ID (if applicable, e.g., in FormView)
  int? get recordId;

  // Optional: Getter for the model name (e.g., 'sale.order', 'res.partner')
  String get modelName;

  /// Handles a button action based on its type and attributes.
  /// - [buttonData]: Map containing button attributes (e.g., name, type, context).
  /// - [buildContext]: Required Flutter BuildContext for navigation and dialogs.
  /// Returns a Future<bool> to indicate success or failure.
  Future<bool> handleButtonAction({
    required Map<String, dynamic> buttonData,
    required BuildContext buildContext,
  }) async {
    try {
      final actionType = buttonData['type']?.toString();
      final actionName = buttonData['name']?.toString();

      if (actionName == null || actionType == null) {
        throw Exception('Button action missing name or type');
      }

      // Merge button context with default values
      final actionContext = <String, dynamic>{
        if (buttonData['context'] is Map) ...Map<String, dynamic>.from(buttonData['context'] as Map),
        if (recordId != null) 'active_id': recordId,
        if (recordId != null) 'active_ids': [recordId],
      };

      switch (actionType) {
        case 'object':
          return await _handleObjectAction(actionName, actionContext, buildContext);
        case 'action':
          return await _handleAction(actionName, actionContext, buildContext);
        case 'act_window':
          return await _handleWindowAction(buttonData, actionContext, buildContext);
        default:
          throw Exception('Unsupported action type: $actionType');
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog(buildContext, 'Action Error', e.toString());
      }
      return false;
    }
  }

  /// Handles 'object' type actions (calls a method on the model).
  Future<bool> _handleObjectAction(
      String methodName,
      Map<String, dynamic> context,
      BuildContext buildContext,
      ) async {
    if (modelName.isEmpty) {
      throw Exception('Model name is required for object actions');
    }

    log("methodName: $methodName,\ncontext: $context\nbuildContext: $modelName");

    final response = await odooClient.client.callKw({
      'model': modelName,
      'method': methodName,
      'args': [if (recordId != null) [recordId] else []],
      'kwargs': {'context': context},
    });

    log("response: $response");

    if (response is Map<String, dynamic> && response.containsKey('type')) {
      if (response['type'] == 'ir.actions.act_window') {
        return await _handleWindowAction(response, context, buildContext);
      } else if (response['type'] == 'ir.actions.act_url') {
        return await _handleUrlAction(response, buildContext);
      }
    }

    if (mounted) {
      _showActionResult(buildContext, response?.toString() ?? 'Action completed');
    }
    return true;
  }

  /// Handles 'ir.actions.act_url' type actions (launches URL or downloads file).
  Future<bool> _handleUrlAction(
      Map<String, dynamic> action,
      BuildContext buildContext,
      ) async {
    try {
      // Retrieve server address from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final serverUrl = prefs.getString('url') ?? '';

      log("serverUrl: $serverUrl");
      if (serverUrl.isEmpty) {
        if (mounted) {
          _showActionResult(buildContext, 'Error: Server URL not configured.');
        }
        return false;
      }

      // Ensure serverUrl ends with a slash and remove trailing slash from url
      final normalizedServerUrl = serverUrl.endsWith('/') ? serverUrl : '$serverUrl/';
      // Extract URL and target from the action
      final String? relativeUrl = action['url']?.toString();
      final String? target = action['target']?.toString();

      if (relativeUrl == null || relativeUrl.isEmpty) {
        if (mounted) {
          _showActionResult(buildContext, 'Error: No URL provided in act_url action.');
        }
        return false;
      }

      // Construct full URL by prepending server address
      final fullUrl = relativeUrl.startsWith('/')
          ? '$normalizedServerUrl${relativeUrl.substring(1)}'
          : '$normalizedServerUrl$relativeUrl';

      // Handle based on target
      if (target == 'new' || target == 'self') {
        // Launch URL in browser
        final Uri uri = Uri.parse(fullUrl);
        if (await canLaunchUrl(uri)) {
          await launchUrl(
            uri,
            mode: LaunchMode.externalApplication, // Opens in Chrome/default browser
          );
          return true;
        } else {
          if (mounted) {
            _showActionResult(buildContext, 'Error: Could not launch URL: $fullUrl');
          }
          return false;
        }
      } else if (target == 'download') {
        // Download file to phone
        return await _downloadFile(fullUrl, buildContext);
      } else {
        if (mounted) {
          _showActionResult(
            buildContext,
            'Error: Unknown target "$target" in act_url action.',
          );
        }
        return false;
      }
    } catch (e) {
      if (mounted) {
        _showActionResult(buildContext, 'Error handling URL action: $e');
      }
      return false;
    }
  }

  /// Download file to phone
  Future<bool> _downloadFile(String url, BuildContext buildContext) async {
    try {
      // Request storage permission (required for Android < 13, optional for others)
      if (Platform.isAndroid) {
        var status = await Permission.storage.request();
        if (!status.isGranted) {
          if (mounted) {
            _showActionResult(buildContext, 'Error: Storage permission denied.');
          }
          return false;
        }
      }

      // Get the downloads directory
      final directory = await getDownloadsDirectory();
      if (directory == null) {
        if (mounted) {
          _showActionResult(buildContext, 'Error: Could not access downloads directory.');
        }
        return false;
      }

      // Generate a file name from the URL or use a default
      final fileName = url.split('/').last.isNotEmpty
          ? url.split('/').last
          : 'downloaded_file_${DateTime.now().millisecondsSinceEpoch}';
      final filePath = '${directory.path}/$fileName';

      // Download the file using Dio
      final dio = Dio();
      await dio.download(url, filePath, onReceiveProgress: (received, total) {
        if (total != -1) {
          // Optional: Show download progress
          log('Download progress: ${(received / total * 100).toStringAsFixed(0)}%');
        }
      });

      if (mounted) {
        _showActionResult(buildContext, 'File downloaded successfully to: $filePath');
      }
      return true;
    } catch (e) {
      if (mounted) {
        _showActionResult(buildContext, 'Error downloading file: $e');
      }
      return false;
    }
  }

  /// Handles 'action' type actions (loads action via /web/action/load).
  Future<bool> _handleAction(
      String actionId,
      Map<String, dynamic> context,
      BuildContext buildContext,
      ) async {
    final action = await odooClient.client.callRPC(
      '/web/action/load',
      'call',
      {'action_id': int.tryParse(actionId) ?? actionId, 'context': context},
    );

    log("action  : $action");
    if (action == null) {
      throw Exception('Failed to load action: $actionId');
    }

    if (action['type'] == 'ir.actions.act_window') {
      return await _handleWindowAction(action, context, buildContext);
    } else if (action['type'] == 'ir.actions.client') {
      // Handle client action (e.g., reload view or custom JS action)
      if (mounted) {
        _showActionResult(buildContext, 'Client action executed: ${action['tag']}');
      }
      return true;
    } else {
      throw Exception('Unsupported action type: ${action['type']}');
    }
  }

  /// Handles 'act_window' type actions (navigates to a view or shows a dialog).
  Future<bool> _handleWindowAction(
      Map<String, dynamic> action,
      Map<String, dynamic> context,
      BuildContext buildContext,
      ) async {
    log("Entered _handleWindowAction $action");

    try {
      // Call processWindowActionResponse from ActWindowActionMixin
      final isHandled = await processWindowActionResponse(
        actionResponse: action,
        context: context,
        menuName: action['name']?.toString() ?? 'Window Action',
        buildContext: buildContext,
      );

      if (!isHandled && targetWidget != null && mounted) {
        Navigator.push(
          buildContext,
          MaterialPageRoute(builder: (_) => targetWidget!),
        );
      }

      return true;
    } catch (e) {
      if (mounted) {
        _showErrorDialog(buildContext, 'Window Action Error', e.toString());
      }
      return false;
    }
  }

  /// Fetches field metadata for a model and view type.
  Future<List<Map<String, dynamic>>> _getFieldMetadata(String model, String viewType) async {
    try {
      final response = await odooClient.client.callKw({
        'model': model,
        'method': 'fields_view_get',
        'args': [],
        'kwargs': {'view_type': viewType},
      });

      if (response is Map<String, dynamic> && response['fields'] is Map) {
        return response['fields'].entries.map((entry) {
          return {
            'name': entry.key,
            'type': entry.value['type'] ?? 'char',
            'string': entry.value['string'] ?? entry.key,
            'pythonAttributes': entry.value,
            'xmlAttributes': [],
          };
        }).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Shows an error dialog.
  void _showErrorDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Shows an action result in a dialog.
  void _showActionResult(BuildContext buildContext, String message) {
    showDialog(
      context: buildContext,
      builder: (context) => AlertDialog(
        title: const Text('Action Result'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}