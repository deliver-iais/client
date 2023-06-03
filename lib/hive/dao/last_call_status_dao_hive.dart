import 'package:deliver/box/db_manager.dart';
import 'package:deliver/box/hive_plus.dart';
import 'package:deliver/box/last_call_status.dart';
import 'package:deliver/hive/last_call_status_hive.dart';
import 'package:hive/hive.dart';

abstract class LastCallStatusDao {
  Future<LastCallStatus?> get(int callSlot);

  Future<bool?> isExist(String callId, String roomUid);

  Future<void> save(
    LastCallStatus lastCallStatus,
  );
}

class LastCallStatusDaoImpl extends LastCallStatusDao {
  @override
  Future<bool?> isExist(String callId, String roomUid) async {
    final box = await _open();

    //here we just have one index and one data
    return box.values.where((element) {
      return element.callId == callId && element.roomUid == roomUid;
    }).isNotEmpty;
  }

  @override
  Future<void> save(
    LastCallStatus lastCallStatus,
  ) async {
    final box = await _open();

    return box.put(
      lastCallStatus.id,
      lastCallStatus.toHive(),
    );
  }

  @override
  Future<LastCallStatus?> get(int callSlot) async {
    final box = await _open();

    return box
        .get(
          callSlot,
        )
        ?.fromHive();
  }

  static String _key() => "last-call-status";

  Future<BoxPlus<LastCallStatusHive>> _open() {
    DBManager.open(
      _key(),
      TableInfo.LAST_CALL_STATUS_TABLE_NAME,
    );
    return gen(
      Hive.openBox<LastCallStatusHive>(_key()),
    );
  }
}
