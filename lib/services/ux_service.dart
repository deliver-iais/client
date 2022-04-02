import 'dart:ui';

import 'package:deliver/box/dao/shared_dao.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver/theme/extra_theme.dart';
import 'package:deliver/theme/theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:rxdart/rxdart.dart';

class DeliverLogFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    return event.level != Level.nothing && event.level.index >= level!.index;
  }
}

class LogLevelHelper {
  static String levelToString(Level level) {
    switch (level) {
      case Level.debug:
        return "DEBUG";
      case Level.verbose:
        return "VERBOSE";
      case Level.error:
        return "ERROR";
      case Level.info:
        return "INFO";
      case Level.warning:
        return "WARNING";
      case Level.wtf:
        return "WTF";
      case Level.nothing:
        return "NOTHING";
    }
  }

  static Level stringToLevel(String level) {
    switch (level) {
      case "DEBUG":
        return Level.debug;
      case "VERBOSE":
        return Level.verbose;
      case "ERROR":
        return Level.error;
      case "INFO":
        return Level.info;
      case "WARNING":
        return Level.warning;
      case "WTF":
        return Level.wtf;
      case "NOTHING":
        return Level.nothing;
      default:
        return Level.debug;
    }
  }

  static List<String> levels() =>
      ["DEBUG", "VERBOSE", "ERROR", "INFO", "WARNING", "WTF", "NOTHING"];
}

class UxService {
  static bool isDeveloperMode = false;

  final _sharedDao = GetIt.I.get<SharedDao>();

  final _themeIndex = BehaviorSubject.seeded(0);
  final _themeIsDark = BehaviorSubject.seeded(false);

  final _isAllNotificationDisabled = BehaviorSubject.seeded(false);
  final _isAutoNightModeEnable = BehaviorSubject.seeded(true);
  final _sendByEnter = BehaviorSubject.seeded(isDesktop);

  UxService() {
    _sharedDao
        .getStream(SHARED_DAO_LOG_LEVEL,
            defaultValue: kDebugMode ? "INFO" : "NOTHING")
        .map((event) => LogLevelHelper.stringToLevel(event!))
        .listen((level) => GetIt.I.get<DeliverLogFilter>().level = level);

    _sharedDao
        .getBooleanStream(SHARED_DAO_IS_AUTO_NIGHT_MODE_ENABLE,
            defaultValue: true)
        .distinct()
        .listen((isEnable) => _isAutoNightModeEnable.add(isEnable));

    _sharedDao
        .getBooleanStream(SHARED_DAO_IS_ALL_NOTIFICATION_DISABLED,
            defaultValue: false)
        .distinct()
        .listen((isDisabled) => _isAllNotificationDisabled.add(isDisabled));

    _sharedDao
        .getBooleanStream(SHARED_DAO_SEND_BY_ENTER, defaultValue: isDesktop)
        .distinct()
        .listen((sbn) => _sendByEnter.add(sbn));
    _sharedDao.get(SHARED_DAO_THEME).then((event) {
      if (event != null) {
        if (event.contains(DarkThemeName)) {
          _themeIsDark.add(true);
        } else {
          _themeIsDark.add(false);
        }
      } else if (isAutoNightModeEnable &&
          window.platformBrightness == Brightness.dark) {
        _themeIsDark.add(true);
      }
    });
    _sharedDao.get(SHARED_DAO_THEME_COLOR).then((event) {
      if (event != null) {
        try {
          final colorIndex = int.parse(event);
          _themeIndex.add(colorIndex);
        } catch (_) {}
      }
    });
  }

  Stream get themeIndexStream =>
      _themeIndex.stream.distinct().map((event) => event);

  Stream get themeIsDarkStream =>
      _themeIsDark.stream.distinct().map((event) => event);

  ThemeData get theme =>
      getThemeScheme(_themeIndex.value).theme(_themeIsDark.value);

  ExtraThemeData get extraTheme =>
      getThemeScheme(_themeIndex.value).extraTheme(_themeIsDark.value);

  bool get themeIsDark => _themeIsDark.value;

  int get themeIndex => _themeIndex.value;

  bool get sendByEnter => isDesktop ? _sendByEnter.value : false;

  bool get isAllNotificationDisabled => _isAllNotificationDisabled.value;

  bool get isAutoNightModeEnable => _isAutoNightModeEnable.value;

  void toggleThemeLightingMode() {
    _sharedDao.putBoolean(SHARED_DAO_IS_AUTO_NIGHT_MODE_ENABLE, false);
    _isAutoNightModeEnable.add(false);
    if (_themeIsDark.value) {
      toggleThemeToLightMode();
    } else {
      toggleThemeToDarkMode();
    }
  }

  void toggleThemeToLightMode() {
    SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(systemNavigationBarColor: Colors.white));
    _sharedDao.put(SHARED_DAO_THEME, LightThemeName);
    _themeIsDark.add(false);
  }

  void toggleThemeToDarkMode() {
    SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(systemNavigationBarColor: Colors.black45));
    _sharedDao.put(SHARED_DAO_THEME, DarkThemeName);
    _themeIsDark.add(true);
  }

  void selectTheme(int index) {
    _sharedDao.put(SHARED_DAO_THEME_COLOR, index.toString());
    _themeIndex.add(index);
  }

  void toggleSendByEnter() {
    if (sendByEnter == false) {
      _sharedDao.putBoolean(SHARED_DAO_SEND_BY_ENTER, true);
    } else {
      _sharedDao.putBoolean(SHARED_DAO_SEND_BY_ENTER, false);
    }
  }

  void toggleIsAllNotificationDisabled() {
    _sharedDao.putBoolean(
        SHARED_DAO_IS_ALL_NOTIFICATION_DISABLED, !isAllNotificationDisabled);
  }

  void toggleIsAutoNightMode() {
    _sharedDao.putBoolean(
        SHARED_DAO_IS_AUTO_NIGHT_MODE_ENABLE, !isAutoNightModeEnable);
  }

  void changeLogLevel(String level) {
    _sharedDao.put(SHARED_DAO_LOG_LEVEL, level);
  }

  // TODO ???
  final Map _tabIndexMap = <String, int>{};

  int? getTabIndex(String fileId) {
    return _tabIndexMap[fileId];
  }

  void setTabIndex(String fileId, int index) {
    _tabIndexMap[fileId] = index;
  }
}
