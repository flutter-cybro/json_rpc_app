import 'package:isar/isar.dart';

part 'one2many_data.g.dart'; // Generated file

@Collection()
class One2ManyRecord {
  Id id = Isar.autoIncrement; // Local unique ID

  @Index()
  late int tempRecordId; // Temporary ID for new records (e.g., timestamp)

  int? serverId; // Odoo server ID (null for unsynced records)

  @Index()
  late String mainModel; // e.g., 'sale.order'

  @Index()
  late int mainRecordId; // Parent record ID (e.g., sale order ID)

  late String relationModel; // e.g., 'sale.order.line'

  late String relationField; // Field linking to main record (e.g., 'order_id')

  @Index()
  late String fieldName;

  late String data; // JSON-encoded record data

  late bool isSynced; // Sync status
}