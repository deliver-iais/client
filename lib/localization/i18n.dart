import 'dart:convert';

import 'package:deliver/services/settings.dart';
import 'package:deliver/shared/language.dart';
import 'package:deliver/shared/methods/is_persian.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';

class I18N {
  Map<String, String>? _values;

  I18N() {
    _loadLanguageResource(Language.defaultLanguage);

    settings.language.stream.listen((lang) async {
      await _loadLanguageResource(lang);
    });
  }

  bool get isRtl => settings.language.value.isRtl;

  List<String> get changelogs => settings.language.value.changelogs;

  Future<void> _loadLanguageResource(Language language) async {
    final jsonValues =
        await rootBundle.loadString('lib/lang/${language.languageCode}.json');

    final Map<String, dynamic> mappedJson = json.decode(jsonValues);

    _values = mappedJson.map((key, value) => MapEntry(key, value.toString()));
  }

  bool get isPersian =>
      settings.language.value.countryCode.contains(Language.FARSI.countryCode);

  TextDirection get defaultTextDirection =>
      isRtl ? TextDirection.rtl : TextDirection.ltr;
  TextDirection get reverseDefaultTextDirection =>
      isRtl ? TextDirection.ltr : TextDirection.rtl;

  Stream get localeStream => settings.language.stream.map((e) => e.locale);

  Locale get locale => settings.language.value.locale;

  Language get language => settings.language.value;

  String get(String key) {
    return _values != null && _values!.isNotEmpty
        ? _values![key] ?? (kDebugMode ? "____NO_TRANSLATION_{$key}___" : "")
        : key.replaceAll("_", " ");
  }

  String operator [](String key) => get(key);

  String verb(
    String key, {
    bool isFirstPerson = false,
    bool needParticleSuffixed = false,
  }) {
    return (needParticleSuffixed
            ? (_values!["_particle_suffixed_"] ?? "")
            : "") +
        get(key) +
        (isFirstPerson ? (_values!["_first_person_verb_extra_"] ?? "") : "");
  }

  void changeLanguage(Language language) {
    settings.language.set(language);
  }

  TextDirection getDirection(String v) {
    final string = v.trim();
    if (string.isEmpty) {
      return TextDirection.ltr;
    }
    // TODO(any): add arabic detection
    if (string.isPersian()) {
      return TextDirection.rtl;
    }
    return TextDirection.ltr;
  }

  static final LocalizationsDelegate<I18N> delegate = _MyLocalizationDelegate();
}

class _MyLocalizationDelegate extends LocalizationsDelegate<I18N> {
  final _i18n = GetIt.I.get<I18N>();

  @override
  bool isSupported(Locale locale) {
    return Language.values
        .map((e) => e.languageCode)
        .contains(locale.languageCode);
  }

  @override
  Future<I18N> load(Locale locale) async {
    return _i18n;
  }

  @override
  bool shouldReload(_MyLocalizationDelegate old) => false;
}
