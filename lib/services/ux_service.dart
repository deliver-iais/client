import 'package:deliver_flutter/box/dao/shared_dao.dart';
import 'package:deliver_flutter/shared/constants.dart';
import 'package:deliver_flutter/shared/language.dart';
import 'package:deliver_flutter/theme/dark.dart';
import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:deliver_flutter/theme/light.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';

class UxService {
  Map tabIndexMap = new Map<String, int>();
  final _sharedDao = GetIt.I.get<SharedDao>();

  BehaviorSubject<ThemeData> _theme = BehaviorSubject.seeded(LightTheme);

  BehaviorSubject<ExtraThemeData> _extraTheme =
      BehaviorSubject.seeded(LightExtraTheme);

  BehaviorSubject<Language> _language = BehaviorSubject.seeded(DefaultLanguage);

  BehaviorSubject<String> _sendByEnter = BehaviorSubject.seeded(SEND_BY_ENTER);

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

  get sendByEnterStream =>
      _sharedDao.getStream(SHARED_DAO_SEND_BY_ENTER).map((event) {
        if (event != null) {
          var code = event;
          if (code.contains(SEND_BY_SHIFT_ENTER)) {
            _sendByEnter.add(SEND_BY_SHIFT_ENTER);
          } else {
            _sendByEnter.add(SEND_BY_ENTER);
          }
        }
      });

  get isPersian => _language.value.countryCode.contains(Farsi.countryCode);

  get theme => _theme.value;

  get sendByEnter => _sendByEnter.value;

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
