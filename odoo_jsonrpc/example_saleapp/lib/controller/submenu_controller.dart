import '../models/menu.dart';

class SubmenuController{
  final dynamic client;
  SubmenuController({required this.client});

  Future<List<Menu>> fetchSubChilds(int moduleId) async {
    List<Menu> menuHierarchy = [];

    try {
      final subMenus = await client?.callKw({
        'model': 'ir.ui.menu',
        'method': 'search_read',
        'args': [
          [
            ['parent_id', '=', moduleId],
          ],
        ],
        'kwargs': {
          'fields': ['name', 'id', 'parent_id', 'action'],
        },
      });

      if (subMenus != null && subMenus.isNotEmpty) {
        for (var menu in subMenus) {
          final subChildHierarchy = await fetchSubChilds(menu['id']);
          menuHierarchy.add(Menu(
            name: menu['name'],
            id: menu['id'],
            action: menu['action'],
            subMenus: subChildHierarchy,
          ));
        }
      }
    } catch (e) {
    }

    return menuHierarchy;
  }
}
