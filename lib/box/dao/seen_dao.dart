import 'package:deliver/box/box_info.dart';
import 'package:deliver/box/seen.dart';
import 'package:hive/hive.dart';

abstract class SeenDao {
  Future<Seen?> getOthersSeen(String uid);

  Stream<Seen?> watchOthersSeen(String uid);

  Future<Seen> getMySeen(String uid);

  Stream<Seen> watchMySeen(String uid);

  Future<void> saveOthersSeen(Seen seen);

  Future<void> saveMySeen(Seen seen);
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

    return box.get(uid) ?? Seen(uid: uid, messageId: -1);
  }

  @override
  Stream<Seen> watchMySeen(String uid) async* {
    final box = await _openMySeen();

    yield box.get(uid) ?? Seen(uid: uid, messageId: 0);

    yield* box
        .watch(key: uid)
        .map((event) => box.get(uid) ?? Seen(uid: uid, messageId: 0));
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
  Future<void> saveMySeen(Seen seen) async {
    final box = await _openMySeen();

    final mySeen = box.get(seen.uid);

    if (mySeen == null ||
        mySeen.messageId < seen.messageId ||
        seen.hiddenMessageCount != null) {
      box.put(seen.uid, seen);
    }
  }

  static String _key() => "others-seen";

  static String _key2() => "my-seen";

  static Future<Box<Seen>> _openOthersSeen() {
    BoxInfo.addBox(_key());
    return Hive.openBox<Seen>(_key());
  }

  static Future<Box<Seen>> _openMySeen() async {
    try {
      BoxInfo.addBox(_key2());
      return Hive.openBox<Seen>(_key2());
    } catch (e) {
      await Hive.deleteBoxFromDisk(_key2());
      return Hive.openBox<Seen>(_key2());
    }
  }
}
