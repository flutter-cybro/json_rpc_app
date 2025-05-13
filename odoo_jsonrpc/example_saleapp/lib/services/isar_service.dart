import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../models/local_nodel/one2many_data.dart';

class IsarService {
  static Isar? _isar;

  static Future<Isar> getInstance() async {
    if (_isar == null) {
      try {
        final dir = await getApplicationDocumentsDirectory();
        print("Opening Isar in directory: ${dir.path}");
        _isar = await Isar.open(
          [One2ManyRecordSchema],
          directory: dir.path,
          inspector: false,
        );
        print("Isar initialized successfully");
      } catch (e, stackTrace) {
        print("Failed to initialize Isar: $e");
        print("Stack trace: $stackTrace");
        rethrow;
      }
    }
    return _isar!;
  }

  // Save a record
  Future<void> saveRecord(One2ManyRecord record) async {
    final isar = await getInstance();
    await isar.writeTxn(() async {
      await isar.one2ManyRecords.put(record);
    });
  }



  Future<List<One2ManyRecord>> getRecordsByTempId(int tempRecordId, {String? fieldName}) async {
    final isar = await _isar;
    return await isar!.one2ManyRecords
        .filter()
        .tempRecordIdEqualTo(tempRecordId)
        .optional(fieldName != null, (q) => q.fieldNameEqualTo(fieldName!))
        .findAll();
  }


  Future<List<One2ManyRecord>> getRecords(
      String mainModel, int mainRecordId, int tempRecordId) async {
    final isar = await getInstance();
    return await isar.one2ManyRecords
        .where()
        .mainModelEqualTo(mainModel)
        .filter()
        .mainRecordIdEqualTo(mainRecordId)
        .or()
        .tempRecordIdEqualTo(tempRecordId)
        .findAll();
  }

  // Delete a record by local ID
  Future<void> deleteRecord(int id) async {
    final isar = await getInstance();
    await isar.writeTxn(() async {
      await isar.one2ManyRecords.delete(id);
    });
  }

  // Update serverId and sync status after syncing
  Future<void> updateServerId(int localId, int serverId) async {
    final isar = await getInstance();
    await isar.writeTxn(() async {
      final record = await isar.one2ManyRecords.get(localId);
      if (record != null) {
        record.serverId = serverId;
        record.isSynced = true;
        await isar.one2ManyRecords.put(record);
      }
    });
  }

  // Get unsynced records
  Future<List<One2ManyRecord>> getUnsyncedRecords() async {
    final isar = await getInstance();
    return await isar.one2ManyRecords
        .filter()
        .isSyncedEqualTo(false)
        .findAll();
  }
}