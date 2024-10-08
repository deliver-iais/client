import 'dart:async';

import 'package:deliver/box/dao/room_dao.dart';
import 'package:deliver/box/db_manager.dart';
import 'package:deliver/box/hive_plus.dart';
import 'package:deliver/box/seen.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';

abstract class SeenDao {
  Future<String?> getRoomSeen(String uid);

  Future<void> addRoomSeen(String uid);

  Stream<List<String>> watchAllRoomSeen();

  Future<void> deleteRoomSeen(String uid);

  Future<Seen?> getOthersSeen(String uid);

  Stream<Seen?> watchOthersSeen(String uid);

  Future<Seen> getMySeen(String uid);

  Stream<Seen> watchMySeen(String uid);

  Future<void> saveOthersSeen(Seen seen);

  Future<void> updateMySeen({
    required String uid,
    int? messageId,
    int? hiddenMessageCount,
  });
}

class SeenDaoImpl extends SeenDao {
  @override
  Future<Seen?> getOthersSeen(String uid) async {
    final box = await _openOthersSeen();

    return box.get(uid);
  }

  @override
  Stream<Seen?> watchOthersSeen(String uid) async* {
    final box = await _openOthersSeen();

    yield box.get(uid);

    yield* box.watch(key: uid).map((event) => box.get(uid));
  }

  @override
  Future<Seen> getMySeen(String uid) async {
    final box = await _openMySeen();

    return box.get(uid) ?? _defaultSeenValue(uid);
  }

  @override
  Stream<Seen> watchMySeen(String uid) async* {
    final box = await _openMySeen();

    yield box.get(uid) ?? _defaultSeenValue(uid);

    yield* box
        .watch(key: uid)
        .map((event) => box.get(uid) ?? _defaultSeenValue(uid));
  }

  @override
  Future<void> saveOthersSeen(Seen seen) async {
    final box = await _openOthersSeen();

    final othersSeen = box.get(seen.uid);

    if (othersSeen == null || othersSeen.messageId < seen.messageId) {
      return box.put(seen.uid, seen);
    }
  }

  @override
  Future<void> updateMySeen({
    required String uid,
    int? messageId,
    int? hiddenMessageCount,
  }) async {
    final mySeenBox = await _openMySeen();

    final seen = mySeenBox.get(uid) ?? _defaultSeenValue(uid);

    if ((messageId != null && seen.messageId < messageId) ||
        (hiddenMessageCount != null)) {
      final seenRoomBox = await _openRoomSeen();
      final seenRoom = seenRoomBox.get(uid);
      final roomDao = GetIt.I.get<RoomDao>();
      final room = await roomDao.getRoom(uid.asUid());

      if (room != null && (messageId ?? seen.messageId) > -1) {
        final unreadCount = room.lastMessageId -
            (messageId ?? seen.messageId) -
            (hiddenMessageCount ?? 0);
        if (seenRoom != null) {
          if (unreadCount <= 0) {
            await deleteRoomSeen(uid);
          }
        } else {
          if (unreadCount > 0) {
            await addRoomSeen(uid);
          }
        }
      }
      return mySeenBox.put(
        uid,
        seen.copyWith(
          uid: uid,
          messageId: messageId,
          hiddenMessageCount: hiddenMessageCount,
        ),
      );
    }
  }

  static Seen _defaultSeenValue(String uid) => Seen(
        uid: uid,
        messageId: -1,
        hiddenMessageCount: 0,
      );

  static String _key() => "others-seen";

  static String _key2() => "my-seen";

  static String _key3() => "room-seen";

  Future<BoxPlus<Seen>> _openOthersSeen() {
    DBManager.open(_key(), TableInfo.OTHER_SEEN_TABLE_NAME);
    return gen(Hive.openBox<Seen>(_key()));
  }

  Future<BoxPlus<String>> _openRoomSeen() {
    DBManager.open(_key3(), TableInfo.ROOM_SEEN_TABLE_NAME);
    return gen(Hive.openBox<String>(_key3()));
  }

  Future<BoxPlus<Seen>> _openMySeen() async {
    try {
      DBManager.open(_key2(), TableInfo.MY_SEEN_TABLE_NAME);
      return gen(Hive.openBox<Seen>(_key2()));
    } catch (e) {
      await Hive.deleteBoxFromDisk(_key2());
      return gen(Hive.openBox<Seen>(_key2()));
    }
  }

  @override
  Future<void> deleteRoomSeen(String uid) async {
    final box = await _openRoomSeen();
    return box.delete(uid);
  }

  @override
  Future<String?> getRoomSeen(String uid) async {
    final box = await _openRoomSeen();
    return box.get(uid);
  }

  @override
  Future<void> addRoomSeen(String uid) async {
    final box = await _openRoomSeen();
    return box.put(uid, uid);
  }

  @override
  Stream<List<String>> watchAllRoomSeen() async* {
    final box = await _openRoomSeen();

    yield box.values.toList();

    yield* box.watch().map((event) => box.values.toList());
  }
}
