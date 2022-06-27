import 'dart:convert';

import 'package:deliver/box/dao/shared_dao.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/language.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';

class I18N {
  final _sharedDao = GetIt.I.get<SharedDao>();

  final _language = BehaviorSubject.seeded(defaultLanguage);

  Map<String, String>? _values;

  I18N() {
    _loadLanguageResource(defaultLanguage);
    _sharedDao
        .getStream(
          SHARED_DAO_LANGUAGE,
          defaultValue: defaultLanguage.countryCode,
        )
        .map((code) {
          if (code != null && code.contains(farsi.countryCode)) {
            return farsi;
          }
          return english;
        })
        .distinct()
        .listen((lang) async {
          await _loadLanguageResource(lang);
          _language.add(lang);
        });
  }

  bool isRtl() => _language.value.countryCode.contains(farsi.countryCode);

  Future<void> _loadLanguageResource(Language language) async {
    final jsonValues =
        await rootBundle.loadString('lib/lang/${language.languageCode}.json');

    final Map<String, dynamic> mappedJson = json.decode(jsonValues);

    _values = mappedJson.map((key, value) => MapEntry(key, value.toString()));
  }

  bool get isPersian => _language.value.countryCode.contains(farsi.countryCode);

  Stream get localeStream => _language.distinct().map((e) => e.locale);

  Locale get locale => _language.value.locale;

  String get(String key) {
    return _values != null && _values!.isNotEmpty
        ? _values![key] ?? (kDebugMode ? "____NO_TRANSLATION_{$key}___" : "")
        : key.replaceAll("_", " ");
  }

  String verb(String key, {bool isFirstPerson = false}) {
    return get(key) +
        (isFirstPerson ? (_values!["_first_person_verb_extra_"] ?? "") : "");
  }

  void changeLanguage(Language language) {
    _sharedDao.put(SHARED_DAO_LANGUAGE, language.countryCode);
  }

  @Deprecated("Use GetIt version instead. final _i18n = GetIt.I.get<I18N>();")
  static I18N? of(BuildContext context) {
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
    return _i18n;
  }

  @override
  bool shouldReload(_MyLocalizationDelegate old) => false;
}
