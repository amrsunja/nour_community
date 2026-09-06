/// Countries offered in the mosque onboarding ("Choose your country").
/// ISO-3166 alpha-2 code, English name, flag emoji. Europe first (Nour's
/// launch markets), then the rest alphabetically.
class Country {
  const Country(this.code, this.name, this.flag);
  final String code;
  final String name;
  final String flag;
}

const List<Country> kCountries = [
  Country('FR', 'France', '🇫🇷'),
  Country('BE', 'Belgium', '🇧🇪'),
  Country('SE', 'Sweden', '🇸🇪'),
  Country('NL', 'Netherlands', '🇳🇱'),
  Country('ES', 'Spain', '🇪🇸'),
  Country('DE', 'Germany', '🇩🇪'),
  Country('CH', 'Switzerland', '🇨🇭'),
  Country('LU', 'Luxembourg', '🇱🇺'),
  Country('IT', 'Italy', '🇮🇹'),
  Country('GB', 'United Kingdom', '🇬🇧'),
  Country('IE', 'Ireland', '🇮🇪'),
  Country('PT', 'Portugal', '🇵🇹'),
  Country('AT', 'Austria', '🇦🇹'),
  Country('DK', 'Denmark', '🇩🇰'),
  Country('NO', 'Norway', '🇳🇴'),
  Country('FI', 'Finland', '🇫🇮'),
  Country('PL', 'Poland', '🇵🇱'),
  Country('CA', 'Canada', '🇨🇦'),
  Country('US', 'United States', '🇺🇸'),
  Country('MA', 'Morocco', '🇲🇦'),
  Country('DZ', 'Algeria', '🇩🇿'),
  Country('TN', 'Tunisia', '🇹🇳'),
  Country('TR', 'Türkiye', '🇹🇷'),
  Country('SA', 'Saudi Arabia', '🇸🇦'),
  Country('AE', 'United Arab Emirates', '🇦🇪'),
  Country('QA', 'Qatar', '🇶🇦'),
  Country('EG', 'Egypt', '🇪🇬'),
  Country('SN', 'Senegal', '🇸🇳'),
  Country('ML', 'Mali', '🇲🇱'),
  Country('ID', 'Indonesia', '🇮🇩'),
  Country('MY', 'Malaysia', '🇲🇾'),
  Country('PK', 'Pakistan', '🇵🇰'),
  Country('BD', 'Bangladesh', '🇧🇩'),
  Country('IN', 'India', '🇮🇳'),
  Country('RU', 'Russia', '🇷🇺'),
  Country('AU', 'Australia', '🇦🇺'),
];

Country? countryByCode(String? code) {
  if (code == null) return null;
  for (final c in kCountries) {
    if (c.code == code.toUpperCase()) return c;
  }
  return null;
}

/// Flag emoji from an ISO-3166 alpha-2 code (works for any code).
String flagEmoji(String code) {
  final upper = code.toUpperCase();
  if (upper.length != 2) return '🏳️';
  return String.fromCharCodes(upper.codeUnits.map((c) => 0x1F1E6 + (c - 65)));
}
