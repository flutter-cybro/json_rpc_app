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

class _ProfileViewState extends State<ProfileView>
    with TickerProviderStateMixin {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmpasswordController =
      TextEditingController();
  Future<List<OdooUserProfile>>? _futureUserProfile;
  final _formKey = GlobalKey<FormState>();
  final _clientController = OdooClientController();

  late AnimationController _animationController;
  late AnimationController _fabAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeClient();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
  }

  Future<void> _initializeClient() async {
    try {
      await _clientController.initialize();
      setState(() {
        _futureUserProfile = fetchUserDetails();
      });
      _animationController.forward();
      _fabAnimationController.forward();
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
            name: userData['name'] is String
                ? userData['name'] as String
                : 'Unknown Name',
            email: userData['email'] is String
                ? userData['email'] as String
                : 'Email not available',
            city: userData['city'] is String
                ? userData['city'] as String
                : 'City not available',
            birthday: userData['birthday'] is String
                ? DateTime.tryParse(userData['birthday'] as String)
                : null,
            barcode_id: userData['barcode_id'] is String
                ? userData['barcode_id'] as String
                : 'No Barcode_id',
            company_name: userData['company_name'] is String
                ? userData['company_name'] as String
                : null,
            avatar_1024: userData['avatar_1024'] is String
                ? _getAvatarFromBase64(userData['avatar_1024'] as String)
                : null,
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.logout, color: Colors.red),
            ),
            const SizedBox(width: 12),
            const Text('Confirm Logout'),
          ],
        ),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Logout'),
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
              Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: ODOO_COLOR.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.lock_outline, color: ODOO_COLOR),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Change Password',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'New Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: ODOO_COLOR, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
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
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: ODOO_COLOR, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
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
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    backgroundColor: ODOO_COLOR,
                    elevation: 0,
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
                              content: Row(
                                children: [
                                  Icon(Icons.check_circle, color: Colors.white),
                                  SizedBox(width: 12),
                                  Text('Password changed successfully!'),
                                ],
                              ),
                              backgroundColor: Colors.green,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
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
                              content: Row(
                                children: [
                                  Icon(Icons.error, color: Colors.white),
                                  SizedBox(width: 12),
                                  Expanded(
                                      child: Text(
                                          'Failed to change password: $e')),
                                ],
                              ),
                              backgroundColor: Colors.red,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          );
                        }
                      }
                    }
                  },
                  child: const Text(
                    'Update Password',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(
      OdooUserProfile userProfile, BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    ODOO_COLOR,
                    ODOO_COLOR.withOpacity(0.8),
                    ODOO_COLOR.withOpacity(0.9),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
                boxShadow: [
                  BoxShadow(
                    color: ODOO_COLOR.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 40),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.3),
                              Colors.white.withOpacity(0.1),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 3,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 60,
                          backgroundImage: userProfile.avatar_1024 != null
                              ? MemoryImage(userProfile.avatar_1024!)
                              : null,
                          backgroundColor: Colors.white.withOpacity(0.2),
                          child: userProfile.avatar_1024 == null
                              ? Icon(
                                  Icons.person,
                                  size: 60,
                                  color: Colors.white.withOpacity(0.9),
                                )
                              : null,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.camera_alt,
                            size: 20,
                            color: ODOO_COLOR,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    userProfile.name,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 26,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (userProfile.barcode_id != 'No Barcode_id')
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          userProfile.barcode_id as String,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileItem(IconData icon, String title, String? value,
      {Color? iconColor}) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    // Add haptic feedback or actions
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: (iconColor ?? ODOO_COLOR).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            icon,
                            color: iconColor ?? ODOO_COLOR,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withOpacity(0.6),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                value ?? 'Not available',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
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
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: FutureBuilder<List<OdooUserProfile>>(
          future: _futureUserProfile,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildShimmerLoading();
            } else if (snapshot.hasError) {
              return _buildErrorState(snapshot.error.toString());
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return _buildEmptyState();
            }

            final userProfile = snapshot.data!.first;
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: _buildProfileHeader(userProfile, context),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildProfileItem(
                        Icons.email_outlined,
                        'Email',
                        userProfile.email,
                        iconColor: Colors.blue,
                      ),
                      _buildProfileItem(
                        Icons.location_city_outlined,
                        'City',
                        userProfile.city,
                        iconColor: Colors.green,
                      ),
                      if (userProfile.birthday != null)
                        _buildProfileItem(
                          Icons.cake_outlined,
                          'Birthday',
                          '${userProfile.birthday!.toLocal().day}/${userProfile.birthday!.toLocal().month}/${userProfile.birthday!.toLocal().year}',
                          iconColor: Colors.purple,
                        ),
                      if (userProfile.company_name != null)
                        _buildProfileItem(
                          Icons.business_outlined,
                          'Company',
                          userProfile.company_name,
                          iconColor: Colors.orange,
                        ),
                      const SizedBox(height: 100),
                    ]),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ScaleTransition(
            scale: _fabAnimationController,
            child: FloatingActionButton(
              heroTag: "logout",
              onPressed: _logout,
              backgroundColor: Colors.red,
              child: const Icon(Icons.logout, color: Colors.white),
            ),
          ),
          const SizedBox(height: 16),
          ScaleTransition(
            scale: _fabAnimationController,
            child: FloatingActionButton.extended(
              heroTag: "changePassword",
              onPressed: _changePasswordOverlay,
              backgroundColor: ODOO_COLOR,
              label: const Text('Change Password',
                  style: TextStyle(color: Colors.white)),
              icon: const Icon(Icons.lock_outline, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.error_outline, size: 60, color: Colors.red),
          ),
          const SizedBox(height: 24),
          const Text(
            'Oops! Something went wrong',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: const TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _initializeClient,
            style: ElevatedButton.styleFrom(
              backgroundColor: ODOO_COLOR,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child:
                const Icon(Icons.person_outline, size: 60, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          const Text(
            'No Profile Data',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Unable to load your profile information',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              height: 300,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: List.generate(
                4,
                (index) => Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _fabAnimationController.dispose();
    _passwordController.dispose();
    _confirmpasswordController.dispose();
    super.dispose();
  }
}
