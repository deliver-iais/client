import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class I18N {
  final Locale locale;

  I18N(this.locale);

  static I18N of(BuildContext context) {
    return Localizations.of<I18N>(context, I18N);
  }

  Map<String, String> _values;

  Future load() async {
    String jsonValues =
        await rootBundle.loadString('lib/lang/${locale.languageCode}.json');

    Map<String, dynamic> mappedJson = json.decode(jsonValues);

    _values = mappedJson.map((key, value) => MapEntry(key, value.toString()));
  }

  String get(String key) {
    return _values[key];
  }

  static const LocalizationsDelegate<I18N> delegate = _MyLocalizationDelegate();
}

class _MyLocalizationDelegate extends LocalizationsDelegate<I18N> {

  const _MyLocalizationDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'fa'].contains(locale.languageCode);
  }

  @override
  Future<I18N> load(Locale locale) async {
    I18N localization = new I18N(locale);
    await localization.load();
    return localization;
  }

  @override
  bool shouldReload(_MyLocalizationDelegate old) => false;
}
