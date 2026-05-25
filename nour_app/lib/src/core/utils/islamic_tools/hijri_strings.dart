/// Localized Hijri month names and Islamic event names.
///
/// Kept in code (rather than the .arb files) because they are largely
/// transliterations and form a self-contained domain table. Falls back to
/// English when a locale is not available.
class HijriStrings {
  const HijriStrings._();

  static const Map<int, String> _monthsEn = {
    1: 'Muharram',
    2: 'Safar',
    3: 'Rabi al-Awwal',
    4: 'Rabi al-Thani',
    5: 'Jumada al-Awwal',
    6: 'Jumada al-Thani',
    7: 'Rajab',
    8: 'Sha\'ban',
    9: 'Ramadan',
    10: 'Shawwal',
    11: 'Dhul Qa\'ada',
    12: 'Dhul Hijjah',
  };

  static const Map<int, String> _monthsFr = {
    1: 'Mouharram',
    2: 'Safar',
    3: 'Rabi al-Awwal',
    4: 'Rabi al-Thani',
    5: 'Joumada al-Awwal',
    6: 'Joumada al-Thani',
    7: 'Rajab',
    8: 'Chaabane',
    9: 'Ramadan',
    10: 'Chawwal',
    11: 'Dhou al-Qi\'da',
    12: 'Dhou al-Hijja',
  };

  static const Map<int, String> _monthsAr = {
    1: 'محرم',
    2: 'صفر',
    3: 'ربيع الأول',
    4: 'ربيع الثاني',
    5: 'جمادى الأولى',
    6: 'جمادى الآخرة',
    7: 'رجب',
    8: 'شعبان',
    9: 'رمضان',
    10: 'شوال',
    11: 'ذو القعدة',
    12: 'ذو الحجة',
  };

  static String monthName(int month, String languageCode) {
    final map = switch (languageCode) {
      'fr' => _monthsFr,
      'ar' => _monthsAr,
      _ => _monthsEn,
    };
    return map[month] ?? _monthsEn[month] ?? '';
  }

  static const Map<String, String> _eventsEn = {
    'islamic_new_year': 'Islamic New Year',
    'ashura': 'Day of Ashura',
    'mawlid': 'Mawlid al-Nabi',
    'isra_miraj': 'Isra and Mi\'raj',
    'ramadan_begins': 'Ramadan begins',
    'laylat_al_qadr': 'Laylat al-Qadr',
    'eid_al_fitr': 'Eid al-Fitr',
    'dhul_hijjah_begins': 'Dhul Hijjah begins',
    'day_of_arafah': 'Day of Arafah',
    'eid_al_adha': 'Eid al-Adha',
  };

  static const Map<String, String> _eventsFr = {
    'islamic_new_year': 'Nouvel an musulman',
    'ashura': 'Jour de l\'Achoura',
    'mawlid': 'Mawlid al-Nabi',
    'isra_miraj': 'Isra et Mi\'raj',
    'ramadan_begins': 'Début du Ramadan',
    'laylat_al_qadr': 'Laylat al-Qadr',
    'eid_al_fitr': 'Aïd al-Fitr',
    'dhul_hijjah_begins': 'Début de Dhou al-Hijja',
    'day_of_arafah': 'Jour d\'Arafat',
    'eid_al_adha': 'Aïd al-Adha',
  };

  static const Map<String, String> _eventsAr = {
    'islamic_new_year': 'رأس السنة الهجرية',
    'ashura': 'يوم عاشوراء',
    'mawlid': 'المولد النبوي',
    'isra_miraj': 'الإسراء والمعراج',
    'ramadan_begins': 'بداية رمضان',
    'laylat_al_qadr': 'ليلة القدر',
    'eid_al_fitr': 'عيد الفطر',
    'dhul_hijjah_begins': 'بداية ذي الحجة',
    'day_of_arafah': 'يوم عرفة',
    'eid_al_adha': 'عيد الأضحى',
  };

  static String eventName(String id, String languageCode) {
    final map = switch (languageCode) {
      'fr' => _eventsFr,
      'ar' => _eventsAr,
      _ => _eventsEn,
    };
    return map[id] ?? _eventsEn[id] ?? id;
  }
}
