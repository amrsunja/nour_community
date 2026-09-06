import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:nour/src/features/mosques/data/models/mosque_enums.dart';

/// Steps of the mosque-manager onboarding (Figma section "Onboarding mosquée").
/// Kept as an enum so [MosqueOnboardingDraft.step] survives reordering.
enum MosqueOnboardingStep {
  featureAnnouncements, // "Made for mosque announcements"
  featureFunds,         // "Raise funds the trusted way"
  featureCalendar,      // "A calendar that reflects your imam"
  country,
  language,
  reminders,
  register,             // legal name / status / RNA / SIREN
  account,              // sign up / sign in
}

/// Local-only draft persisted while the mosque manager has NO session yet.
/// Cleared by [MosqueOnboardingLocalDatasource.clear] once the account exists
/// (or when the user logs into an existing profile of either type).
class MosqueOnboardingDraft extends Equatable {
  final MosqueOnboardingStep step;
  final String? countryCode;
  final String? language;
  final String? legalName;
  final MosqueLegalStatus? legalStatus;
  final String? rna;
  final String? siren;

  const MosqueOnboardingDraft({
    this.step = MosqueOnboardingStep.featureAnnouncements,
    this.countryCode,
    this.language,
    this.legalName,
    this.legalStatus,
    this.rna,
    this.siren,
  });

  static const empty = MosqueOnboardingDraft();

  static final _rnaRegex = RegExp(r'^W\d{9}$');
  static final _sirenRegex = RegExp(r'^\d{9}$');

  bool get isRnaRequired => legalStatus != MosqueLegalStatus.other;

  bool get isRegisterValid {
    if ((legalName ?? '').trim().length < 2) return false;
    if (legalStatus == null) return false;
    if (!_sirenRegex.hasMatch(siren ?? '')) return false;
    if (isRnaRequired && !_rnaRegex.hasMatch(rna ?? '')) return false;
    return true;
  }

  static bool isValidSiren(String v) => _sirenRegex.hasMatch(v.trim());
  static bool isValidRna(String v) => _rnaRegex.hasMatch(v.trim().toUpperCase());

  MosqueOnboardingDraft copyWith({
    MosqueOnboardingStep? step,
    String? countryCode,
    String? language,
    String? legalName,
    MosqueLegalStatus? legalStatus,
    String? rna,
    String? siren,
  }) {
    return MosqueOnboardingDraft(
      step: step ?? this.step,
      countryCode: countryCode ?? this.countryCode,
      language: language ?? this.language,
      legalName: legalName ?? this.legalName,
      legalStatus: legalStatus ?? this.legalStatus,
      rna: rna ?? this.rna,
      siren: siren ?? this.siren,
    );
  }

  Map<String, dynamic> toJson() => {
        'step': step.name,
        'country_code': countryCode,
        'language': language,
        'legal_name': legalName,
        'legal_status': legalStatus?.dbValue,
        'rna': rna,
        'siren': siren,
      };

  factory MosqueOnboardingDraft.fromJson(Map<String, dynamic> json) => MosqueOnboardingDraft(
        step: MosqueOnboardingStep.values.firstWhere(
          (e) => e.name == json['step'],
          orElse: () => MosqueOnboardingStep.featureAnnouncements,
        ),
        countryCode: json['country_code'] as String?,
        language: json['language'] as String?,
        legalName: json['legal_name'] as String?,
        legalStatus: json['legal_status'] == null ? null : MosqueLegalStatus.fromDb(json['legal_status'] as String?),
        rna: json['rna'] as String?,
        siren: json['siren'] as String?,
      );

  String encode() => jsonEncode(toJson());

  static MosqueOnboardingDraft? decode(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      return MosqueOnboardingDraft.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  @override
  List<Object?> get props => [step, countryCode, language, legalName, legalStatus, rna, siren];
}
