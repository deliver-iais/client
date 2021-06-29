import 'package:deliver_flutter/box/last_activity.dart';
import 'package:deliver_flutter/box/seen.dart';
import 'package:hive/hive.dart';

abstract class SeenDao {
  Future<Seen> getOthersSeen(String uid);
  
  Future<Seen> getMySeen(String uid);

  Future<void> saveOthersSeen(Seen seen);
  
  Future<void> saveMySeen(Seen seen);
}

class SeenDaoImpl implements SeenDao {
  Future<Seen> getOthersSeen(String uid) async {
    var box = await _openOthersSeen();

    return box.get(uid);
  }
  
  Future<Seen> getMySeen(String uid) async {
    var box = await _openMySeen();

    return box.get(uid);
  }

  Future<void> saveOthersSeen(Seen seen) async {
    var box = await _openOthersSeen();

    box.put(seen.uid, seen);
  }
  
  Future<void> saveMySeen(Seen seen) async {
    var box = await _openMySeen();

    box.put(seen.uid, seen);
  }

  static String _key() => "others-seen";
  static String _key2() => "my-seen";

  static Future<Box<Seen>> _openOthersSeen() =>
      Hive.openBox<Seen>(_key());
  
  static Future<Box<Seen>> _openMySeen() =>
      Hive.openBox<Seen>(_key2());
}
