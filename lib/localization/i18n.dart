import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';

class I18N {
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
