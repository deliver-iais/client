import 'package:deliver_flutter/box/dao/shared_dao.dart';
import 'package:deliver_flutter/shared/constants.dart';
import 'package:deliver_flutter/theme/constants.dart';
import 'package:deliver_flutter/theme/dark.dart';
import 'package:deliver_flutter/theme/extra_theme.dart';
import 'package:deliver_flutter/theme/light.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:rxdart/rxdart.dart';

class DeliverLogFilter extends LogFilter {
  @override
  set level(Level _level) {
    super.level = _level;
  }

  @override
  bool shouldLog(LogEvent event) {
    return event.level != Level.nothing && event.level.index >= level.index;
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
      default:
        return "DEBUG";
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
  final _sharedDao = GetIt.I.get<SharedDao>();

  final _theme = BehaviorSubject.seeded(LightTheme);
  final _extraTheme = BehaviorSubject.seeded(LightExtraTheme);
  final _isAllNotificationDisabled = BehaviorSubject.seeded(false);
  final _sendByEnter = BehaviorSubject.seeded(isDesktop());

  UxService() {
    _sharedDao
        .getStream(SHARED_DAO_LOG_LEVEL,
            defaultValue: kDebugMode ? "INFO" : "NOTHING")
        .map((event) => LogLevelHelper.stringToLevel(event))
        .listen((level) => GetIt.I.get<DeliverLogFilter>().level = level);

    _sharedDao
        .getBooleanStream(SHARED_DAO_IS_ALL_NOTIFICATION_DISABLED,
            defaultValue: false)
        .distinct()
        .listen((isDisabled) => _isAllNotificationDisabled.add(isDisabled));

    _sharedDao
        .getBooleanStream(SHARED_DAO_SEND_BY_ENTER, defaultValue: isDesktop())
        .distinct()
        .listen((sbn) => _sendByEnter.add(sbn));
  }

  Stream get themeStream => _sharedDao.getStream(SHARED_DAO_THEME).map((event) {
        if (event != null) {
          if (event.contains(DarkThemeName)) {
            _theme.add(DarkTheme);
            _extraTheme.add(DarkExtraTheme);
          } else if (event.contains(LightThemeName)) {
            _theme.add(LightTheme);
            _extraTheme.add(LightExtraTheme);
          } else {
            _theme.add(LightTheme);
            _extraTheme.add(LightExtraTheme);
          }
        }
      });



  ThemeData get theme => _theme.value;

  ExtraThemeData get extraTheme => _extraTheme.value;

  bool get sendByEnter => isDesktop() ? _sendByEnter.value : false;

  bool get isAllNotificationDisabled => _isAllNotificationDisabled.value;

  toggleTheme() {
    if (theme == DarkTheme) {
      _sharedDao.put(SHARED_DAO_THEME, LightThemeName);
      _theme.add(LightTheme);
      _extraTheme.add(LightExtraTheme);
    } else {
      _sharedDao.put(SHARED_DAO_THEME, DarkThemeName);
      _theme.add(DarkTheme);
      _extraTheme.add(DarkExtraTheme);
    }
  }

  toggleSendByEnter() {
    if (sendByEnter == false) {
      _sharedDao.putBoolean(SHARED_DAO_SEND_BY_ENTER, true);
    } else {
      _sharedDao.putBoolean(SHARED_DAO_SEND_BY_ENTER, false);
    }
  }

  toggleIsAllNotificationDisabled() {
    _sharedDao.putBoolean(
        SHARED_DAO_IS_ALL_NOTIFICATION_DISABLED, !isAllNotificationDisabled);
  }

  changeLogLevel(String level) {
    _sharedDao.put(SHARED_DAO_LOG_LEVEL, level);
  }

  // TODO ???
  Map _tabIndexMap = new Map<String, int>();

  int getTabIndex(String fileId) {
    return _tabIndexMap[fileId];
  }

  setTabIndex(String fileId, int index) {
    _tabIndexMap[fileId] = index;
  }
}
