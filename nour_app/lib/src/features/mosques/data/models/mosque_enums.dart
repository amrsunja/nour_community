/// Enums mirroring the Postgres types of the mosques module.
/// `fromDb` is tolerant: unknown values fall back to a safe default.

enum MosqueStatus {
  pendingReview('pending_review'),
  approved('approved'),
  rejected('rejected'),
  suspended('suspended');

  const MosqueStatus(this.dbValue);
  final String dbValue;

  static MosqueStatus fromDb(String? v) =>
      values.firstWhere((e) => e.dbValue == v, orElse: () => pendingReview);

  bool get isApproved => this == approved;
}

enum MosqueLegalStatus {
  association1901('association_1901'),
  association1905('association_1905'),
  other('other');

  const MosqueLegalStatus(this.dbValue);
  final String dbValue;

  static MosqueLegalStatus fromDb(String? v) =>
      values.firstWhere((e) => e.dbValue == v, orElse: () => other);
}

enum MosqueAdminRole {
  owner('owner'),
  manager('manager');

  const MosqueAdminRole(this.dbValue);
  final String dbValue;

  static MosqueAdminRole fromDb(String? v) =>
      values.firstWhere((e) => e.dbValue == v, orElse: () => manager);
}

enum MosqueService {
  parking('parking'),
  disabledAccess('disabled_access'),
  ablutionRoom('ablution_room'),
  womenSpace('women_space'),
  adultClasses('adult_classes'),
  childrenClasses('children_classes'),
  quranClasses('quran_classes'),
  arabicClasses('arabic_classes'),
  eidPrayer('eid_prayer'),
  janaza('janaza'),
  iftarRamadan('iftar_ramadan'),
  library('library'),
  newMuslimsSupport('new_muslims_support');

  const MosqueService(this.dbValue);
  final String dbValue;

  static MosqueService? fromDb(String? v) {
    for (final e in values) {
      if (e.dbValue == v) return e;
    }
    return null;
  }

  static List<MosqueService> listFromDb(dynamic raw) {
    if (raw is! List) return const [];
    return raw.map((e) => fromDb(e?.toString())).whereType<MosqueService>().toList();
  }
}

enum MosquePostType {
  announcement('announcement'),
  event('event'),
  volunteering('volunteering'),
  highlight('highlight'),
  janaza('janaza');

  const MosquePostType(this.dbValue);
  final String dbValue;

  static MosquePostType fromDb(String? v) =>
      values.firstWhere((e) => e.dbValue == v, orElse: () => announcement);
}

enum MosquePostStatus {
  draft('draft'),
  published('published'),
  archived('archived');

  const MosquePostStatus(this.dbValue);
  final String dbValue;

  static MosquePostStatus fromDb(String? v) =>
      values.firstWhere((e) => e.dbValue == v, orElse: () => published);
}

enum MosquePostAudience {
  public('public'),
  followers('followers');

  const MosquePostAudience(this.dbValue);
  final String dbValue;

  static MosquePostAudience fromDb(String? v) =>
      values.firstWhere((e) => e.dbValue == v, orElse: () => public);
}

enum MosqueCampaignStatus {
  draft('draft'),
  active('active'),
  closed('closed'),
  cancelled('cancelled');

  const MosqueCampaignStatus(this.dbValue);
  final String dbValue;

  static MosqueCampaignStatus fromDb(String? v) =>
      values.firstWhere((e) => e.dbValue == v, orElse: () => active);
}

enum StripeAccountStatus {
  notStarted('not_started'),
  onboarding('onboarding'),
  active('active'),
  restricted('restricted'),
  disabled('disabled');

  const StripeAccountStatus(this.dbValue);
  final String dbValue;

  static StripeAccountStatus fromDb(String? v) =>
      values.firstWhere((e) => e.dbValue == v, orElse: () => notStarted);
}

/// Tabs of the public mosque profile (user + admin editor).
enum MosqueTab { prayers, information, news, donation }
