import 'package:deliver_flutter/db/dao/SharedPreferencesDao.dart';
import 'package:deliver_flutter/shared/language.dart';
import 'package:deliver_flutter/theme/dark.dart';
import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:deliver_flutter/theme/light.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';

class UxService {
  Map tabIndexMap = new Map<String, int>();
  SharedPreferencesDao _sharedPrefs = GetIt.I.get<SharedPreferencesDao>();

  BehaviorSubject<ThemeData> _theme = BehaviorSubject.seeded(LightTheme);
  BehaviorSubject<ExtraThemeData> _extraTheme =
      BehaviorSubject.seeded(LightExtraTheme);

  BehaviorSubject<Language> _language = BehaviorSubject.seeded(DefaultLanguage);

  get localeStream => _sharedPrefs.watch("lang").map((event) {
        if (event != null) {
          var code = event.value;
          if (code.contains(Farsi.countryCode)) {
            _language.add(Farsi);
          } else if (code.contains(English.countryCode)) {
            _language.add(English);
          }
        }
      });

  get themeStream => _sharedPrefs.watch("theme").map((event) {
        if (event != null) {
          if (event.value.contains("Dark")) {
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
      _sharedPrefs.set("theme", "Light");
      _theme.add(LightTheme);
      _extraTheme.add(LightExtraTheme);
    } else {
      _sharedPrefs.set("theme", "Dark");
      _theme.add(DarkTheme);
      _extraTheme.add(DarkExtraTheme);
    }
  }

  changeLanguage(Language language) {
    _sharedPrefs.set("lang", language.countryCode);
    _language.add(language);
  }

  int getTabIndex(String fileId) {
    return tabIndexMap[fileId];
  }

  setTabIndex(String fileId, int index) {
    tabIndexMap[fileId] = index;
  }
}
