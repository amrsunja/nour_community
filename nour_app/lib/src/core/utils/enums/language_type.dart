enum LanguageType {
  en,
  fr,
  ar;

  static LanguageType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'en':
        return en;
      case 'fr':
        return fr;
      case 'ar':
        return ar;
      default:
        return en;
    }
  }

  String get dbValue => name;
}
