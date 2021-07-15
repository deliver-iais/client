import 'package:hive/hive.dart';

abstract class SharedDao {
  Future<String> get(String key);

  Stream<String> getStream(String key, {defaultValue: String});

  Future<void> put(String key, String value);

  Future<void> remove(String key);
}

class SharedDaoImpl implements SharedDao {
  Future<String> get(String key) async {
    var box = await _open();

    return box.get(key);
  }

  Stream<String> getStream(String key, {defaultValue: String}) async* {
    var box = await _open();

    yield box.get(key) ?? defaultValue;

    yield* box.watch(key: key).map((event) => box.get(key) ?? defaultValue);
  }

  Future<void> put(String key, String value) async {
    var box = await _open();

    box.put(key, value);
  }

  Future<void> remove(String key) async {
    var box = await _open();

    box.delete(key);
  }

  static Future<Box> _open() => Hive.openBox("shared");
}
