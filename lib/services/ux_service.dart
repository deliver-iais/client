import 'package:deliver_flutter/box/dao/shared_dao.dart';
import 'package:deliver_flutter/shared/constants.dart';
import 'package:deliver_flutter/shared/language.dart';
import 'package:deliver_flutter/theme/constants.dart';
import 'package:deliver_flutter/theme/dark.dart';
import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:deliver_flutter/theme/light.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:rxdart/rxdart.dart';

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

  BehaviorSubject<ThemeData> _theme = BehaviorSubject.seeded(LightTheme);

  BehaviorSubject<ExtraThemeData> _extraTheme =
      BehaviorSubject.seeded(LightExtraTheme);

  BehaviorSubject<Language> _language = BehaviorSubject.seeded(DefaultLanguage);

  BehaviorSubject<String> _sendByEnter =
      BehaviorSubject.seeded(isDesktop() ? SEND_BY_ENTER : SEND_BY_SHIFT_ENTER);

  UxService() {
    _sharedDao
        .getStream(SHARED_DAO_LOG_LEVEL, defaultValue: "DEBUG")
        .map((event) => LogLevelHelper.stringToLevel(event))
        .listen((level) => Logger.level = level);
  }

  // TODO ???
  Map tabIndexMap = new Map<String, int>();

  get localeStream => _sharedDao.getStream(SHARED_DAO_LANGUAGE).map((event) {
        if (event != null) {
          var code = event;
          if (code.contains(Farsi.countryCode)) {
            _language.add(Farsi);
          } else if (code.contains(English.countryCode)) {
            _language.add(English);
          }
        }
      });

  get themeStream => _sharedDao.getStream(SHARED_DAO_THEME).map((event) {
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

  get isPersian => _language.value.countryCode.contains(Farsi.countryCode);

  get theme => _theme.value;

  get sendByEnter => isDesktop() ? _sendByEnter.value : SEND_BY_SHIFT_ENTER;

  get extraTheme => _extraTheme.value;

  get locale =>
      Locale(_language.value.languageCode, _language.value.countryCode);

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
    if (sendByEnter == SEND_BY_SHIFT_ENTER) {
      _sharedDao.put(SHARED_DAO_SEND_BY_ENTER, SEND_BY_ENTER);
      _sendByEnter.add(SEND_BY_ENTER);
    } else {
      _sharedDao.put(SHARED_DAO_SEND_BY_ENTER, SEND_BY_SHIFT_ENTER);
      _sendByEnter.add(SEND_BY_SHIFT_ENTER);
    }
  }

  changeLogLevel(String level) {
    _sharedDao.put(SHARED_DAO_LOG_LEVEL, level);
  }

  changeLanguage(Language language) {
    _sharedDao.put(SHARED_DAO_LANGUAGE, language.countryCode);
    _language.add(language);
  }

  int getTabIndex(String fileId) {
    return tabIndexMap[fileId];
  }

  setTabIndex(String fileId, int index) {
    tabIndexMap[fileId] = index;
  }
}
