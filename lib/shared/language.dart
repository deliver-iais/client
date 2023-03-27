import 'dart:ui';

import 'package:deliver/shared/changelog.dart';

enum Language {
  FARSI(
    languageCode: "fa",
    languageName: 'فارسی',
    countryCode: "IR",
    isRtl: true,
    changelogs: FARSI_FEATURE_LIST,
  ),
  ENGLISH(
    languageCode: "en",
    languageName: "English",
    countryCode: "US",
    isRtl: false,
    changelogs: ENGLISH_FEATURE_LIST,
  ),
  ARABIC(
    languageCode: "ar",
    languageName: "عربی - BETA",
    countryCode: "SA",
    isRtl: true,
    changelogs: ARABIC_FEATURE_LIST,
  );

  static const defaultLanguage = Language.FARSI;

  final String languageCode;
  final String languageName;
  final String countryCode;
  final bool isRtl;
  final List<String> changelogs;

  const Language({
    required this.languageCode,
    required this.languageName,
    required this.countryCode,
    required this.isRtl,
    required this.changelogs,
  });

  Locale get locale => Locale(languageCode, countryCode);
}
