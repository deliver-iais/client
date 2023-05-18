import 'dart:async';

import 'package:deliver/box/broadcast_status.dart';
import 'package:deliver/box/broadcast_success_and_failed_count.dart';
import 'package:deliver/box/db_manager.dart';
import 'package:deliver/box/hive_plus.dart';
import 'package:deliver/shared/extensions/string_extension.dart';
import 'package:hive/hive.dart';

abstract class BroadcastDao {
  Future<BroadcastStatus?> getBroadcastStatus(
    String sendingId,
    String broadcastRoomId,
  );

  Future<void> deleteBroadcastStatus(String packetId, String broadcastRoomId);

  Stream<List<BroadcastStatus>> getAllBroadcastStatusAsStream(
    String broadcastRoomId,
  );

  Future<List<BroadcastStatus>> getAllBroadcastStatus(
    String broadcastRoomId,
  );

  Future<void> saveBroadcastStatus(
    String broadcastRoomId,
    BroadcastStatus broadcastStatus,
  );

  Future<void> clearAllBroadcastStatus(String broadcastRoomId);

  Future<BroadcastSuccessAndFailedCount?> getBroadcastSuccessAndFailedCount(
    int id,
    String broadcastRoomId,
  );

  Future<List<BroadcastSuccessAndFailedCount>>
      getAllBroadcastSuccessAndFailedCount(
    String broadcastRoomId,
  );

  Stream<BroadcastSuccessAndFailedCount?>
      getBroadcastSuccessAndFailedCountAsStream(int id, String broadcastRoomId);

  Future<void> increaseBroadcastSuccessCount(
    int id,
    String broadcastRoomId,
  );

  Future<void> decreaseBroadcastFailedCount(
    int id,
    String broadcastRoomId,
  );

  Future<void> setBroadcastFailedCount(
    int id,
    String broadcastRoomId,
    int failedCount,
  );

  Future<void> increaseBroadcastFailedCount(
    int id,
    String broadcastRoomId,
  );
}

class BroadcastDaoImpl extends BroadcastDao {
  static String _broadcastSuccessAndFailedCountKey(String uid) =>
      "broadcast_success_and_failed_count_${uid.convertUidStringToDaoKey()}";

  static String _broadcastStatus(String uid) =>
      "broadcast_status_${uid.convertUidStringToDaoKey()}";

  Future<BoxPlus<BroadcastStatus>> _openBroadcastStatusBox(
    String broadcastRoomId,
  ) async {
    try {
      DBManager.open(
        _broadcastStatus(broadcastRoomId),
        TableInfo.BROADCAST_STATUS_TABLE_NAME,
      );
      return gen(
        Hive.openBox<BroadcastStatus>(_broadcastStatus(broadcastRoomId)),
      );
    } catch (e) {
      await Hive.deleteBoxFromDisk(_broadcastStatus(broadcastRoomId));
      return gen(
        Hive.openBox<BroadcastStatus>(_broadcastStatus(broadcastRoomId)),
      );
    }
  }

  Future<BoxPlus<BroadcastSuccessAndFailedCount>>
      _openBroadcastSuccessAndFailedCount(
    String broadcastRoomId,
  ) async {
    try {
      DBManager.open(
        _broadcastSuccessAndFailedCountKey(broadcastRoomId),
        TableInfo.BROADCAST_SUCCESS_AND_FAILED_COUNT_TABLE_NAME,
      );
      return gen(
        Hive.openBox<BroadcastSuccessAndFailedCount>(
          _broadcastSuccessAndFailedCountKey(broadcastRoomId),
        ),
      );
    } catch (e) {
      await Hive.deleteBoxFromDisk(
        _broadcastSuccessAndFailedCountKey(broadcastRoomId),
      );
      return gen(
        Hive.openBox<BroadcastSuccessAndFailedCount>(
          _broadcastSuccessAndFailedCountKey(broadcastRoomId),
        ),
      );
    }
  }

  @override
  Future<void> deleteBroadcastStatus(
    String packetId,
    String broadcastRoomId,
  ) async {
    final box = await _openBroadcastStatusBox(broadcastRoomId);
    return box.delete(packetId);
  }

  @override
  Future<BroadcastStatus?> getBroadcastStatus(
    String sendingId,
    String broadcastRoomId,
  ) async {
    final box = await _openBroadcastStatusBox(broadcastRoomId);
    return box.get(sendingId);
  }

