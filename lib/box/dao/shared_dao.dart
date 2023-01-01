import 'dart:async';
import 'dart:convert';

import 'package:clock/clock.dart';
import 'package:deliver/box/db_manager.dart';
import 'package:deliver/box/hive_plus.dart';
import 'package:deliver/models/time_counter.dart';
import 'package:hive/hive.dart';

class OnceOptions {
  final String key;
  final int count;
  final Duration period;

  const OnceOptions(this.key, this.count, this.period);
}

abstract class SharedDao {
  Future<String?> get(String key);

  Stream<String?> getStream(String key, {String? defaultValue});

  Future<void> put(String key, String value);

  Future<void> remove(String key);

  Future<bool> getBoolean(String key, {bool defaultValue = false});

  Stream<bool> getBooleanStream(String key, {bool defaultValue = false});

  Future<void> once(
    OnceOptions onceOptions,
    Future<void> Function() callback,
  );

  Future<void> resetTimeCounter(OnceOptions onceOptions);

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
    DBManager.open(_key(), TableInfo.SHARED_TABLE_NAME);
    return gen(Hive.openBox(_key()));
  }

  @override
  Future<void> once(
    OnceOptions onceOptions,
    void Function() callback,
  ) async {
    try {
      final box = await _open();
      final timeCounterModel = box.get(onceOptions.key);
      if (timeCounterModel != null) {
        final timeCounter = TimeCounter.fromJson(jsonDecode(timeCounterModel));
        if (timeCounter.count == 0 ||
            (timeCounter.count < onceOptions.count &&
                timeCheck(onceOptions.period, timeCounter.time))) {
          timeCounter.count++;
          timeCounter.time = clock.now().millisecondsSinceEpoch;
          await box.put(onceOptions.key, jsonEncode(timeCounter));

          return callback();
        }
      } else {
        await box.put(
          onceOptions.key,
          jsonEncode(
            TimeCounter(
              count: 1,
              time: clock.now().millisecondsSinceEpoch,
            ),
          ),
        );
        return callback();
      }
    } catch (_) {}
  }

  bool timeCheck(Duration period, int time) =>
      clock.now().millisecondsSinceEpoch - time > period.inMilliseconds;

  @override
  Future<void> resetTimeCounter(OnceOptions onceOptions) async {
    try {
      final box = await _open();
      unawaited(
        box.put(
          onceOptions.key,
          jsonEncode(
            TimeCounter(
              count: 0,
              time: clock.now().millisecondsSinceEpoch,
            ),
          ),
        ),
      );
    } catch (_) {}
  }
}
