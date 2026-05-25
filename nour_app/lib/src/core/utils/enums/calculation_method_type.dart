import 'package:adhan_dart/adhan_dart.dart';

/// Prayer-time calculation methods supported by the app.
///
/// Thin wrapper over the `adhan_dart` `CalculationMethodParameters` named
/// constructors. [id] is the stable value persisted in the settings table,
/// while [name]/[description] feed the calculation-method bottom sheet.
enum CalculationMethodType {
  muslimWorldLeague(
    id: 'muslim_world_league',
    name: 'World league',
    description:
        'Muslim World League. Widely used across Europe, the Far East and '
        'parts of North America. Fajr at 18°, Isha at 17°.',
  ),
  france(
    id: 'france',
    name: 'France',
    description:
        'Union des Organisations Islamiques de France (UOIF) '
        'Fajr Angle: 12° '
        'Isha Angle: 12°',
  ),

  egyptian(
    id: 'egyptian',
    name: 'Egyptian',
    description:
        'Egyptian General Authority of Survey. Common in Egypt, Africa and '
        'parts of the Middle East. Fajr at 19.5°, Isha at 17.5°.',
  ),
  karachi(
    id: 'karachi',
    name: 'Karachi',
    description:
        'University of Islamic Sciences, Karachi. Used in Pakistan, India, '
        'Bangladesh and Afghanistan. Fajr and Isha at 18°.',
  ),
  ummAlQura(
    id: 'umm_al_qura',
    name: 'Umm al-Qura',
    description:
        'Umm al-Qura University, Makkah. Used in Saudi Arabia. Fajr at 18.5°, '
        'Isha a fixed 90 minutes after Maghrib.',
  ),
  dubai(
    id: 'dubai',
    name: 'Dubai',
    description: 'Used across the United Arab Emirates. Fajr and Isha at 18.2°.',
  ),
  qatar(
    id: 'qatar',
    name: 'Qatar',
    description:
        'Modified Umm al-Qura. Fajr at 18°, Isha a fixed 90 minutes after '
        'Maghrib.',
  ),
  kuwait(
    id: 'kuwait',
    name: 'Kuwait',
    description: 'Used in Kuwait. Fajr at 18°, Isha at 17.5°.',
  ),
  moonsightingCommittee(
    id: 'moonsighting_committee',
    name: 'Moonsighting Committee',
    description:
        'Moonsighting Committee Worldwide with a seasonal adjustment for high '
        'latitudes. Fajr and Isha at 18°.',
  ),
  singapore(
    id: 'singapore',
    name: 'Singapore',
    description: 'Majlis Ugama Islam Singapura. Fajr at 20°, Isha at 18°.',
  ),
  northAmerica(
    id: 'north_america',
    name: 'North America (ISNA)',
    description:
        'Islamic Society of North America. Earlier reference angles. Fajr and '
        'Isha at 15°.',
  ),
  turkey(
    id: 'turkey',
    name: 'Turkey',
    description: 'Diyanet İşleri Başkanlığı (Turkey). Fajr at 18°, Isha at 17°.',
  ),
  tehran(
    id: 'tehran',
    name: 'Tehran',
    description:
        'Institute of Geophysics, University of Tehran. Fajr at 17.7°, '
        'Isha at 14°.',
  );

  const CalculationMethodType({
    required this.id,
    required this.name,
    required this.description,
  });

  /// Stable identifier persisted in the database.
  final String id;

  /// Short, human-readable method name shown in the UI.
  final String name;

  /// Longer explanation surfaced in the calculation-method bottom sheet.
  final String description;

  static const CalculationMethodType defaultMethod =
      CalculationMethodType.muslimWorldLeague;

  static CalculationMethodType fromId(String? id) =>
      values.firstWhere((m) => m.id == id, orElse: () => defaultMethod);

  /// Builds the matching `adhan_dart` parameter set for this method.
  CalculationParameters buildParameters() {
    switch (this) {
      case CalculationMethodType.muslimWorldLeague:
        return CalculationMethodParameters.muslimWorldLeague();
      case CalculationMethodType.egyptian:
        return CalculationMethodParameters.egyptian();
      case CalculationMethodType.karachi:
        return CalculationMethodParameters.karachi();
      case CalculationMethodType.ummAlQura:
        return CalculationMethodParameters.ummAlQura();
      case CalculationMethodType.dubai:
        return CalculationMethodParameters.dubai();
      case CalculationMethodType.qatar:
        return CalculationMethodParameters.qatar();
      case CalculationMethodType.kuwait:
        return CalculationMethodParameters.kuwait();
      case CalculationMethodType.moonsightingCommittee:
        return CalculationMethodParameters.moonsightingCommittee();
      case CalculationMethodType.singapore:
        return CalculationMethodParameters.singapore();
      case CalculationMethodType.northAmerica:
        return CalculationMethodParameters.northAmerica();
      case CalculationMethodType.turkey:
        return CalculationMethodParameters.turkiye();
      case CalculationMethodType.tehran:
        return CalculationMethodParameters.tehran();
      case CalculationMethodType.france:
        return CalculationMethodParameters.france();
    }
  }
}
