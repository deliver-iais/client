import 'package:deliver_flutter/shared/language.dart';
import 'package:deliver_flutter/theme/dark.dart';
import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:deliver_flutter/theme/light.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class UxService {
  BehaviorSubject<ThemeData> _theme = BehaviorSubject.seeded(DarkTheme);
  BehaviorSubject<ExtraThemeData> _extraTheme = BehaviorSubject.seeded(
      DarkExtraTheme);

  BehaviorSubject<Language> _language = BehaviorSubject.seeded(DefaultLanguage);

  get themeStream => _theme.stream;

  get extraThemeStream => _extraTheme.stream;

  get localeStream =>
      _language.stream
          .map((lang) => Locale(lang.languageCode, lang.countryCode));

  get theme => _theme.value;

  get extraTheme => _extraTheme.value;

  get locale =>
      Locale(_language.value.languageCode, _language.value.countryCode);

  toggleTheme() {
    if (theme == DarkTheme) {
      _theme.add(LightTheme);
      _extraTheme.add(LightExtraTheme);
    } else {
      _theme.add(DarkTheme);
      _extraTheme.add(DarkExtraTheme);
    }
  }

  changeLanguage(Language language) {
    _language.add(language);
  }
}
