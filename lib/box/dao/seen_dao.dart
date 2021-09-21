import 'package:deliver/box/seen.dart';
import 'package:hive/hive.dart';

abstract class SeenDao {
  Future<Seen> getOthersSeen(String uid);

  Stream<Seen> watchOthersSeen(String uid);

  Future<Seen> getMySeen(String uid);

  Stream<Seen> watchMySeen(String uid);

  Future<void> saveOthersSeen(Seen seen);

  Future<void> saveMySeen(Seen seen);
}

class SeenDaoImpl implements SeenDao {
  Future<Seen> getOthersSeen(String uid) async {
    var box = await _openOthersSeen();

    return box.get(uid);
  }

  Stream<Seen> watchOthersSeen(String uid) async* {
    var box = await _openOthersSeen();

    yield box.get(uid);

    yield* box.watch(key: uid).map((event) => box.get(uid));
  }

  Future<Seen> getMySeen(String uid) async {
    var box = await _openMySeen();

    return box.get(uid);
  }

  Stream<Seen> watchMySeen(String uid) async* {
    var box = await _openMySeen();

    yield box.get(uid);

    yield* box.watch(key: uid).map((event) => box.get(uid));
  }

  Future<void> saveOthersSeen(Seen seen) async {
    var box = await _openOthersSeen();

    var othersSeen = box.get(seen.uid);

    if (othersSeen == null || othersSeen.messageId < seen.messageId) {
      box.put(seen.uid, seen);
    }
  }

  Future<void> saveMySeen(Seen seen) async {
    if (seen == null || seen.messageId == null) return;

    var box = await _openMySeen();

    var mySeen = box.get(seen.uid);

    if (mySeen == null ||
        (mySeen != null && mySeen.messageId < seen.messageId)) {
      box.put(seen.uid, seen);
    }
  }

  static String _key() => "others-seen";

  static String _key2() => "my-seen";

  static Future<Box<Seen>> _openOthersSeen() => Hive.openBox<Seen>(_key());

  static Future<Box<Seen>> _openMySeen() => Hive.openBox<Seen>(_key2());
}
