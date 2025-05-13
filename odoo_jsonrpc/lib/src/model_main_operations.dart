import 'odoo_client.dart';
import 'odoo_exceptions.dart';

class ModelMainOperations {
  final OdooClient _client;

  ModelMainOperations(this._client);

  Future<dynamic> create(String model, Map<String, dynamic> fields) async {
    final params = {
      'model': model,
      'method': 'create',
      'args': [fields],
      'kwargs': {},
    };
    return await _client.callKw(params);
  }

  Future<dynamic> delete(String model, int id) async {
    final params = {
      'model': model,
      'method': 'unlink',
      'args': [[id]],
      'kwargs': {},
    };
    return await _client.callKw(params);
  }

  Future<dynamic> read(String model, List<int> ids, List<String> fields) async {
    final params = {
      'model': model,
      'method': 'read',
      'args': [ids, fields],
      'kwargs': {},
    };
    return await _client.callKw(params);
  }

  Future<List<int>> searchAll(String model) async {
    final params = {
      'model': model,
      'method': 'search',
      'args': [[], [], 0, 0],
      'kwargs': {},
    };

    try {
      final result = await _client.callKw(params);
      if (result is List) {
        return result.map((e) => e as int).toList();
      } else {
        throw OdooException(
            'Unexpected result format from search: ${result.runtimeType}');
      }
    } catch (e) {
      throw OdooException('Failed to search all records: ${e.toString()}');
    }
  }

  Future<List<dynamic>> readAll(String model, List<String> fields) async {
    try {
      final ids = await searchAll(model);
      return await read(model, ids, fields);
    } catch (e) {
      throw OdooException('Failed to read all records: ${e.toString()}');
    }
  }

  Future<dynamic> callFunction(String model, String functionName, int id,
      [List<int>? args]) async {
    final params = {
      'model': model,
      'method': functionName,
      'args': [id] + (args ?? []),
      'kwargs': {},
    };

    try {
      return await _client.callKw(params);
    } catch (e) {
      throw OdooException('Failed to call function: ${e.toString()}');
    }
  }
}