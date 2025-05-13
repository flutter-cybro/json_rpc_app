/// Odoo JSON-RPC Client for authentication and method calls.
library;

import 'dart:async';
import 'dart:convert';
import 'dart:core';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

import '../odoo_jsonrpc.dart';
import 'cookie.dart';

enum OdooLoginEvent { loggedIn, loggedOut }

/// Odoo client for making RPC calls.
class OdooClient {
  /// Odoo server URL in format proto://domain:port
  late String baseURL;

  /// Stores current session_id that is coming from responce cookies.
  /// Odoo server will issue new session for each call as we do cross-origin requests.
  /// Session token can be retrived with SessionId getter.
  OdooSession? _sessionId;

  /// Language used by user on website.
  /// It may be different from [OdooSession.userLang]
  String frontendLang = '';

  /// Tells whether we should send session change events to a stream.
  /// Activates when there are some listeners.
  bool _sessionStreamActive = false;

  /// Send LoggedIn and LoggedOut events
  bool _loginStreamActive = false;

  /// Send in request events
  bool _inRequestStreamActive = false;

  /// Session change events stream controller
  late StreamController<OdooSession> _sessionStreamController;

  /// Login events stream controller
  late StreamController<OdooLoginEvent> _loginStreamController;

  /// Sends true while request is executed and false when it's done
  late StreamController<bool> _inRequestStreamController;

  /// HTTP client instance. By default instantiated with [http.Client].
  /// Could be overridden for tests or custom client configuration.
  late http.BaseClient httpClient;

  /// Instantiates [OdooClient] with given Odoo server URL.
  /// Optionally accepts [sessionId] to reuse existing session.
  /// It is possible to pass own [httpClient] inherited
  /// from [http.BaseClient] to override default one.
  OdooClient(String baseURL,
      [OdooSession? sessionId, http.BaseClient? httpClient]) {
    // Restore previous session
    _sessionId = sessionId;
    // Take or init HTTP client
    this.httpClient = httpClient ?? http.Client() as http.BaseClient;

    var baseUri = Uri.parse(baseURL);

    // Take only scheme://host:port
    this.baseURL = baseUri.origin;

    _sessionStreamController = StreamController<OdooSession>.broadcast(
        onListen: _startSessionSteam, onCancel: _stopSessionStream);

    _loginStreamController = StreamController<OdooLoginEvent>.broadcast(
        onListen: _startLoginSteam, onCancel: _stopLoginStream);

    _inRequestStreamController = StreamController<bool>.broadcast(
        onListen: _startInRequestSteam, onCancel: _stopInRequestStream);
  }

  void _startSessionSteam() => _sessionStreamActive = true;

  void _stopSessionStream() => _sessionStreamActive = false;

  void _startLoginSteam() => _loginStreamActive = true;

  void _stopLoginStream() => _loginStreamActive = false;

  void _startInRequestSteam() => _inRequestStreamActive = true;

  void _stopInRequestStream() => _inRequestStreamActive = false;

  /// Returns current session
  OdooSession? get sessionId => _sessionId;

  /// Returns stream of session changed events
  Stream<OdooSession> get sessionStream => _sessionStreamController.stream;

  /// Returns stream of login events
  Stream<OdooLoginEvent> get loginStream => _loginStreamController.stream;

  /// Returns stream of inRequest events
  Stream<bool> get inRequestStream => _inRequestStreamController.stream;

  Future get inRequestStreamDone => _inRequestStreamController.done;

  /// Frees HTTP client resources
  void close() {
    httpClient.close();
  }

  void _setSessionId(String newSessionId, {bool auth = false}) {
    // Update session if exists
    if (_sessionId != null && _sessionId!.id != newSessionId) {
      final currentSessionId = _sessionId!.id;

      if (currentSessionId == '' && !auth) {
        // It is not allowed to init new session outside authenticate().
        // Such may happen when we are already logged out
        // but received late RPC response that contains session in cookies.
        return;
      }

      _sessionId = _sessionId!.updateSessionId(newSessionId);

      if (currentSessionId == '' && _loginStreamActive) {
        // send logged in event
        _loginStreamController.add(OdooLoginEvent.loggedIn);
      }

      if (newSessionId == '' && _loginStreamActive) {
        // send logged out event
        _loginStreamController.add(OdooLoginEvent.loggedOut);
      }

      if (_sessionStreamActive) {
        // Send new session to listeners
        _sessionStreamController.add(_sessionId!);
      }
    }
  }

