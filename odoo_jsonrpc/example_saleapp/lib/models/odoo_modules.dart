import 'dart:typed_data';

class OdooModule {
  final int id;
  final String? action;
  final String display_name;
  final Uint8List? iconBytes;
  final String? actionpath;

  OdooModule({
    required this.id,
    required this.display_name,
    this.iconBytes,
    this.action,
    this.actionpath
  });
}