  @override
  Stream<List<BroadcastStatus>> getAllBroadcastStatusAsStream(
    String broadcastRoomId,
  ) async* {
    final box = await _openBroadcastStatusBox(broadcastRoomId);
    yield box.values.toList();
    yield* box.watch().map((event) => box.values.toList());
  }

  @override
  Future<BroadcastSuccessAndFailedCount?> getBroadcastSuccessAndFailedCount(
    int id,
    String broadcastRoomId,
  ) async {
    final box = await _openBroadcastSuccessAndFailedCount(broadcastRoomId);
    return box.get(id);
  }

  @override
  Stream<BroadcastSuccessAndFailedCount?>
      getBroadcastSuccessAndFailedCountAsStream(
    int id,
    String broadcastRoomId,
  ) async* {
    final box = await _openBroadcastSuccessAndFailedCount(broadcastRoomId);
    yield box.get(id);
    yield* box.watch(key: id).map((event) => box.get(id));
  }

  @override
  Future<void> saveBroadcastStatus(
    String broadcastRoomId,
    BroadcastStatus broadcastStatus,
  ) async {
    final box = await _openBroadcastStatusBox(broadcastRoomId);
    return box.put(broadcastStatus.sendingId, broadcastStatus);
  }

  @override
  Future<List<BroadcastSuccessAndFailedCount>>
      getAllBroadcastSuccessAndFailedCount(String broadcastRoomId) async {
    final box = await _openBroadcastSuccessAndFailedCount(broadcastRoomId);
    return box.values.toList();
  }

  @override
  Future<void> increaseBroadcastFailedCount(
    int id,
    String broadcastRoomId,
  ) async {
    final box = await _openBroadcastSuccessAndFailedCount(broadcastRoomId);
    final broadcastCount = box.get(id);
    if (broadcastCount != null) {
      return box.put(
        id,
        broadcastCount.copyWith(
          broadcastFailedCount: broadcastCount.broadcastFailedCount + 1,
        ),
      );
    } else {
      final keys = box.keys;
      if (keys.length > 30) {
        await box.delete(keys.first);
      }
      return box.put(
        id,
        BroadcastSuccessAndFailedCount(
          broadcastSuccessCount: 0,
          broadcastFailedCount: 1,
          broadcastMessageId: id,
        ),
      );
    }
  }

  @override
  Future<void> increaseBroadcastSuccessCount(
    int id,
    String broadcastRoomId,
  ) async {
    final box = await _openBroadcastSuccessAndFailedCount(broadcastRoomId);
    final broadcastCount = box.get(id);
    if (broadcastCount != null) {
      return box.put(
        id,
        broadcastCount.copyWith(
          broadcastSuccessCount: broadcastCount.broadcastSuccessCount + 1,
        ),
      );
    } else {
      final keys = box.keys;
      if (keys.length > 30) {
        await box.delete(keys.first);
      }
      return box.put(
        id,
        BroadcastSuccessAndFailedCount(
          broadcastSuccessCount: 1,
          broadcastFailedCount: 0,
          broadcastMessageId: id,
        ),
      );
    }
  }

  @override
  Future<void> decreaseBroadcastFailedCount(
    int id,
    String broadcastRoomId,
  ) async {
    final box = await _openBroadcastSuccessAndFailedCount(broadcastRoomId);
    final broadcastCount = box.get(id);
    if (broadcastCount != null && broadcastCount.broadcastFailedCount > 0) {
      return box.put(
        id,
        broadcastCount.copyWith(
          broadcastSuccessCount: broadcastCount.broadcastFailedCount - 1,
        ),
      );
    }
  }

  @override
  Future<void> clearAllBroadcastStatus(String broadcastRoomId) async {
    final box = await _openBroadcastStatusBox(broadcastRoomId);
    return box.clear();
  }

  @override
  Future<List<BroadcastStatus>> getAllBroadcastStatus(
    String broadcastRoomId,
  ) async {
    final box = await _openBroadcastStatusBox(broadcastRoomId);
    return box.values.toList();
  }

  @override
  Future<void> setBroadcastFailedCount(
    int id,
    String broadcastRoomId,
    int failedCount,
  ) async {
    final box = await _openBroadcastSuccessAndFailedCount(broadcastRoomId);
    final broadcastCount = box.get(id);
    if (broadcastCount != null && broadcastCount.broadcastFailedCount > 0) {
      return box.put(
        id,
        broadcastCount.copyWith(
          broadcastFailedCount: failedCount,
        ),
      );
    }
  }
}
