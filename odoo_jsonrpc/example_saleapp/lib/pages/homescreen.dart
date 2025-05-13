import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:odoo_jsonrpc/odoo_jsonrpc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../controller/odooclient_manager_controller.dart';
import '../models/odoo_modules.dart';
import '../res/widgets/app_card_view.dart';
import '../res/widgets/home_drawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<List<OdooModule>>? _futureModules;
  final client = OdooClientController();
  String? url;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _initializeOdooClient();
  }

  Future<void> _initializeOdooClient() async {
    try {
      await client.initialize();
      setState(() {
        _futureModules = fetchInstalledApps();
      });
    } catch (e) {
    }
  }

  Future<List<OdooModule>> fetchInstalledApps() async {
    try {
      final result = await client.fetchInstalledApplications();
      if (result is List) {
        return result.map((module) {
          String? base64String;
          if (module['web_icon_data'] is String) {
            base64String = module['web_icon_data'];
          }

          Uint8List? iconBytes;
          if (base64String != null && base64String.isNotEmpty) {
            try {
              iconBytes = base64.decode(base64String);
            } catch (e) {
            }
          }

          return OdooModule(
            id: module['id'],
            display_name: module['display_name'],
            iconBytes: iconBytes,
            action: module['action'],
          );
        }).toList();
      } else {
        throw OdooException(
            'Unexpected result format from search_read: ${result.runtimeType}');
      }
    } catch (e) {
      throw OdooException('Failed to fetch installed apps');
    }
  }

  Future<void> _refresh() async {
    _initializeOdooClient();
  }

  @override
  void dispose() {
    print('dispose');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
      ),
      drawer: HomeDrawer(clientController: client),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<OdooModule>>(
          future: _futureModules,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              print('${snapshot.error}');
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                        'Error: Due to Some Reasons you can retry it or logout'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _refresh,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            } else {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 20.0,
                    mainAxisSpacing: 20.0,
                  ),
                  itemCount: snapshot.data?.length ?? 0,
                  itemBuilder: (context, index) {
                    final module = snapshot.data![index];
                    return AppCard(module: module);
                  },
                ),
              );
            }
          },
        ),
      ),
    );
  }
}