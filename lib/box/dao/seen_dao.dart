import 'package:deliver/box/box_info.dart';
import 'package:deliver/box/hive_plus.dart';
import 'package:deliver/box/seen.dart';
import 'package:hive/hive.dart';

abstract class SeenDao {
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

class SeenDaoImpl implements SeenDao {
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
      box.put(seen.uid, seen);
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
      box.put(
        uid,
        seen.copyWith(
          uid: uid,
          messageId: messageId,
          hiddenMessageCount: hiddenMessageCount,
        ),
      );
    }
  }

  static Seen _defaultSeenValue(String uid) => Seen(uid: uid, messageId: -1);

  static String _key() => "others-seen";

  static String _key2() => "my-seen";

  static Future<BoxPlus<Seen>> _openOthersSeen() {
    BoxInfo.addBox(_key());
    return gen(Hive.openBox<Seen>(_key()));
  }

  static Future<BoxPlus<Seen>> _openMySeen() async {
    try {
      BoxInfo.addBox(_key2());
      return gen(Hive.openBox<Seen>(_key2()));
    } catch (e) {
      await Hive.deleteBoxFromDisk(_key2());
      return gen(Hive.openBox<Seen>(_key2()));
    }
  }
}
