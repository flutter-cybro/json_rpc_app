class Menu {
  final String name;
  final int id;
  final List<Menu> subMenus;
  final dynamic action;

  Menu({
    required this.name,
    required this.id,
    this.subMenus = const [],
    this.action,
  });

  factory Menu.fromJson(Map<String, dynamic> json) {
    return Menu(
      name: json['name'],
      id: json['id'],
      action: json['action'],
      subMenus: (json['subMenus'] as List<dynamic>? ?? [])
          .map((subMenuJson) => Menu.fromJson(subMenuJson))
          .toList(),
    );
  }
}
