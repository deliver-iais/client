import 'dart:ui';

const English = const Language(1, 'English', '🇺🇸', "en", "US");
const Farsi = const Language(1, 'فارسی', '🇮🇷', "fa", "IR");
const DefaultLanguage = Farsi;

class Language {
  final int id;
  final String name;
  final String flag;
  final String languageCode;
  final String countryCode;

  const Language(
      this.id, this.name, this.flag, this.languageCode, this.countryCode);

  static List<Language> languageList() {
    return <Language>[Farsi, English];
  }
}

extension LanguageOnLocale on Locale {
  Language language() {
    var index = Language.languageList()
        .indexWhere((element) => element.languageCode == this.languageCode);
    if (index > -1) {
      return Language.languageList()[index];
    }
    return English;
  }
}
