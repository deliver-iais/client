import 'dart:ui';

const english = Language(1, 'English', '🇺🇸', "en", "US");
const farsi = Language(1, 'فارسی', '🇮🇷', "fa", "IR");
const defaultLanguage = english;

class Language {
  final int id;
  final String name;
  final String flag;
  final String languageCode;
  final String countryCode;

  const Language(
    this.id,
    this.name,
    this.flag,
    this.languageCode,
    this.countryCode,
  );

  static List<Language> languageList() {
    return <Language>[farsi, english];
  }

  Locale get locale => Locale(languageCode, countryCode);
}

extension LanguageOnLocale on Locale {
  Language language() {
    final index = Language.languageList()
        .indexWhere((element) => element.languageCode == languageCode);
    if (index > -1) {
      return Language.languageList()[index];
    }
    return english;
  }
}
