import 'dart:async';

import 'package:deliver/box/dao/isar_manager.dart';
import 'package:deliver/box/dao/last_call_status_dao.dart';
import 'package:deliver/box/last_call_status.dart';
import 'package:deliver/isar/last_call_status_isar.dart';
import 'package:isar/isar.dart';

class LastCallStatusDaoImpl extends LastCallStatusDao {
  Isar? lastCallStatus;

  Future<Isar> _openPendingMessageIsar() => IsarManager.open();

  @override
  Future<bool?> isExist(String callId, String roomUid) async {
    final box = await _openPendingMessageIsar();

    //here we just have one index and one data
    return (await box.lastCallStatusIsars
        .filter()
        .callIdEqualTo(callId)
        .roomUidEqualTo(roomUid)
        .build()
        .isNotEmpty());
  }

  @override
  Future<void> save(
    LastCallStatus lastCallStatus,
  ) async {
    final box = await _openPendingMessageIsar();

    return box.writeTxn(() async {
      await box.lastCallStatusIsars.put(lastCallStatus.toIsar());
    });
  }

  @override
  Future<LastCallStatus?> get(int callSlot) async {
    final box = await _openPendingMessageIsar();

    return (await box.lastCallStatusIsars.get(callSlot))?.fromIsar();
  }
}
