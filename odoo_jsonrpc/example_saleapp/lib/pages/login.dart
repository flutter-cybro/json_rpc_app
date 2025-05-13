import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:odoo_jsonrpc/odoo_jsonrpc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../controller/odooclient_manager_controller.dart';
import '../res/constants/app_colors.dart';
import '../res/constants/const.dart';
import '../screen_handler/screen_handler.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _urlController =
  TextEditingController(text: DEFAULT_SERVER_ADDRESS);
  final TextEditingController _usernameController =
  TextEditingController(text: DEFAULT_USERNAME);
  final TextEditingController _passwordController =
  TextEditingController(text: DEFAULT_PASSWORD);
  final _storage = FlutterSecureStorage();

  bool _isLoading = false;
  List<DropdownMenuItem<String>> _dropdownItems = [];
  String? _selectedDatabase;
  String? _errorMessage;
  bool _rememberMe = false;
  final OdooClientController _clientController = OdooClientController();

  @override
  void initState() {
    super.initState();
    _urlController.addListener(_onUrlChange);
    _loadSavedCredentials();
  }

  void _onUrlChange() {
    setState(() {
      _dropdownItems.clear();
      _selectedDatabase = null;
      _errorMessage = null;
    });

    if (_urlController.text.trim().isNotEmpty) {
      _fetchDatabaseList();
    }
  }

  Future<void> _fetchDatabaseList() async {
    setState(() => _isLoading = true);

    try {
      await _clientController.reset();
      await _clientController.initializeWithUrl(_urlController.text.trim());

      final dbList = await _clientController.fetchDatabaseList();

      setState(() {
        _dropdownItems = dbList
            .map((db) => DropdownMenuItem(value: db, child: Text(db)))
            .toList();
        _selectedDatabase ??= dbList.isNotEmpty ? dbList.first : null;
        _errorMessage = null;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to fetch databases. Check your URL.';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _rememberMe = prefs.getBool('rememberMe') ?? false;
      if (_rememberMe) {
        _urlController.text = prefs.getString('savedUrl') ?? DEFAULT_SERVER_ADDRESS;
        _usernameController.text = prefs.getString('savedUsername') ?? DEFAULT_USERNAME;
        _passwordController.text = '';
        _selectedDatabase = prefs.getString('savedDatabase');
        if (_urlController.text.trim().isNotEmpty) {
          _fetchDatabaseList();
        }
      }
    });

    // Load password asynchronously after initial setState
    if (_rememberMe) {
      final savedPassword = await _storage.read(key: 'savedPassword');
      setState(() {
        _passwordController.text = savedPassword ?? DEFAULT_PASSWORD;
      });
    }
  }

  Future<void> _saveCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    if (_rememberMe) {
      await prefs.setString('savedUrl', _urlController.text.trim());
      await prefs.setString('savedUsername', _usernameController.text.trim());
      await _storage.write(key: 'savedPassword', value: _passwordController.text.trim());
      await prefs.setString('savedDatabase', _selectedDatabase ?? '');
      await prefs.setBool('rememberMe', true);
    } else {
      await prefs.remove('savedUrl');
      await prefs.remove('savedUsername');
      await _storage.delete(key: 'savedPassword');
      await prefs.remove('savedDatabase');
      await prefs.remove('rememberMe');
    }
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDatabase == null) {
      setState(() => _errorMessage = 'Database not selected');
      return;
    }

    if (_usernameController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Username or Password cannot be empty');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final session = await _clientController.authenticate(
        _selectedDatabase!,
        _usernameController.text.trim(),
        _passwordController.text.trim(),
      );

      await _saveSession(session);
      await _savePreferences();
      await _saveCredentials();
      await _promptLocalAuth();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ScreenHandler()),
      );
    } on OdooException {
      setState(() => _errorMessage = 'Authentication failed. Try again.');
    } catch (e) {
      setState(() => _errorMessage = 'Unexpected error occurred: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('selectedDatabase', _selectedDatabase!);
    await prefs.setString('url', _urlController.text.trim());
  }

  Future<void> _saveSession(OdooSession session) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', session.userName);
    await prefs.setString('userLogin', session.userLogin.toString());
    await prefs.setInt('userId', session.userId);
    await prefs.setString('sessionId', session.id);
    await prefs.setString('pass', _passwordController.text.trim());
    await prefs.setString('serverVersion', session.serverVersion);
    await prefs.setString('userLang', session.userLang);
    await prefs.setInt('partnerId', session.partnerId);
    await prefs.setBool('isSystem', session.isSystem);
  }

  Future<void> _promptLocalAuth() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('hasAskedLocalAuth') ?? false) return;

    final useLocalAuth = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text('Use Local Authentication?'),
        content: const Text(
          'Do you want to use biometric authentication for future logins?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );

    if (useLocalAuth != null) {
      await prefs.setBool('useLocalAuth', useLocalAuth);
      await prefs.setBool('hasAskedLocalAuth', true);
    }
  }

  Widget _buildFormField(
      TextEditingController controller,
      String label,
      IconData icon, {
        bool isPassword = false,
      }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      validator: (value) =>
      (value == null || value.trim().isEmpty) ? 'Enter $label' : null,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: Icon(icon),
      ),
    );
  }

  Widget _buildDropdown() {
    return DropdownButtonFormField<String>(
      hint: const Text('Select a database', style: TextStyle(color: Colors.black)),
      value: _selectedDatabase,
      items: _dropdownItems,
      onChanged: _urlController.text.trim().isNotEmpty
          ? (item) => setState(() => _selectedDatabase = item)
          : null,
      decoration: InputDecoration(
        labelStyle: const TextStyle(color: Colors.black),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.black),
          borderRadius: BorderRadius.circular(5.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.black),
          borderRadius: BorderRadius.circular(5.0),
        ),
        prefixIcon: const Icon(Icons.storage, color: Colors.black),
        contentPadding: const EdgeInsets.symmetric(vertical: 16.0),
      ),
      iconEnabledColor: Colors.black,
      dropdownColor: Colors.white,
      style: const TextStyle(color: Colors.black),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Column(
              children: [
                Container(height: size.height * 0.5, color: const Color(0xFF7D3C98)),
                Container(height: size.height * 0.5, color: Colors.white60),
              ],
            ),
            Center(
              child: Container(
                width: size.width * 0.8,
                margin: EdgeInsets.only(top: size.height * 0.3),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildFormField(_urlController, 'Base URL', Icons.public),
                      const SizedBox(height: 20),
                      _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : _buildDropdown(),
                      const SizedBox(height: 20),
                      _buildFormField(_usernameController, 'Username', Icons.person),
                      const SizedBox(height: 20),
                      _buildFormField(_passwordController, 'Password', Icons.lock,
                          isPassword: true),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Checkbox(
                            value: _rememberMe,
                            onChanged: (value) {
                              setState(() {
                                _rememberMe = value ?? false;
                              });
                            },
                          ),
                          const Text('Remember Me'),
                        ],
                      ),
                      if (_errorMessage != null) ...[
                        const SizedBox(height: 16),
                        Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
                      ],
                      const SizedBox(height: 20),
                      Stack(
                        alignment: Alignment.topCenter,
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: GREEN_COLOR,
                                padding: const EdgeInsets.symmetric(vertical: 16.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                              child: const Text(
                                'Sign-in',
                                style: TextStyle(
                                  fontSize: 18.0,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          if (_isLoading) ...[
                            Positioned(
                              top: 2,
                              left: 3,
                              right: 3,
                              child: LinearProgressIndicator(
                                backgroundColor: Colors.white.withOpacity(0.5),
                                valueColor: AlwaysStoppedAnimation<Color>(GREEN_COLOR),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _urlController.removeListener(_onUrlChange);
    _urlController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}