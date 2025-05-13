import 'dart:developer';
import '../controller/odooclient_manager_controller.dart'; // Adjust path to your OdooClientController

/// A mixin that provides CRUD operations for Odoo from Flutter applications using OdooClientController.
/// This abstract class is designed to be mixed into your Odoo model classes or widget states.
mixin OdooCrudMixin {
  /// The Odoo client controller instance (must be provided by the implementing class)
  OdooClientController get odooClientController;

  /// The model name in Odoo (e.g., 'res.partner')
  String get modelName;

  /// Converts the model object to a map for sending to Odoo
  Map<String, dynamic> toJson();

  /// Creates a model object from Odoo response
  dynamic fromJson(Map<String, dynamic> json);

  /// Creates a new record in Odoo
  Future<int> create() async {
    try {
      final response = await odooClientController.client.callKw({
        'model': modelName,
        'method': 'create',
        'args': [toJson()],
        'kwargs': {},
      });

      if (response is int) {
        log('Record created successfully with ID: $response');
        return response;
      } else {
        throw Exception('Unexpected response type for create: $response');
      }
    } catch (e) {
      throw Exception('Failed to create record in $modelName: $e');
    }
  }

  /// Reads a specific record by ID from Odoo
  Future<dynamic> read(int id, {List<String> fields = const []}) async {
    try {
      final response = await odooClientController.client.callKw({
        'model': modelName,
        'method': 'read',
        'args': [
          [id],
          fields.isEmpty ? [] : fields,
        ],
        'kwargs': {},
      });

      if (response is List && response.isNotEmpty) {
        return fromJson(response[0]);
      } else {
        throw Exception('No record found or unexpected response: $response');
      }
    } catch (e) {
      throw Exception('Failed to read record $id from $modelName: $e');
    }
  }

  /// Searches for records based on domain filters
  Future<List<dynamic>> search(
      List<List<dynamic>> domain, {
        int limit = 0,
        int offset = 0,
        String order = '',
        List<String> fields = const [],
      }) async {
    try {
      final response = await odooClientController.client.callKw({
        'model': modelName,
        'method': 'search_read',
        'args': [domain],
        'kwargs': {
          if (limit > 0) 'limit': limit,
          if (offset > 0) 'offset': offset,
          if (order.isNotEmpty) 'order': order,
          if (fields.isNotEmpty) 'fields': fields,
        },
      });

      if (response is List) {
        return response.map((record) => fromJson(record)).toList();
      } else {
        throw Exception('Unexpected response type for search: $response');
      }
    } catch (e) {
      throw Exception('Failed to search records in $modelName: $e');
    }
  }

  /// Updates an existing record in Odoo
  Future<bool> update(int id) async {
    try {
      print("update  : ${toJson()}");
      final response = await odooClientController.client.callKw({
        'model': modelName,
        'method': 'write',
        'args': [
          [id],
          toJson(),
        ],
        'kwargs': {},
      });

      if (response is bool) {
        log('Record $id updated successfully in $modelName');
        return response;
      } else {
        throw Exception('Unexpected response type for update: $response');
      }
    } catch (e) {
      throw Exception('Failed to update record $id in $modelName: $e');
    }
  }

  /// Deletes a record from Odoo
  Future<bool> delete(int id) async {
    try {
      final response = await odooClientController.client.callKw({
        'model': modelName,
        'method': 'unlink',
        'args': [[id]],
        'kwargs': {},
      });

      if (response is bool) {
        log('Record $id deleted successfully from $modelName');
        return response;
      } else {
        throw Exception('Unexpected response type for delete: $response');
      }
    } catch (e) {
      throw Exception('Failed to delete record $id from $modelName: $e');
    }
  }

  /// Executes a custom method on the Odoo model
  Future<dynamic> executeMethod(
      String method,
      List<dynamic> args, {
        Map<String, dynamic> kwargs = const {},
      }) async {
    try {
      final response = await odooClientController.client.callKw({
        'model': modelName,
        'method': method,
        'args': args,
        'kwargs': kwargs,
      });

      log('Method $method executed successfully on $modelName');
      return response;
    } catch (e) {
      throw Exception('Failed to execute method $method on $modelName: $e');
    }
  }
}