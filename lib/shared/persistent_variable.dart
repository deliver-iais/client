import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:battery_plus/battery_plus.dart';
import 'package:clock/clock.dart';
import 'package:deliver/box/dao/shared_dao.dart';
import 'package:deliver/models/time_counter.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:get_it/get_it.dart';
import 'package:path_provider/path_provider.dart';

// TODO(bitbeter): add in package.yaml
// ignore: depend_on_referenced_packages
import 'package:protobuf/protobuf.dart' as $pb;
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Variable Interface
abstract class _Variable<T> {
  final BehaviorSubject<T> _value;

  final T defaultValue;

  _Variable({required this.defaultValue})
      : _value = BehaviorSubject.seeded(defaultValue);

  bool set(T value) {
    if (_value.value == value) return false;

    _value.add(value);

    return true;
  }

  // Abstract variables and methods

  Stream<T> get stream;

  T get value;

  T stringToType(String? value, {required T defaultValue});

  String typeToString(T value);
}

/// Storage Interface
abstract class Storage {
  final SharedKeys key;

  const Storage(this.key);

  void save(String value);

  String? get();
}

/// Persistent Variable Interface
abstract class _PersistentVariable<T> extends _Variable<T> {
  final Storage storage;

  _PersistentVariable(this.storage, {required super.defaultValue}) {
    init();
  }

  Future<void> init() async {
    final val = storage.get();
    if (val != null) {
      _value.add(stringToType(val, defaultValue: defaultValue));
    }
  }

  @override
  bool set(T value, {bool retry = true}) {
    try {
      if (super.set(value)) {
        storage.save(typeToString(value));
        return true;
      }
      return false;
    } catch (_) {
      if (retry) {
        return set(value, retry: false);
      }
      return false;
    }
  }

  String get name => storage.key.name;
}

/// String Persistent Variable Interface
abstract class _StringPersistent extends _PersistentVariable<String> {
  _StringPersistent(super.storage, {required super.defaultValue});

  @override
  String stringToType(String? value, {required String defaultValue}) =>
      value ?? defaultValue;

  @override
  String typeToString(String value) => value;
}

/// Boolean Persistent Variable Interface
abstract class _BooleanPersistent extends _PersistentVariable<bool> {
  _BooleanPersistent(super.storage, {required super.defaultValue});

  void toggleValue() => set(!value);

  @override
  bool stringToType(String? value, {required bool defaultValue}) =>
      value == null ? defaultValue : value == "t";

  @override
  String typeToString(bool value) => value ? "t" : "f";
}

/// Number Persistent Variable Interface
abstract class _NumberPersistent<T extends num> extends _PersistentVariable<T> {
  _NumberPersistent(super.storage, {required super.defaultValue});

  void max(T newValue) => set(math.max(value, newValue));

  @override
  T stringToType(String? value, {required T defaultValue}) {
    try {
      if (value == null) {
        return defaultValue;
      }
      return num.parse(value) as T;
    } catch (_) {
      return defaultValue;
    }
  }

  @override
  String typeToString(T value) => value.toString();
}

typedef FromJsonMap<T> = T Function(Map<String, dynamic> json);
typedef ToJsonMap<T> = Map<String, dynamic> Function(T instance);
typedef FromJson<T> = T Function(String json);
typedef ToJson<T> = String Function(T instance);

/// Json String Persistent Variable Interface
abstract class _JsonPersistent<T> extends _PersistentVariable<T> {
  final FromJson<T> fromJson;
  final ToJson<T> toJson;

  _JsonPersistent(
    super.storage, {
    required super.defaultValue,
    required this.fromJson,
    required this.toJson,
  });

  @override
  T stringToType(String? value, {required T defaultValue}) {
    try {
      if (value == null || value.isEmpty) {
        return defaultValue;
      }
      return fromJson(value);
    } catch (_) {
      return defaultValue;
    }
  }

  @override
  String typeToString(T value) => toJson(value);
}

/// Enum Persistent Variable Interface
abstract class _EnumPersistent<T extends Enum> extends _PersistentVariable<T> {
  final List<T> enumValues;

  _EnumPersistent(
    super.storage, {
    required super.defaultValue,
    required this.enumValues,
  });

  @override
  T stringToType(String? value, {required T defaultValue}) {
    try {
      return enumValues.byName(value ?? defaultValue.name);
    } catch (_) {
      return enumValues.byName(defaultValue.name);
    }
  }

  @override
  String typeToString(T value) => value.name;
}

// Storages Definitions

class MemoryStorage {
  final map = <SharedKeys, String?>{};

  String? get(SharedKeys key) => map[key];

  void save(SharedKeys key, String? value) {
    map[key] = value;
  }
}

/// In Memory Implementation of Storage
class InMemoryStorage extends Storage {
  static final _mem = MemoryStorage();

  InMemoryStorage(super.key);

  @override
  String? get() => _mem.get(key);

  @override
  void save(String value) => _mem.save(key, value);
}

