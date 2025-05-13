import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../controller/odooclient_manager_controller.dart';
import '../../pages/login.dart';
import '../../res/constants/app_colors.dart';

class HomeDrawer extends StatelessWidget {
  final OdooClientController clientController;

  const HomeDrawer({super.key, required this.clientController});


  Future<Map<String, dynamic>> _getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userName = prefs.getString('userName') ?? 'Guest';
    Uint8List? userImage;


    try {
      final userProfile = await clientController.client.fetchUserProfile();
      if (userProfile is Map<String, dynamic> && userProfile['avatar_1024'] is String) {
        userImage = _getAvatarFromBase64(userProfile['avatar_1024'] as String);
      }
    } catch (e) {
      print('Error fetching user profile for drawer: $e');
    }

    return {
      'userName': userName,
      'userImage': userImage,
    };
  }

  Uint8List? _getAvatarFromBase64(String? base64String) {
    try {
      if (base64String != null && base64String.isNotEmpty) {
        return Uint8List.fromList(base64Decode(base64String));
      }
    } catch (e) {

    }
    return null;
  }


  Future<void> _removeShared() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('isLoggedIn');
    await prefs.remove('selectedDatabase');
    await prefs.remove('url');
    await prefs.remove('userName');
    await prefs.remove('userLogin');
    await prefs.remove('userId');
    await prefs.remove('sessionId');
    final bool rememberMe = prefs.getBool('rememberMe') ?? false;
    if (!rememberMe) {
      await prefs.clear();
    }
  }


  Future<void> _logout(BuildContext context) async {
    await _removeShared();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const Login()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: FutureBuilder<Map<String, dynamic>>(
        future: _getUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading user data'));
          }

          final userName = snapshot.data?['userName'] ?? 'Guest';
          final userImage = snapshot.data?['userImage'] as Uint8List?;

          return ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                decoration: BoxDecoration(
                  color: ODOO_COLOR,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: userImage != null
                          ? MemoryImage(userImage)
                          : const AssetImage('assets/default_profile.png')
                      as ImageProvider,
                      backgroundColor: Colors.white,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      userName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              ListTile(
                title: const Text('Profile'),
                onTap: () {
                  Navigator.pushNamed(context, '/profile');
                },
              ),
              // ListTile(
              //   title: const Text('Item 2'),
              //   onTap: () {
              //     Navigator.push(
              //       context,
              //       MaterialPageRoute(builder: (context) => const WidgetScafold()),
              //     );
              //   },
              // ),
              ListTile(
                title: const Text('Logout'),
                onTap: () => _logout(context),
              ),
            ],
          );
        },
      ),
    );
  }
}