  // Take new session from cookies and update session instance
  void _updateSessionIdFromCookies(http.Response response,
      {bool auth = false}) {
    // see https://github.com/dart-lang/http/issues/362
    final lookForCommaExpression = RegExp(r'(?<=)(,)(?=[^;]+?=)');
    var cookiesStr = response.headers['set-cookie'];
    if (cookiesStr == null) {
      return;
    }

    for (final cookieStr in cookiesStr.split(lookForCommaExpression)) {
      try {
        final cookie = Cookie.fromSetCookieValue(cookieStr);
        if (cookie.name == 'session_id') {
          _setSessionId(cookie.value, auth: auth);
        }
      } catch (e) {
        throw OdooException(e.toString());
      }
    }
  }

  /// Low Level RPC call.
  /// It has to be used on all Odoo Controllers with type='json'
  Future<dynamic> callRPC(path, funcName, params) async {
    var headers = {'Content-type': 'application/json'};
    var cookie = '';
    if (_sessionId != null) {
      cookie = 'session_id=${_sessionId!.id}';
    }
    if (frontendLang.isNotEmpty) {
      if (cookie.isEmpty) {
        cookie = 'frontend_lang=$frontendLang';
      } else {
        cookie += '; frontend_lang=$frontendLang';
      }
    }
    if (cookie.isNotEmpty) {
      headers['Cookie'] = cookie;
    }

    final uri = Uri.parse(baseURL + path);
    var body = json.encode({
      'jsonrpc': '2.0',
      'method': funcName,
      'params': params,
      'id': sha1.convert(utf8.encode(DateTime.now().toString())).toString()
    });

    try {
      if (_inRequestStreamActive) _inRequestStreamController.add(true);
      final response = await httpClient.post(uri, body: body, headers: headers);

      _updateSessionIdFromCookies(response);
      var result = json.decode(response.body);
      if (result['error'] != null) {
        if (result['error']['code'] == 100) {
          // session expired
          _setSessionId('');
          final err = result['error'].toString();
          throw OdooSessionExpiredException(err);
        } else {
          // Other error
          final err = result['error'].toString();
          throw OdooException(err);
        }
      }

      if (_inRequestStreamActive) _inRequestStreamController.add(false);
      return result['result'];
    } catch (e) {
      if (_inRequestStreamActive) _inRequestStreamController.add(false);
      rethrow;
    }
  }

  /// Calls any public method on a model.
  ///
  /// Throws [OdooException] on any error on Odoo server side.
  /// Throws [OdooSessionExpiredException] when session is expired or not valid.
  Future<dynamic> callKw(params) async {
    return callRPC('/web/dataset/call_kw', 'call', params);
  }

  /// Authenticates user for given database.
  /// This call receives valid session on successful login
  /// which we be reused for future RPC calls.
  Future<OdooSession> authenticate(
      String db, String login, String password) async {
    final params = {'db': db, 'login': login, 'password': password};
    const headers = {'Content-type': 'application/json'};
    final uri = Uri.parse('$baseURL/web/session/authenticate');
    final body = json.encode({
      'jsonrpc': '2.0',
      'method': 'call',
      'params': params,
      'id': sha1.convert(utf8.encode(DateTime.now().toString())).toString()
    });
    try {
      if (_inRequestStreamActive) _inRequestStreamController.add(true);
      final response = await httpClient.post(uri, body: body, headers: headers);

      var result = json.decode(response.body);
      if (result['error'] != null) {
        if (result['error']['code'] == 100) {
          // session expired
          _setSessionId('');
          final err = result['error'].toString();
          throw OdooSessionExpiredException(err);
        } else {
          // Other error
          final err = result['error'].toString();
          throw OdooException(err);
        }
      }
      // Odoo 11 sets uid to False on failed login without any error message
      if (result['result'].containsKey('uid')) {
        if (result['result']['uid'] is bool) {
          throw OdooException('Authentication failed');
        }
      }

      _sessionId = OdooSession.fromSessionInfo(result['result']);
      // It will notify subscribers
      _updateSessionIdFromCookies(response, auth: true);

      if (_inRequestStreamActive) _inRequestStreamController.add(false);
      return _sessionId!;
    } catch (e) {
      if (_inRequestStreamActive) _inRequestStreamController.add(false);
      rethrow;
    }
  }

