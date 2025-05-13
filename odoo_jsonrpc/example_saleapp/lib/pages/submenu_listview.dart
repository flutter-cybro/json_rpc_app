import 'dart:developer';
import 'package:flutter/material.dart';
import '../mixins/action_mixier.dart';
import '../controller/odooclient_manager_controller.dart';
import '../controller/submenu_controller.dart';
import '../models/menu.dart';
import '../res/constants/app_colors.dart';
import '../res/utils/loading.dart';
import '../res/widgets/no_data_image.dart';
import 'form_view.dart';
import 'settings_form_view.dart';
import 'tree_view.dart';

class SubmenuListview extends StatefulWidget {
  final int moduleId;
  final String moduleName;

  const SubmenuListview({
    Key? key,
    required this.moduleId,
    required this.moduleName,
  }) : super(key: key);

  @override
  State<SubmenuListview> createState() => _SubmenuListviewState();
}

class _SubmenuListviewState extends State<SubmenuListview>
    with ActWindowActionMixin<SubmenuListview> {
  late SubmenuController submenuController;
  List<Menu> menuHierarchy = [];
  bool isLoading = true;
  List<Menu> currentMenuList = [];
  String currentTitle = '';

  @override
  OdooClientController get odooClientController => OdooClientController();

  @override
  void initState() {
    super.initState();
    print("module name  : ${widget.moduleName}");
    final client = odooClientController.client;
    submenuController = SubmenuController(client: client);
    currentTitle = widget.moduleName;
    fetchMenuData();
  }

  Future<void> fetchMenuData() async {
    setState(() => isLoading = true);
    try {
      final hierarchy = await submenuController.fetchSubChilds(widget.moduleId);
      setState(() {
        menuHierarchy = hierarchy;
        currentMenuList = hierarchy;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      _showErrorSnackBar('Failed to fetch menu data: $e');
      log('Error fetching menu data: $e');
    }
  }

  Future<void> navigateToSubmenu(Menu menu) async {
    setState(() => isLoading = true);

    try {
      if (menu.subMenus.isNotEmpty) {
        setState(() {
          currentMenuList = menu.subMenus;
          currentTitle = menu.name;
          isLoading = false;
        });
        return;
      }

      if (menu.action == null) {
        _showErrorSnackBar('No action defined for ${menu.name}');
        setState(() => isLoading = false);
        return;
      }

      final actionParts = menu.action!.split(',');
      final actionId = actionParts.length > 1 ? actionParts[1] : null;

      if (actionId == null) {
        _showErrorSnackBar('Invalid action format for ${menu.name}');
        setState(() => isLoading = false);
        return;
      }

      final isHandled = await callWindowAction(
        actionId: actionId,
        buildContext: context,
        modulename: widget.moduleName
      );

      if (!isHandled && targetWidget != null && mounted) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => targetWidget!));
      }
    } catch (e) {
      _showErrorSnackBar('Error loading action for ${menu.name}: $e');
      log('Error loading action: $e');
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void goBackToParentMenu() {
    setState(() {
      currentMenuList = menuHierarchy;
      currentTitle = widget.moduleName;
    });
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          currentTitle,
          style:
              TextStyle(fontSize: screenSize.width * 0.05, color: WHITE_COLOR),
        ),
        leading: IconButton(
          onPressed: () => currentMenuList == menuHierarchy
              ? Navigator.pop(context)
              : goBackToParentMenu(),
          icon: Icon(Icons.arrow_back_ios_new, color: WHITE_COLOR),
        ),
        centerTitle: true,
        backgroundColor: ODOO_COLOR,
      ),
      body: isLoading
          ? Center(child: RotatingLoadingWidget())
          : currentMenuList.isEmpty
              ? const NoDataWidget()
              : Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12.0,
                      mainAxisSpacing: 12.0,
                      childAspectRatio: 1.2,
                    ),
                    itemCount: currentMenuList.length,
                    itemBuilder: (context, index) {
                      final menu = currentMenuList[index];
                      return Card(
                        elevation: 5.0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.0)),
                        child: InkWell(
                          onTap: () => navigateToSubmenu(menu),
                          child: Center(
                            child: Text(
                              menu.name,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: screenSize.width * 0.04,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
