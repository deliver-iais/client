import 'dart:async';

import 'package:deliver/box/db_manage.dart';
import 'package:deliver/box/hive_plus.dart';
import 'package:deliver/box/seen.dart';
import 'package:hive/hive.dart';

abstract class SeenDao extends DBManager {
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
    final box = await _openMySeen();

    final seen = box.get(uid) ?? _defaultSeenValue(uid);

    if ((messageId != null && seen.messageId < messageId) ||
        hiddenMessageCount != null) {
      return box.put(
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

  Future<BoxPlus<Seen>> _openOthersSeen() {
    super.open(_key(), MY_SEEN_TABLE_NAME);
    return gen(Hive.openBox<Seen>(_key()));
  }

  Future<BoxPlus<Seen>> _openMySeen() async {
    try {
      super.open(_key2(), OTHER_SEEN_TABLE_NAME);
      return gen(Hive.openBox<Seen>(_key2()));
    } catch (e) {
      await Hive.deleteBoxFromDisk(_key2());
      return gen(Hive.openBox<Seen>(_key2()));
    }
  }
}
