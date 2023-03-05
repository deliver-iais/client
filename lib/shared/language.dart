import 'dart:ui';

import 'package:deliver/shared/changelog.dart';

const farsi = Language(
  languageCode: "fa",
  name: 'فارسی',
  countryCode: "IR",
  isRtl: true,
  changelogs: FARSI_FEATURE_LIST,
);

const english = Language(
  languageCode: "en",
  name: "English",
  countryCode: "US",
  isRtl: false,
  changelogs: ENGLISH_FEATURE_LIST,
);

const arabic = Language(
  languageCode: "ar",
  name: "عربی - BETA",
  countryCode: "SA",
  isRtl: true,
  changelogs: ARABIC_FEATURE_LIST,
);
const defaultLanguage = farsi;
const supportedLanguages = <Language>[farsi, english, arabic];

class Language {
  final String languageCode;
  final String name;
  final String countryCode;
  final bool isRtl;
  final List<String> changelogs;

  const Language({
    required this.languageCode,
    required this.name,
    required this.countryCode,
    required this.isRtl,
    required this.changelogs,
  });

  Locale get locale => Locale(languageCode, countryCode);
}
