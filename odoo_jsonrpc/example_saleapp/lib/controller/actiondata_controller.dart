import 'dart:convert';
import 'dart:developer';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xml/xml.dart';

class ActionController {
  final dynamic client;

  ActionController({required this.client});

  List<String> parseActionString(String actionString) => actionString.split(',');

  List<dynamic> formatDomain(dynamic domain) {
    if (domain is String) {
      try {
        return jsonDecode(domain.replaceAll('(', '[').replaceAll(')', ']').replaceAll("'", '"'));
      } catch (e) {
        log('Error parsing domain: $e');
        return [];
      }
    }
    return domain is List ? domain : [];
  }

  Future<List<dynamic>> loadAction(String actionString) async {
    try {
      final parts = parseActionString(actionString);
      if (parts.length != 2) throw Exception('Invalid action format: $actionString');

      final actionType = parts[0];
      final actionId = int.parse(parts[1]);

      return switch (actionType) {
        'ir.actions.act_window' => await loadActWindowAction(actionString),
        'ir.actions.server' => await loadServerAction(actionString),
        _ => throw Exception('Unsupported action type: $actionType'),
      };
    } catch (e) {
      log('Error loading action: $e');
      rethrow;
    }
  }

  Future<List<dynamic>> loadServerAction(String actionString) async {
    try {
      final parts = parseActionString(actionString);
      if (parts.length != 2 || parts[0] != 'ir.actions.server') {
        throw Exception('Invalid server action format: $actionString');
      }

      final actionId = int.parse(parts[1]);
      final actionResult = await client?.callRPC('/web/action/load', 'call', {'action_id': actionId});

      if (actionResult == null || actionResult.isEmpty) {
        throw Exception('Server action not found or empty response for ID: $actionId');
      }

      final model = actionResult['model'] as String?;
      final context = actionResult['context'] as Map<String, dynamic>? ?? {};
      final executionResult = await client?.callKw({
        'model': 'ir.actions.server',
        'method': 'run',
        'args': [actionId],
        'kwargs': {'context': context},
      });

      if (executionResult is Map && executionResult['type'] == 'ir.actions.act_window') {
        return await loadActWindowAction('ir.actions.act_window,${executionResult['id'] ?? actionId}');
      }

      if (model == null) return [null, [], '', ''];

      final viewsResult = await client?.callKw({
        'model': 'ir.actions.act_window',
        'method': 'fields_view_get',
        'args': [],
        'kwargs': {'view_type': 'list', 'context': {'model_name': model}},
      });

      final fieldMetadata = _parseFieldMetadata(viewsResult['fields']);
      final dataList = executionResult is List
          ? executionResult
          : executionResult is Map && executionResult['ids'] != null
          ? await _fetchModelData(model, executionResult['ids'], fieldMetadata)
          : [];

      return [dataList, fieldMetadata, model, viewsResult['arch'] ?? ''];
    } catch (e) {
      log('Error in loadServerAction: $e');
      rethrow;
    }
  }

  Future<List<dynamic>> loadActWindowAction(String actionString) async {
    try {
      final parts = parseActionString(actionString);
      if (parts.length != 2 || parts[0] != 'ir.actions.act_window') {
        throw Exception('Invalid action format: $actionString');
      }

      final actionId = int.parse(parts[1]);
      final actionResult = await client?.callRPC('/web/action/load', 'call', {'action_id': actionId});


      log("actionResult  : $actionResult");

      if (actionResult == null || actionResult.isEmpty) {
        throw Exception('Action not found or empty response for ID: $actionId');
      }

      final resModel = actionResult['res_model'] as String?;
      final views = actionResult['views'] as List<dynamic>?;
      final domain = formatDomain(actionResult['domain']);
      String mainFormData = '';

      if (resModel != null) {
        final viewResult = await client?.callKw({
          'model': resModel,
          'method': 'get_views',
          'args': [],
          'kwargs': {'views': views},
        });
        mainFormData = viewResult['views']['form']?['arch'] as String? ?? '';
      }

      if (actionResult['view_mode'] == 'form' || (views?.every((v) => v[1] == 'form') ?? false)) {
        return [null, [], resModel ?? '', mainFormData];
      }

      final viewsResult = await client?.callKw({
        'model': 'ir.actions.act_window',
        'method': 'fields_view_get',
        'args': [],
        'kwargs': {'view_type': 'list', 'context': {'model_name': resModel}},
      });

      log("viewsResult : $viewsResult");

      final fieldMetadata = _parseFieldMetadata(viewsResult['fields']);

      log("fieldMetadata : $fieldMetadata");
      final modelResult = await client?.callKw({
        'model': resModel,
        'method': 'search_read',
        'args': [domain],
        'kwargs': {
          'fields': fieldMetadata.map((e) => e['name'] as String).toList(),
          'limit': 50,
          'context': {'search_default_my_quotation': 1},
        },
      });

      return [modelResult ?? [], fieldMetadata, resModel ?? '', mainFormData];
    } catch (e) {
      log('Error in loadActWindowAction: $e');
      rethrow;
    }
  }

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

  Future<List<dynamic>> _fetchModelData(String model, List<dynamic> ids, List<Map<String, dynamic>> fieldMetadata) async {
    return await client?.callKw({
      'model': model,
      'method': 'search_read',
      'args': [[['id', 'in', ids]]],
      'kwargs': {'fields': fieldMetadata.map((e) => e['name'] as String).toList()},
    }) ?? [];
  }

  Future<void> enrichFieldStrings(Map<String, dynamic> fields, String resModel) async {
    try {
      final fieldsInfo = await client?.callKw({
        'model': resModel,
        'method': 'fields_view_get',
        'args': [],
        'kwargs': {'attributes': ['string', 'type', 'selection']},
      });
      if (fieldsInfo is Map) {
        fields.forEach((fieldName, attributes) {
          final fieldInfo = fieldsInfo[fieldName];
          if (fieldInfo != null) {
            attributes['string'] = fieldInfo['string'] ?? attributes['string'];
            attributes['type'] = fieldInfo['type'] ?? attributes['type'];
            if (fieldInfo['type'] == 'selection') attributes['selection'] = fieldInfo['selection'] ?? [];
          }
        });
      }
    } catch (e) {
      log('Error enriching field strings: $e');
    }
  }
}