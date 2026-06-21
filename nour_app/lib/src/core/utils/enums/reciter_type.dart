import 'package:quran/quran.dart' as q;

/// Reciter selection for Quran audio playback.
///
/// Maps 1:1 with the `Reciter` enum from the `quran` package and exposes
/// display-friendly metadata for the UI.
enum ReciterType {
  alafasy(
    reciter: q.Reciter.arAlafasy,
    displayName: 'Sheikh Mishary Al-Afasy',
    arabicName: 'مشاري راشد العفاسي',
  ),
  husary(
    reciter: q.Reciter.arHusary,
    displayName: 'Mahmoud Al-Hussary',
    arabicName: 'محمود خليل الحصري',
  ),
  ahmedAjamy(
    reciter: q.Reciter.arAhmedAjamy,
    displayName: 'Ahmed Al-Ajamy',
    arabicName: 'أحمد العجمي',
  ),
  hudhaify(
    reciter: q.Reciter.arHudhaify,
    displayName: 'Ali Al-Hudhaify',
    arabicName: 'علي الحذيفي',
  ),
  maherMuaiqly(
    reciter: q.Reciter.arMaherMuaiqly,
    displayName: 'Sheikh Maher Muaqily',
    arabicName: 'ماهر المعيقلي',
  ),
  muhammadAyyoub(
    reciter: q.Reciter.arMuhammadAyyoub,
    displayName: 'Muhammad Ayyoub',
    arabicName: 'محمد أيوب',
  ),
  muhammadJibreel(
    reciter: q.Reciter.arMuhammadJibreel,
    displayName: 'Muhammad Jibreel',
    arabicName: 'محمد جبريل',
  ),
  minshawi(
    reciter: q.Reciter.arMinshawi,
    displayName: 'Mohamed Siddiq Al-Minshawi',
    arabicName: 'محمد صديق المنشاوي',
  ),
  shaatree(
    reciter: q.Reciter.arShaatree,
    displayName: 'Abu Bakr Ash-Shaatree',
    arabicName: 'أبو بكر الشاطري',
  );

  const ReciterType({
    required this.reciter,
    required this.displayName,
    required this.arabicName,
  });

  final q.Reciter reciter;
  final String displayName;
  final String arabicName;

  /// Default reciter when no preference is stored.
  static const ReciterType defaultReciter = ReciterType.alafasy;

  String get dbValue => name;

  static ReciterType fromString(String? value) {
    if (value == null) return defaultReciter;
    return ReciterType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => defaultReciter,
    );
  }
}