/// ShareDao Implementation of Storage
class SharedDaoStorage extends Storage {
  static final _mem = MemoryStorage();
  static final _sharedDao = GetIt.I.get<SharedDao>();

  SharedDaoStorage(super.key);

  static Future<void> init() async {
    final m = await _sharedDao.toMap();

    for (final e in SharedKeys.values) {
      _mem.save(e, m[e.name]);
    }
  }

  @override
  String? get() => _mem.get(key);

  @override
  void save(String value) => _sharedDao.put(key, value);
}

/// SharedPreference Implementation of Storage
class SharedPreferenceStorage extends Storage {
  static late SharedPreferences _prefs;

  SharedPreferenceStorage(super.key);

  static Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
    } catch (_) {
      await _restoreSharedPreferenceFile();
      _prefs = await SharedPreferences.getInstance();
    }
  }

  static Future<void> _restoreSharedPreferenceFile() async {
    try {
      //delete shared pref file
      if (isWindowsNative || isLinuxNative) {
        final path =
            "${(await getApplicationSupportDirectory()).path}\\shared_preferences.json";
        if (File(path).existsSync()) {
          await (File(path)).delete(recursive: true);
        }
      }
    } catch (_) {}
  }

  @override
  String? get() => _prefs.getString(key.name);

  @override
  Future<void> save(String value) => _prefs.setString(key.name, value);
}

// Persistent Variable Definitions

/// String Persistent Variable
class StringPersistent extends _StringPersistent {
  StringPersistent(super.storage, {required super.defaultValue});

  @override
  Stream<String> get stream => _value.stream.distinct();

  @override
  String get value => _value.value;
}

/// Boolean Persistent Variable
class BooleanPersistent extends _BooleanPersistent {
  BooleanPersistent(super.storage, {required super.defaultValue});

  @override
  Stream<bool> get stream => _value.stream.distinct();

  @override
  bool get value => _value.value;
}

/// Int Persistent Variable
class IntPersistent extends _NumberPersistent<int> {
  IntPersistent(super.storage, {required super.defaultValue});

  @override
  Stream<int> get stream => _value.stream.distinct();

  @override
  int get value => _value.value;
}

/// Double Persistent Variable
class DoublePersistent extends _NumberPersistent<double> {
  DoublePersistent(super.storage, {required super.defaultValue});

  @override
  Stream<double> get stream => _value.stream.distinct();

  @override
  double get value => _value.value;
}

/// Enum Persistent Variable
class EnumPersistent<T extends Enum> extends _EnumPersistent<T> {
  EnumPersistent(
    super.storage, {
    required super.defaultValue,
    required super.enumValues,
  });

  @override
  Stream<T> get stream => _value.stream.distinct();

  @override
  T get value => _value.value;
}

/// Json Persistent Variable
class JsonPersistent<T> extends _JsonPersistent<T> {
  JsonPersistent(
    super.storage, {
    required super.defaultValue,
    required super.fromJson,
    required super.toJson,
  });

  @override
  Stream<T> get stream => _value.stream.distinct();

  @override
  T get value => _value.value;
}

/// Once Persistent
class JsonMapPersistent<T> extends JsonPersistent<T> {
  JsonMapPersistent(
    super.storage, {
    required super.defaultValue,
    required FromJsonMap<T> fromJsonMap,
    required ToJsonMap<T> toJsonMap,
  }) : super(
          fromJson: (json) => fromJsonMap(jsonDecode(json)),
          toJson: (instance) => jsonEncode(toJsonMap(instance)),
        );
}

class ProtoPersistent<T extends $pb.GeneratedMessage>
    extends JsonPersistent<T> {
  ProtoPersistent(
    super.storage, {
    required super.defaultValue,
    required FromJson<T> fromJson,
  }) : super(
          fromJson: fromJson,
          toJson: (instance) => jsonEncode(instance.writeToJson()),
        );
}

/// Once Persistent
class OncePersistent extends JsonMapPersistent<TimeCounter> {
  final int count;
  final Duration period;

  OncePersistent(
    super.storage, {
    required this.count,
    required this.period,
  }) : super(
          fromJsonMap: TimeCounterFromJson,
          toJsonMap: TimeCounterToJson,
          defaultValue: TimeCounter(count: 0, time: 0),
        );

  void reset() => set(TimeCounter(count: 0, time: 0));
}

/// Extension for applying callback function even once persistent object is null
extension OptionalOnce on OncePersistent? {
  void once(void Function() callback) {
    if (this == null) {
      callback();
      return;
    }

    final self = this!;

    final shouldRunOnceAgain = (self.value.count < self.count &&
        clock.now().millisecondsSinceEpoch - self.value.time >
            self.period.inMilliseconds);

    if (shouldRunOnceAgain) {
      callback();

      self.set(
        TimeCounter(
          count: self.value.count + 1,
          time: clock.now().millisecondsSinceEpoch,
        ),
      );
    }
  }
}

class BatteryMonitor {
  final _battery = Battery();

