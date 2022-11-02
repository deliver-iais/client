import 'package:deliver/box/db_manager.dart';
import 'package:deliver/box/hive_plus.dart';
import 'package:hive/hive.dart';

abstract class SharedDao extends DBManager {
  Future<String?> get(String key);

  Stream<String?> getStream(String key, {String? defaultValue});

  Future<void> put(String key, String value);

  Future<void> remove(String key);

  Future<bool> getBoolean(String key, {bool defaultValue = false});

  Stream<bool> getBooleanStream(String key, {bool defaultValue = false});

  // ignore: avoid_positional_boolean_parameters
  Future<void> putBoolean(String key, bool value);

  Future<bool> toggleBoolean(String key);
}

class SharedDaoImpl extends SharedDao {
  @override
  Future<String?> get(String key) async {
    final box = await _open();

    return box.get(key);
  }

  @override
  Stream<String?> getStream(String key, {String? defaultValue}) async* {
    final box = await _open();

    yield box.get(key, defaultValue: defaultValue).toString();

    yield* box.watch(key: key).map((event) => box.get(key) ?? defaultValue);
  }

  @override
  Future<void> put(String key, String value) async {
    final box = await _open();

    return box.put(key, value);
  }

  @override
  Future<void> remove(String key) async {
    final box = await _open();

    return box.delete(key);
  }

  @override
  Future<bool> getBoolean(String key, {bool defaultValue = false}) =>
      get(key).then((value) => value == null ? defaultValue : value == "t");

  @override
  Stream<bool> getBooleanStream(String key, {bool defaultValue = false}) =>
      getStream(key, defaultValue: defaultValue ? "t" : "f")
          .map((value) => value == "t");

  @override
  Future<void> putBoolean(String key, bool value) =>
      put(key, value ? "t" : "f");

  @override
  Future<bool> toggleBoolean(String key) async {
    final toggledBoolean = !(await getBoolean(key));
    await put(key, toggledBoolean ? "t" : "f");
    return toggledBoolean;
  }

  static String _key() => "shared";

  Future<BoxPlus> _open() {
    super.open(_key(), TableInfo.SHARED_TABLE_NAME);
    return gen(Hive.openBox(_key()));
  }
}
