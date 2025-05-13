import 'package:odoo_jsonrpc/odoo_jsonrpc.dart';
import 'package:shared_preferences/shared_preferences.dart';
class OdooClientController {
  static final OdooClientController _instance = OdooClientController._internal();
  OdooClient? _client;
  int? _userId;

  factory OdooClientController() {
    return _instance;
  }

  OdooClientController._internal();

  int? get userId => _userId;

  OdooClient get client {
    if (_client == null) {
      throw Exception('OdooClient not initialized. Call initialize() first.');
    }
    return _client!;
  }

  bool get isInitialized => _client != null;

  Future<void> initializeWithUrl(String url) async {
    _client = OdooClient(url);
  }


  Future<void> initialize() async {
    if (_client != null) return;

    final prefs = await SharedPreferences.getInstance();
    final url = prefs.getString('url');
    final db = prefs.getString('selectedDatabase');
    final sessionId = prefs.getString('sessionId');
    final serverVersion = prefs.getString('serverVersion');
    final userLang = prefs.getString('userLang');

    if (url == null || db == null || sessionId == null) {
      throw Exception('Required session data not found in SharedPreferences');
    }

    final session = OdooSession(
      id: sessionId,
      userId: prefs.getInt('userId') ?? 0,
      partnerId: prefs.getInt('partnerId') ?? 0,
      userLogin: prefs.getString('userLogin') ?? '',
      userName: prefs.getString('userName') ?? '',
      userLang: userLang ?? '',
      userTz: '',
      isSystem: prefs.getBool('isSystem') ?? false,
      dbName: db,
      serverVersion: serverVersion ?? '',
    );

    _client = OdooClient(url, session);
    _userId = session.userId;
  }

  Future<void> reset() async {
    _client = null;
    _userId = null;
  }

  Future<List<dynamic>> fetchInstalledApplications() async {
    return await client.fetchInstalledApplications();
  }

  Future<List<String>> fetchDatabaseList() async {
    if (_client == null) {
      throw Exception("OdooClient is not initialized. Call initializeClient first.");
    }
    return await _client!.dbList();
  }

  Future<OdooSession> authenticate(String db, String username, String password) async {
    if (_client == null) {
      throw Exception("OdooClient is not initialized. Call initializeClient first.");
    }
    final session = await _client!.authenticate(db, username, password);
    _userId = session.userId;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('userId', session.userId);
    await prefs.setString('sessionId', session.id);
    await prefs.setString('userLogin', session.userLogin);
    await prefs.setString('userName', session.userName);
    await prefs.setString('selectedDatabase', db);
    return session;
  }


}