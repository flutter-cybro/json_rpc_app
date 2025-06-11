import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:odoo_jsonrpc/odoo_jsonrpc.dart';
import '../controller/odooclient_manager_controller.dart';
import '../models/odoo_modules.dart';
import '../res/widgets/app_card_view.dart';
import '../res/widgets/home_drawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  Future<List<OdooModule>>? _futureModules;
  final client = OdooClientController();
  bool _isSearchActive = false;
  String _searchQuery = '';
  List<OdooModule>? _filteredModules;
  List<OdooModule>? _allModules;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _searchBarAnimation;

  @override
  void initState() {
    super.initState();
    _initializeOdooClient();
    _searchController.addListener(_onSearchChanged);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _searchBarAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  Future<void> _initializeOdooClient() async {
    try {
      await client.initialize();
      setState(() {
        _futureModules = fetchInstalledApps();
      });
    } catch (e) {
      print('Error initializing Odoo client: $e');
    }
  }

  Future<List<OdooModule>> fetchInstalledApps() async {
    try {
      final result = await client.fetchInstalledApplications();
      if (result is List) {
        final modules = result.map((module) {
          String? base64String;
          if (module['web_icon_data'] is String) {
            base64String = module['web_icon_data'];
          }

          Uint8List? iconBytes;
          if (base64String != null && base64String.isNotEmpty) {
            try {
              iconBytes = base64.decode(base64String);
            } catch (e) {
              print('Error decoding base64 icon: $e');
            }
          }

          return OdooModule(
            id: module['id'],
            display_name: module['display_name'],
            iconBytes: iconBytes,
            action: module['action'],
          );
        }).toList();
        _allModules = modules;
        _filteredModules = modules;
        return modules;
      } else {
        throw OdooException(
            'Unexpected result format from search_read: ${result.runtimeType}');
      }
    } catch (e) {
      throw OdooException('Failed to fetch installed apps: $e');
    }
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
      if (_allModules != null) {
        _filteredModules = _allModules!
            .where((module) =>
            module.display_name.toLowerCase().contains(_searchQuery))
            .toList();
      } else {
        _filteredModules = [];
      }
    });
  }

  void _toggleSearch() {
    setState(() {
      _isSearchActive = !_isSearchActive;
      if (_isSearchActive) {
        _animationController.forward();
      } else {
        _animationController.reverse();
        _searchController.clear();
        _searchQuery = '';
        _filteredModules = _allModules;
      }
    });
  }

  Future<void> _refresh() async {
    setState(() {
      _futureModules = fetchInstalledApps();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    print('dispose');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;

    // Responsive grid columns: 2 for mobile, 3 for tablets, 4 for larger screens
    final crossAxisCount = screenWidth < 600 ? 2 : screenWidth < 900 ? 3 : 4;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        elevation: 4,
        shadowColor: theme.colorScheme.shadow.withOpacity(0.2),
        title: _isSearchActive
            ? FadeTransition(
          opacity: _searchBarAnimation,
          child: TextField(
            controller: _searchController,
            autofocus: true,
            style: theme.textTheme.bodyLarge,
            decoration: InputDecoration(
              hintText: 'Search modules...',
              hintStyle: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerHigh,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              suffixIcon: IconButton(
                icon: Icon(Icons.clear, color: theme.colorScheme.onSurface),
                onPressed: _toggleSearch,
              ),
            ),
          ),
        )
            : Text(
          'Odoo Modules',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onPrimary,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.menu, color: theme.colorScheme.onPrimary),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        actions: [
          if (!_isSearchActive)
            IconButton(
              icon: Icon(Icons.search, color: theme.colorScheme.onPrimary),
              onPressed: _toggleSearch,
            ),
        ],
        backgroundColor: theme.colorScheme.primary,
      ),
      drawer: HomeDrawer(clientController: client),
      body: RefreshIndicator(
        onRefresh: _refresh,
        color: theme.colorScheme.primary,
        backgroundColor: theme.colorScheme.surface,
        child: FutureBuilder<List<OdooModule>>(
          future: _futureModules,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Loading modules...',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: theme.colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load modules',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Please try again or logout.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _refresh,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            } else {
              final modules = _searchQuery.isEmpty ? snapshot.data : _filteredModules;
              if (modules == null || modules.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 48,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _searchQuery.isEmpty ? 'No modules found' : 'No matching modules',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _searchQuery.isEmpty
                            ? 'Try refreshing to load modules.'
                            : 'Try a different search term.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (_searchQuery.isEmpty) ...[
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          onPressed: _refresh,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Refresh'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: theme.colorScheme.primary,
                            side: BorderSide(color: theme.colorScheme.primary),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }
              return Padding(
                padding: const EdgeInsets.all(16),
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: modules.length,
                  itemBuilder: (context, index) {
                    final module = modules[index];
                    return AnimatedOpacity(
                      opacity: 1,
                      duration: const Duration(milliseconds: 300),
                      child: AppCard(module: module),
                    );
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