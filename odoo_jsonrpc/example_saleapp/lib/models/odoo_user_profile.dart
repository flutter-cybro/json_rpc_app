import 'dart:typed_data';

class OdooUserProfile{
  final int id;
  final String name;
  final String email;
  final String city;
  final DateTime? birthday;
  final String? barcode_id;
  final String? company_name;
  final Uint8List? avatar_1024;

  OdooUserProfile({
    required this.id,
    required this.name,
    required this.city,
    required this.email,
    this.avatar_1024,
    this.birthday,
    this.company_name,
    this.barcode_id,
});
}


