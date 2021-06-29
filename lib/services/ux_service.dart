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

  get localeStream => _sharedDao.getStream("lang").map((event) {
        if (event != null) {
          var code = event;
          if (code.contains(Farsi.countryCode)) {
            _language.add(Farsi);
          } else if (code.contains(English.countryCode)) {
            _language.add(English);
          }
        }
      });

  get themeStream => _sharedDao.getStream("theme").map((event) {
        if (event != null) {
          if (event.contains("Dark")) {
            _theme.add(DarkTheme);
            _extraTheme.add(DarkExtraTheme);
          } else {
            _theme.add(LightTheme);
            _extraTheme.add(LightExtraTheme);
          }
        }
      });

  get isPersian => _language.value.countryCode.contains(Farsi.countryCode);

  get theme => _theme.value;

  get extraTheme => _extraTheme.value;

  get locale =>
      Locale(_language.value.languageCode, _language.value.countryCode);

  toggleTheme() {
    if (theme == DarkTheme) {
      _sharedDao.put(SHARED_DAO_THEME, "Light");
      _theme.add(LightTheme);
      _extraTheme.add(LightExtraTheme);
    } else {
      _sharedDao.put(SHARED_DAO_THEME, "Dark");
      _theme.add(DarkTheme);
      _extraTheme.add(DarkExtraTheme);
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
