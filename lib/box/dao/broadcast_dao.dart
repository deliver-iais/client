import 'dart:async';

import 'package:deliver/box/broadcast_status.dart';
import 'package:deliver/box/broadcast_success_and_failed_count.dart';
import 'package:deliver/box/db_manager.dart';
import 'package:deliver/box/hive_plus.dart';
import 'package:deliver/shared/extensions/string_extension.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:hive/hive.dart';

abstract class BroadcastDao {
  Future<BroadcastStatus?> getBroadcastStatus(
    String sendingId,
    Uid broadcastRoomId,
  );

  Future<void> deleteBroadcastStatus(String packetId, Uid broadcastRoomId);

  Stream<List<BroadcastStatus>> getAllBroadcastStatusAsStream(
    Uid broadcastRoomId,
  );

  Future<List<BroadcastStatus>> getAllBroadcastStatus(
    Uid broadcastRoomId,
  );

  Future<void> saveBroadcastStatus(
    Uid broadcastRoomId,
    BroadcastStatus broadcastStatus,
  );

  Future<void> clearAllBroadcastStatus(Uid broadcastRoomId);

  Future<BroadcastSuccessAndFailedCount?> getBroadcastSuccessAndFailedCount(
    int id,
    Uid broadcastRoomId,
  );

  Future<List<BroadcastSuccessAndFailedCount>>
      getAllBroadcastSuccessAndFailedCount(
    Uid broadcastRoomId,
  );

  Stream<BroadcastSuccessAndFailedCount?>
      getBroadcastSuccessAndFailedCountAsStream(int id, Uid broadcastRoomId);

  Future<void> increaseBroadcastSuccessCount(
    int id,
    Uid broadcastRoomId,
  );

  Future<void> decreaseBroadcastFailedCount(
    int id,
    Uid broadcastRoomId,
  );

  Future<void> setBroadcastFailedCount(
    int id,
    Uid broadcastRoomId,
    int failedCount,
  );

  Future<void> increaseBroadcastFailedCount(
    int id,
    Uid broadcastRoomId,
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
    Uid broadcastRoomId,
  ) async {
    final box = await _openBroadcastStatusBox(broadcastRoomId.asString());
    return box.delete(packetId);
  }

  @override
  Future<BroadcastStatus?> getBroadcastStatus(
    String sendingId,
    Uid broadcastRoomId,
  ) async {
    final box = await _openBroadcastStatusBox(broadcastRoomId.asString());
    return box.get(sendingId);
  }

  @override
  Stream<List<BroadcastStatus>> getAllBroadcastStatusAsStream(
    Uid broadcastRoomId,
  ) async* {
    final box = await _openBroadcastStatusBox(broadcastRoomId.asString());
    yield box.values.toList();
    yield* box.watch().map((event) => box.values.toList());
  }

  @override
  Future<BroadcastSuccessAndFailedCount?> getBroadcastSuccessAndFailedCount(
    int id,
    Uid broadcastRoomId,
  ) async {
    final box =
        await _openBroadcastSuccessAndFailedCount(broadcastRoomId.asString());
    return box.get(id);
  }

  @override
  Stream<BroadcastSuccessAndFailedCount?>
      getBroadcastSuccessAndFailedCountAsStream(
    int id,
    Uid broadcastRoomId,
  ) async* {
    final box =
        await _openBroadcastSuccessAndFailedCount(broadcastRoomId.asString());
    yield box.get(id);
    yield* box.watch(key: id).map((event) => box.get(id));
  }

  @override
  Future<void> saveBroadcastStatus(
    Uid broadcastRoomId,
    BroadcastStatus broadcastStatus,
  ) async {
    final box = await _openBroadcastStatusBox(broadcastRoomId.asString());
    return box.put(broadcastStatus.sendingId, broadcastStatus);
  }

  @override
  Future<List<BroadcastSuccessAndFailedCount>>
      getAllBroadcastSuccessAndFailedCount(Uid broadcastRoomId) async {
    final box =
        await _openBroadcastSuccessAndFailedCount(broadcastRoomId.asString());
    return box.values.toList();
  }

  @override
  Future<void> increaseBroadcastFailedCount(
    int id,
    Uid broadcastRoomId,
  ) async {
    final box =
        await _openBroadcastSuccessAndFailedCount(broadcastRoomId.asString());
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
    Uid broadcastRoomId,
  ) async {
    final box =
        await _openBroadcastSuccessAndFailedCount(broadcastRoomId.asString());
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
    Uid broadcastRoomId,
  ) async {
    final box =
        await _openBroadcastSuccessAndFailedCount(broadcastRoomId.asString());
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
  Future<void> clearAllBroadcastStatus(Uid broadcastRoomId) async {
    final box = await _openBroadcastStatusBox(broadcastRoomId.asString());
    return box.clear();
  }

  @override
  Future<List<BroadcastStatus>> getAllBroadcastStatus(
    Uid broadcastRoomId,
  ) async {
    final box = await _openBroadcastStatusBox(broadcastRoomId.asString());
    return box.values.toList();
  }

  @override
  Future<void> setBroadcastFailedCount(
    int id,
    Uid broadcastRoomId,
    int failedCount,
  ) async {
    final box =
        await _openBroadcastSuccessAndFailedCount(broadcastRoomId.asString());
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
