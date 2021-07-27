import 'dart:convert';

import 'package:deliver_flutter/box/dao/shared_dao.dart';
import 'package:deliver_flutter/shared/constants.dart';
import 'package:deliver_flutter/shared/language.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';

class I18N {
  final _sharedDao = GetIt.I.get<SharedDao>();

  final _language = BehaviorSubject.seeded(DefaultLanguage);

  Map<String, String> _values;

  Future load(Locale locale) async {
    String jsonValues =
        await rootBundle.loadString('lib/lang/${locale.languageCode}.json');

    Map<String, dynamic> mappedJson = json.decode(jsonValues);

    _values = mappedJson.map((key, value) => MapEntry(key, value.toString()));
  }

  String get(String key) {
    return _values[key];
  }

  bool get isPersian => _language.value.countryCode.contains(Farsi.countryCode);

  Stream get localeStream =>
      _sharedDao.getStream(SHARED_DAO_LANGUAGE).map((event) {
        if (event != null) {
          var code = event;
          if (code.contains(Farsi.countryCode)) {
            _language.add(Farsi);
          } else if (code.contains(English.countryCode)) {
            _language.add(English);
          }
        }
      });

  Locale get locale =>
      Locale(_language.value.languageCode, _language.value.countryCode);

  changeLanguage(Language language) {
    _sharedDao.put(SHARED_DAO_LANGUAGE, language.countryCode);
    _language.add(language);
  }

  static I18N of(BuildContext context) {
    return Localizations.of<I18N>(context, I18N);
  }

  static LocalizationsDelegate<I18N> delegate = _MyLocalizationDelegate();
}

class _MyLocalizationDelegate extends LocalizationsDelegate<I18N> {
  final _i18n = GetIt.I.get<I18N>();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'fa'].contains(locale.languageCode);
  }

  @override
  Future<I18N> load(Locale locale) async {
    await _i18n.load(locale);
    return _i18n;
  }

  @override
  bool shouldReload(_MyLocalizationDelegate old) => false;
}