  /// Destroys current session.
  Future<void> destroySession() async {
    try {
      await callRPC('/web/session/destroy', 'call', {});
      // RPC call sets expired session.
      // Need to overwrite it.
      _setSessionId('');
    } on Exception {
      // If session is not cleared due to
      // unknown error - clear it locally.
      // Remote session will expire on its own.
      _setSessionId('');
    }
  }

  /// Retrieves list of databases.
  Future<List<String>> dbList() async {
    final response = await callRPC('/web/database/list', 'call', {});
    return List<String>.from(response);
  }

  /// Retrieves list of installed modules.
  Future<List<String>> module() async {
    final response = await callRPC('/web/session/modules', 'call', {});
    return List<String>.from(response);
  }

  /// Fetches the details of the current user profile.
  Future<Map<String, dynamic>> fetchUserProfile() async {
    // Ensure the session is valid before making the call
    await checkSession();

    // Get the current user ID from the session
    final userId = _sessionId?.userId;

    if (userId == null) {
      throw OdooException('User is not authenticated');
    }

    // Define the fields you want to retrieve
    final fields = [
      'id',
      'name',
      'email',
      'city',
      // 'birthday',
      'barcode',
      // 'department_id',
      'company_name',
      'avatar_1024'
    ];

    // Prepare the parameters for the `read` method call
    final params = {
      'model': 'res.users',
      'method': 'read',
      'args': [
        [userId],
        fields
      ],
      'kwargs': {},
    };

    try {
      // Call the `callKw` method with the prepared parameters
      final result = await callKw(params);

      // Check if the result is a list with user data
      if (result is List && result.isNotEmpty) {
        return result.first as Map<String, dynamic>;
      } else {
        throw OdooException('Unexpected result format or empty result');
      }
    } catch (e) {
      throw OdooException('Failed to fetch user profile: ${e.toString()}');
    }
  }


  /// Fetches all installed applications from Odoo and processes them.
  Future<List<dynamic>> fetchInstalledApplications() async {
    final params = {
      'model': 'ir.ui.menu',
      'method': 'search_read',
      'args': [
        [
          ['parent_id', '=', null], // Fetch top-level parent modules
        ],
      ],
      'kwargs': {
        'fields': ['action', 'display_name', 'name', 'id',
          'web_icon_data'
        ],
        'limit': 0,
      },
    };
    print('****************************************************************************** $params');

    try {
      final result = await callKw(params);
      if (result is List) {
        return await _processModules(result);
      } else {
        throw OdooException('Unexpected result format from Odoo');
      }
    } catch (e) {
      throw OdooException('Failed to fetch installed applications: ${e.toString()}');
    }
  }

  /// Processes modules to ensure each has a valid action, searching for child items if necessary.
  Future<List<dynamic>> _processModules(List<dynamic> modules) async {
    final processedModules = <dynamic>[];

    for (var module in modules) {
      if (_hasValidAction(module)) {
        processedModules.add(module);
      } else {
        final validChild = await _findFirstValidChildMenuItem(module['id']);
        if (validChild != null) {
          module['action'] = validChild['action'];
          processedModules.add(module);
        }
      }
    }

    return processedModules;
  }

  /// Checks if a module has a valid action.
  bool _hasValidAction(Map<String, dynamic> module) =>
      module['action'] != null && module['action'] != false;

