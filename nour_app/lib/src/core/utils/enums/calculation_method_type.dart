import 'package:adhan_dart/adhan_dart.dart';
import 'package:nour/src/core/locale/l10n.dart';

/// Prayer-time calculation methods supported by the app.
///
/// Thin wrapper over the `adhan_dart` `CalculationMethodParameters` named
/// constructors. [id] is the stable value persisted in the settings table.
/// Human-readable name/description are resolved per-locale via
/// [localizedName]/[localizedDescription] using the generated [AppLocale]
/// strings (keys `calc_method_<id>_name` / `calc_method_<id>_desc`).
enum CalculationMethodType {
  muslimWorldLeague(id: 'muslim_world_league'),
  france(id: 'france'),
  egyptian(id: 'egyptian'),
  karachi(id: 'karachi'),
  ummAlQura(id: 'umm_al_qura'),
  dubai(id: 'dubai'),
  qatar(id: 'qatar'),
  kuwait(id: 'kuwait'),
  moonsightingCommittee(id: 'moonsighting_committee'),
  singapore(id: 'singapore'),
  northAmerica(id: 'north_america'),
  turkey(id: 'turkey'),
  tehran(id: 'tehran'),
  algerian(id: 'algerian'),
  gulfRegion(id: 'gulf_region'),
  indonesian(id: 'indonesian'),
  jafari(id: 'jafari'),
  jordan(id: 'jordan'),
  morocco(id: 'morocco'),
  portugal(id: 'portugal'),
  russia(id: 'russia'),
  tunisia(id: 'tunisia');

  const CalculationMethodType({required this.id});

  /// Stable identifier persisted in the database.
  final String id;

  static const CalculationMethodType defaultMethod =
      CalculationMethodType.muslimWorldLeague;

  static CalculationMethodType fromId(String? id) =>
      values.firstWhere((m) => m.id == id, orElse: () => defaultMethod);

  /// Short, human-readable method name for the current locale.
  String localizedName(AppLocale l10n) {
    switch (this) {
      case CalculationMethodType.muslimWorldLeague:
        return l10n.calc_method_muslim_world_league_name;
      case CalculationMethodType.france:
        return l10n.calc_method_france_name;
      case CalculationMethodType.egyptian:
        return l10n.calc_method_egyptian_name;
      case CalculationMethodType.karachi:
        return l10n.calc_method_karachi_name;
      case CalculationMethodType.ummAlQura:
        return l10n.calc_method_umm_al_qura_name;
      case CalculationMethodType.dubai:
        return l10n.calc_method_dubai_name;
      case CalculationMethodType.qatar:
        return l10n.calc_method_qatar_name;
      case CalculationMethodType.kuwait:
        return l10n.calc_method_kuwait_name;
      case CalculationMethodType.moonsightingCommittee:
        return l10n.calc_method_moonsighting_committee_name;
      case CalculationMethodType.singapore:
        return l10n.calc_method_singapore_name;
      case CalculationMethodType.northAmerica:
        return l10n.calc_method_north_america_name;
      case CalculationMethodType.turkey:
        return l10n.calc_method_turkey_name;
      case CalculationMethodType.tehran:
        return l10n.calc_method_tehran_name;
      case CalculationMethodType.algerian:
        return l10n.calc_method_algerian_name;
      case CalculationMethodType.gulfRegion:
        return l10n.calc_method_gulf_region_name;
      case CalculationMethodType.indonesian:
        return l10n.calc_method_indonesian_name;
      case CalculationMethodType.jafari:
        return l10n.calc_method_jafari_name;
      case CalculationMethodType.jordan:
        return l10n.calc_method_jordan_name;
      case CalculationMethodType.morocco:
        return l10n.calc_method_morocco_name;
      case CalculationMethodType.portugal:
        return l10n.calc_method_portugal_name;
      case CalculationMethodType.russia:
        return l10n.calc_method_russia_name;
      case CalculationMethodType.tunisia:
        return l10n.calc_method_tunisia_name;
    }
  }

  /// Longer explanation surfaced in the calculation-method bottom sheet,
  /// localized for the current locale.
  String localizedDescription(AppLocale l10n) {
    switch (this) {
      case CalculationMethodType.muslimWorldLeague:
        return l10n.calc_method_muslim_world_league_desc;
      case CalculationMethodType.france:
        return l10n.calc_method_france_desc;
      case CalculationMethodType.egyptian:
        return l10n.calc_method_egyptian_desc;
      case CalculationMethodType.karachi:
        return l10n.calc_method_karachi_desc;
      case CalculationMethodType.ummAlQura:
        return l10n.calc_method_umm_al_qura_desc;
      case CalculationMethodType.dubai:
        return l10n.calc_method_dubai_desc;
      case CalculationMethodType.qatar:
        return l10n.calc_method_qatar_desc;
      case CalculationMethodType.kuwait:
        return l10n.calc_method_kuwait_desc;
      case CalculationMethodType.moonsightingCommittee:
        return l10n.calc_method_moonsighting_committee_desc;
      case CalculationMethodType.singapore:
        return l10n.calc_method_singapore_desc;
      case CalculationMethodType.northAmerica:
        return l10n.calc_method_north_america_desc;
      case CalculationMethodType.turkey:
        return l10n.calc_method_turkey_desc;
      case CalculationMethodType.tehran:
        return l10n.calc_method_tehran_desc;
      case CalculationMethodType.algerian:
        return l10n.calc_method_algerian_desc;
      case CalculationMethodType.gulfRegion:
        return l10n.calc_method_gulf_region_desc;
      case CalculationMethodType.indonesian:
        return l10n.calc_method_indonesian_desc;
      case CalculationMethodType.jafari:
        return l10n.calc_method_jafari_desc;
      case CalculationMethodType.jordan:
        return l10n.calc_method_jordan_desc;
      case CalculationMethodType.morocco:
        return l10n.calc_method_morocco_desc;
      case CalculationMethodType.portugal:
        return l10n.calc_method_portugal_desc;
      case CalculationMethodType.russia:
        return l10n.calc_method_russia_desc;
      case CalculationMethodType.tunisia:
        return l10n.calc_method_tunisia_desc;
    }
  }

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
      case CalculationMethodType.algerian:
        return CalculationMethodParameters.algerian();
      case CalculationMethodType.gulfRegion:
        return CalculationMethodParameters.gulfRegion();
      case CalculationMethodType.indonesian:
        return CalculationMethodParameters.indonesian();
      case CalculationMethodType.jafari:
        return CalculationMethodParameters.jafari();
      case CalculationMethodType.jordan:
        return CalculationMethodParameters.jordan();
      case CalculationMethodType.morocco:
        return CalculationMethodParameters.morocco();
      case CalculationMethodType.portugal:
        return CalculationMethodParameters.portugal();
      case CalculationMethodType.russia:
        return CalculationMethodParameters.russia();
      case CalculationMethodType.tunisia:
        return CalculationMethodParameters.tunisia();
    }
  }
}
