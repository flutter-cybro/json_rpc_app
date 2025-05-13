import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:example_saleapp/models/odoo_user_profile.dart';
import 'package:odoo_jsonrpc/odoo_jsonrpc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import '../controller/odooclient_manager_controller.dart';
import '../res/constants/app_colors.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmpasswordController = TextEditingController();
  Future<List<OdooUserProfile>>? _futureUserProfile;
  final _formKey = GlobalKey<FormState>();
  final _clientController = OdooClientController();

  @override
  void initState() {
    super.initState();
    _initializeClient();
  }

  Future<void> _initializeClient() async {
    try {
      await _clientController.initialize();
      setState(() {
        _futureUserProfile = fetchUserDetails();
      });
    } catch (e) {
      // Handle error
    }
  }

  Future<List<OdooUserProfile>> fetchUserDetails() async {
    try {
      final result = await _clientController.client.fetchUserProfile();
      if (result is Map<String, dynamic>) {
        final userData = result;
        return [
          OdooUserProfile(
            id: userData['id'] is int ? userData['id'] as int : 0,
            name: userData['name'] is String ? userData['name'] as String : 'Unknown Name',
            email: userData['email'] is String ? userData['email'] as String : 'Email not available',
            city: userData['city'] is String ? userData['city'] as String : 'City not available',
            birthday: userData['birthday'] is String ? DateTime.tryParse(userData['birthday'] as String) : null,
            barcode_id: userData['barcode_id'] is String ? userData['barcode_id'] as String : 'No Barcode_id',
            company_name: userData['company_name'] is String ? userData['company_name'] as String : null,
            avatar_1024: userData['avatar_1024'] is String ? _getAvatarFromBase64(userData['avatar_1024'] as String) : null,
          ),
        ];
      }
      throw Exception('Expected a Map from fetchUserProfile');
    } catch (e) {
      throw Exception('Failed to fetch user details: $e');
    }
  }

  Uint8List? _getAvatarFromBase64(String? base64String) {
    try {
      if (base64String != null && base64String.isNotEmpty) {
        return Uint8List.fromList(base64Decode(base64String));
      }
    } catch (e) {
      // Handle error
    }
    return null;
  }

  Future<void> _logout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  void _changePasswordOverlay() {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 24,
          right: 24,
          top: 24,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Change Password',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'New Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  prefixIcon: const Icon(Icons.lock_outline),
                ),
                validator: (password) {
                  if (password == null || password.isEmpty) {
                    return 'Please enter a password';
                  }
                  if (password.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmpasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  prefixIcon: const Icon(Icons.lock_outline),
                ),
                validator: (confirmpassword) {
                  if (confirmpassword == null || confirmpassword.isEmpty) {
                    return 'Please confirm your password';
                  }
                  if (confirmpassword != _passwordController.text.trim()) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: ODOO_COLOR,
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final prefs = await SharedPreferences.getInstance();
                      final db = prefs.getString('selectedDatabase') ?? '';
                      final userLogin = prefs.getString('userLogin') ?? '';
                      final newPassword = _passwordController.text.trim();

                      try {
                        final authResponse = await _clientController.client
                            .authenticate(db, userLogin, newPassword);
                        prefs.setString('sessionId', authResponse.id);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Password changed successfully!'),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          );
                          Navigator.pop(context);
                          _passwordController.clear();
                          _confirmpasswordController.clear();
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to change password: $e'),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          );
                        }
                      }
                    }
                  },
                  child: const Text(
                    'Update Password',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(OdooUserProfile userProfile, BuildContext context) {
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWideScreen = constraints.maxWidth > 600;
        return Container(
          decoration: BoxDecoration(
            color: ODOO_COLOR,
            borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
            bottomRight: Radius.circular(24),
          ),
        ),
        padding: EdgeInsets.symmetric(
        horizontal: isWideScreen ? 48 : 24,
        vertical: isWideScreen ? 48 : 32,
        ),
        child: Column(
        children: [
        Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
        Expanded(
        child: Column(
        children: [
        Stack(
        alignment: Alignment.bottomRight,
        children: [
        Container(
        decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
        color: theme.colorScheme.surface,
        width: 3,
        ),
        ),
        child: CircleAvatar(
        radius: isWideScreen ? 80 : 60,
        backgroundImage: userProfile.avatar_1024 != null
        ? MemoryImage(userProfile.avatar_1024!)
            : null,
        backgroundColor: Colors.grey[300],
        child: userProfile.avatar_1024 == null
        ? Icon(
        Icons.person,
        size: isWideScreen ? 80 : 60,
        color: Colors.white,
        )
            : null,
        ),
        ),
        Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        shape: BoxShape.circle,
        ),
        child: Icon(
        Icons.edit,
        size: isWideScreen ? 24 : 20,
        color: ODOO_COLOR,
        ),
        ),
        ],
        ),
        ],
        ),
        ),
        if (isWideScreen)
        SizedBox(
        width: 200,
        child: OutlinedButton.icon(
        icon: const Icon(Icons.logout),
        label: const Text('Logout'),
        style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: const BorderSide(color: Colors.white),
        shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        ),
        ),
        onPressed: _logout,
        ),
        ),
        ],
        ),
        const SizedBox(height: 16),
        Text(
        userProfile.name,
        style: theme.textTheme.headlineSmall?.copyWith(
        color: theme.colorScheme.surface,
        fontWeight: FontWeight.bold,
        fontSize: isWideScreen ? 28 : 24,
        ),
        textAlign: TextAlign.center,
        ),
        if (userProfile.barcode_id != 'No Barcode_id')
        Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
        userProfile.barcode_id as String,
        style: theme.textTheme.bodyMedium?.copyWith(
        color: theme.colorScheme.surface.withOpacity(0.9),
        fontSize: isWideScreen ? 16 : 14,
        ),
        textAlign: TextAlign.center,
        ),
        ),
        if (!isWideScreen)
        Padding(
        padding: const EdgeInsets.only(top: 16),
        child: OutlinedButton.icon(
        icon: const Icon(Icons.logout),
        label: const Text('Logout'),
        style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: const BorderSide(color: Colors.white),
        shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        ),
        ),
        onPressed: _logout,
        ),
        ),
        ],
        ),
        );
        },
    );
  }

  Widget _buildProfileItem(IconData icon, String title, String? value) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWideScreen = constraints.maxWidth > 600;
        return Container(
          margin: EdgeInsets.symmetric(
            horizontal: isWideScreen ? 32 : 16,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: ODOO_COLOR.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: ODOO_COLOR,
                size: isWideScreen ? 28 : 24,
              ),
            ),
            title: Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                fontSize: isWideScreen ? 14 : 12,
              ),
            ),
            subtitle: Text(
              value ?? 'Not available',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontSize: isWideScreen ? 18 : 16,
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: ODOO_COLOR,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
        title: Text(
          'My Profile',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return FutureBuilder<List<OdooUserProfile>>(
              future: _futureUserProfile,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildShimmerLoading();
                } else if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          'Failed to load profile',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          snapshot.error.toString(),
                          style: Theme.of(context).textTheme.bodySmall,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _initializeClient,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text(
                      'No profile data available',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  );
                }
                final userProfile = snapshot.data!.first;
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildProfileHeader(userProfile, context),
                      const SizedBox(height: 24),
                      _buildProfileItem(Icons.email_outlined, 'Email', userProfile.email),
                      _buildProfileItem(Icons.location_city_outlined, 'City', userProfile.city),
                      if (userProfile.birthday != null)
                        _buildProfileItem(
                          Icons.cake_outlined,
                          'Birthday',
                          '${userProfile.birthday!.toLocal().day}/${userProfile.birthday!.toLocal().month}/${userProfile.birthday!.toLocal().year}',
                        ),
                      if (userProfile.company_name != null)
                        _buildProfileItem(
                          Icons.business_outlined,
                          'Company',
                          userProfile.company_name,
                        ),
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: SizedBox(
                          width: constraints.maxWidth > 600 ? 400 : double.infinity,
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.lock_outline),
                            label: const Text('Change Password'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: ODOO_COLOR,
                              side: BorderSide(color: ODOO_COLOR),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            onPressed: _changePasswordOverlay,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWideScreen = constraints.maxWidth > 600;
        return SingleChildScrollView(
          child: Column(
            children: [
              Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  height: isWideScreen ? 350 : 300,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: isWideScreen ? 32 : 16),
                child: Column(
                  children: List.generate(
                    4,
                        (index) => Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}