  /// Finds the first valid child menu item for a given parent ID.
  Future<dynamic> _findFirstValidChildMenuItem(int parentId) async {
    final toCheck = <int>[parentId];

    while (toCheck.isNotEmpty) {
      final currentParentId = toCheck.removeAt(0);

      final params = {
        'model': 'ir.ui.menu',
        'method': 'search_read',
        'args': [
          [
            ['parent_id', '=', currentParentId], // Fetch child items
          ],
        ],
        'kwargs': {
          'fields': ['action', 'display_name', 'name', 'id'],
          'limit': 0,
        },
      };

      try {
        final result = await callKw(params);
        if (result is List && result.isNotEmpty) {
          for (var item in result) {
            if (_hasValidAction(item)) {
              return item;
            } else {
              toCheck.add(item['id']);
            }
          }
        }
      } catch (e) {
        throw OdooException('Failed to fetch child menu items: ${e.toString()}');
      }
    }

    return null;
  }






  /// Calls the `create` method on a model to add a new record.
  Future<dynamic> create(String model, Map<String, dynamic> fields) async {
    // Prepare the parameters for the `create` method call
    final params = {
      'model': model,
      'method': 'create',
      'args': [fields], // The fields to create the new record
      'kwargs': {}, // Additional keyword arguments (if any)
    };

    // Call the `callKw` method with the prepared parameters
    return await callKw(params);
  }

  /// Calls the `unlink` method on a model to delete a record.
  Future<dynamic> delete(String model, int id) async {
    // Prepare the parameters for the `unlink` method call
    final params = {
      'model': model,
      'method': 'unlink',
      'args': [
        [id]
      ], // The ID of the record to delete (wrapped in a list)
      'kwargs': {}, // Additional keyword arguments (if any)
    };

    // Call the `callKw` method with the prepared parameters
    return await callKw(params);
  }

  /// Calls the `read` method on a model to retrieve records.
  Future<dynamic> read(String model, List<int> ids, List<String> fields) async {
    // Prepare the parameters for the `read` method call
    final params = {
      'model': model,
      'method': 'read',
      'args': [ids, fields],
      // The IDs of the records to read and the fields to retrieve
      'kwargs': {},
      // Additional keyword arguments (if any)
    };

    // Call the `callKw` method with the prepared parameters
    return await callKw(params);
  }

  /// Calls the `search` method on a model to retrieve all record IDs.
  /// Calls the `search` method on a model to retrieve all record IDs.
  Future<List<int>> searchAll(String model) async {
    final params = {
      'model': model,
      'method': 'search',
      'args': [[], [], 0, 0], // Empty domain, no limit
      'kwargs': {},
    };

    try {
      final result = await callKw(params);

      // Ensure the result is a List<int>
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

  /// Calls the `read` method on a model to retrieve all records.
  Future<List<dynamic>> readAll(String model, List<String> fields) async {
    try {
      // Get all record IDs
      final ids = await searchAll(model);

      // Read all records using the retrieved IDs
      return await read(model, ids, fields);
    } catch (e) {
      // Handle exceptions as needed
      throw OdooException('Failed to read all records: ${e.toString()}');
    }
  }

  /// Calls a specified function on a model with a given record ID.
  Future<dynamic> callFunction(String model, String functionName, int id,
      [List<int>? args]) async {
    // Prepare the parameters for the function call
    final params = {
      'model': model,
      'method': functionName,
      'args': [id] + (args ?? []), // Pass the ID and any additional arguments
      'kwargs': {}, // Additional keyword arguments (if any)
    };

    // Call the `callKw` method with the prepared parameters
    try {
      return await callKw(params);
    } catch (e) {
      throw OdooException('Failed to call function: ${e.toString()}');
    }
  }

  /// Calls the `write` method on a model to update an existing record.
  Future<dynamic> update(
      String model, Map<String, dynamic> fields, List<int> ids) async {
    // Prepare the parameters for the `write` method call
    final params = {
      'model': model,
      'method': 'write',
      'args': [ids, fields],
      // The IDs of the records to update and the fields to update
      'kwargs': {},
      // Additional keyword arguments (if any)
    };

    // Call the `callKw` method with the prepared parameters
    return await callKw(params);
  }

  /// Checks if current session is valid.
  /// Throws [OdooSessionExpiredException] if session is not valid.
  Future<dynamic> checkSession() async {
    return callRPC('/web/session/check', 'call', {});
  }
}