  final batteryLevel = BehaviorSubject.seeded(100);
  final batteryState =
      BehaviorSubject<BatteryState>.seeded(BatteryState.unknown);

  bool get isNotAvailable =>
      batteryState.value == BatteryState.unknown || batteryLevel.value <= 0;

  BatteryMonitor() {
    _battery.onBatteryStateChanged.listen((state) => batteryState.add(state));

    Timer.periodic(
      const Duration(seconds: 10),
      (_) async => batteryLevel.add(await _battery.batteryLevel),
    );
  }
}

class PerformanceMonitor {
  static final batteryMonitor = BatteryMonitor();

  static final powerSaverBatteryLevel = IntPersistent(
    SharedKeys.POWER_SAVE_BATTERY_LEVEL.inSharedDaoStorage(),
    defaultValue: 0,
  );

  static final performanceModeSetting = EnumPersistent<PerformanceMode>(
    SharedKeys.PERFORMANCE_MODE.inSharedDaoStorage(),
    defaultValue: _defaultPerformanceMode,
    enumValues: PerformanceMode.values,
  );

  static final performanceProfile = MergeStream([
    performanceModeSetting.stream,
    powerSaverBatteryLevel.stream,
    batteryMonitor.batteryLevel
  ])
      .map((event) {
        if (!_batteryLevelIsOk) {
          if (performanceModeSetting.value.level <
              PerformanceMode.POWER_SAVER.level) {
            return performanceModeSetting.value;
          } else {
            return PerformanceMode.POWER_SAVER;
          }
        } else {
          return performanceModeSetting.value;
        }
      })
      .distinct()
      .shareValueSeeded(_defaultPerformanceMode);

  static bool get isLessThanBalancedMode =>
      performanceModeSetting.value.level <= PerformanceMode.POWER_SAVER.level;

  static bool get _batteryLevelIsOk =>
      batteryMonitor.batteryLevel.value >= powerSaverBatteryLevel.value;

  static const _defaultPerformanceMode =
      isWeb ? PerformanceMode.POWER_SAVER : PerformanceMode.BALANCED;
}

class PerformanceBooleanPersistent extends _BooleanPersistent {
  final PerformanceMode availableLevel;
  bool isReverse = false;

  PerformanceBooleanPersistent(
    super.storage,
    this.availableLevel, {
    super.defaultValue = true,
    this.isReverse = false,
  }) {
    PerformanceMonitor.performanceProfile.listen((event) {
      _value.add(_value.value);
    });
  }

  bool get enabled => isReverse
      ? PerformanceMonitor.performanceProfile.value.level <=
          availableLevel.level
      : PerformanceMonitor.performanceProfile.value.level >=
          availableLevel.level;

  @override
  Stream<bool> get stream => _value.map((v) => enabled && v).distinct();

  @override
  bool get value =>
      isReverse ? (enabled || _value.value) : enabled && _value.value;
}

enum PerformanceMode {
  /// No animation, no background, no glass effect, no animated avatars,
  /// no emoji substitution, no link preview and markdown and reduce some features
  LOW("Low", "performance_low", 0),

  /// No animation, no animated emojis, no animated avatars,
  /// no glass effect and reduce some features
  POWER_SAVER("Power saver", "performance_power_saver", 1),

  /// No animated emojis repeats, no repeat animated avatars
  /// and reduce some features
  BALANCED("Balanced", "performance_balanced", 2),

  /// Repeating animated emojis and animated avatars
  HIGH("High", "performance_high", 3),

  /// Render animated emojis everywhere and all settings available
  ULTRA("Ultra", "performance_ultra", 4);

  final String buttonName;
  final String i18nKey;
  final int level;

  const PerformanceMode(this.buttonName, this.i18nKey, this.level);
}

enum VideoCallQuality {
  /// this case is low quality video , 320 x 240 x 20 frame
  /// less internet usage
  LOW("Low", "low_quality", 0),

  /// this case is medium video quality 480 x 360 x 30 frame
  /// more internet usage
  MEDIUM("Medium", "medium_quality", 1),

  /// this case is high video quality 640 x 480 x 30 frame
  /// more internet usage
  HIGH("High", "high_quality", 3),

  /// this case is high video quality 720 x 540 x 30 frame
  /// more internet usage
  ULTRA("ULTRA", "ultra_quality", 4);

  final String buttonName;
  final String i18nKey;
  final int level;

  const VideoCallQuality(this.buttonName, this.i18nKey, this.level);
}

extension SharedKeysExtention on SharedKeys {
  SharedDaoStorage inSharedDaoStorage() => SharedDaoStorage(this);

  InMemoryStorage inMemoryStorage() => InMemoryStorage(this);

  SharedPreferenceStorage inSharedPreferenceStorage() =>
      SharedPreferenceStorage(this);

  // Syntax Sugars
  BooleanPersistent sharedDaoBoolean({required bool defaultValue}) =>
      BooleanPersistent(SharedDaoStorage(this), defaultValue: defaultValue);
}
