import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLocalization {
  final Locale locale;

  AppLocalization(this.locale);

  static AppLocalization of(BuildContext context) {
    return Localizations.of<AppLocalization>(context, AppLocalization);
  }

  Map<String, String> _values;

  Future load() async {
    String jsonValues =
        await rootBundle.loadString('lib/lang/${locale.languageCode}.json');

    Map<String, dynamic> mappedJson = json.decode(jsonValues);

    _values = mappedJson.map((key, value) => MapEntry(key, value.toString()));
  }

  String getTraslateValue(String key) {
    return _values[key];
  }

  static const LocalizationsDelegate<AppLocalization> delegate = _MyLocalizatioinDalagate();
}

class _MyLocalizatioinDalagate extends LocalizationsDelegate<AppLocalization> {

  const _MyLocalizatioinDalagate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'fa'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalization> load(Locale locale) async {
    AppLocalization localization = new AppLocalization(locale);
    await localization.load();
    return localization;
  }

  @override
  bool shouldReload(_MyLocalizatioinDalagate old) => false;
}
