import 'package:equatable/equatable.dart';
import 'package:nour/src/core/utils/typedefs.dart';

/// A single dua ready for display. Mirrors `public.duas`.
///
/// Unlike hadiths, duas live in one flat library (no collections), so
/// [position] is the 1-based order inside the whole library — used both for the
/// numbered badge in the list and to derive reading progress ("x/total").
/// [whenEn]/[whenFr]/[whenAr] hold the "When to recite" guidance shown beneath
/// the translation. [audioUrl] is optional (a recitation), [likesCount] is the
/// global favorite count (maintained by a DB trigger on `favorite_duas`).
class DuaModel extends Equatable {
  final int id;

  final String titleEn;
  final String titleFr;
  final String titleAr;

  final String arabicText;

  final String transcriptionEn;
  final String transcriptionFr;

  final String translationEn;
  final String translationFr;

  final String whenEn;
  final String whenFr;
  final String whenAr;

  final String referenceEn;
  final String referenceFr;
  final String referenceAr;

  final String tafsirEn;
  final String tafsirFr;
  final String tafsirAr;

  final String? audioUrl;
  final int ajr;
  final int likesCount;
  final int position;
  final bool isActive;

  const DuaModel({
    required this.id,
    required this.titleEn,
    required this.titleFr,
    required this.titleAr,
    required this.arabicText,
    this.transcriptionEn = '',
    this.transcriptionFr = '',
    this.translationEn = '',
    this.translationFr = '',
    this.whenEn = '',
    this.whenFr = '',
    this.whenAr = '',
    this.referenceEn = '',
    this.referenceFr = '',
    this.referenceAr = '',
    this.tafsirEn = '',
    this.tafsirFr = '',
    this.tafsirAr = '',
    this.audioUrl,
    this.ajr = 5,
    this.likesCount = 0,
    this.position = 0,
    this.isActive = true,
  });

  factory DuaModel.fromJson(Json json) => DuaModel(
        id: json['id'] as int,
        titleEn: json['title_en'] ?? '',
        titleFr: json['title_fr'] ?? '',
        titleAr: json['title_ar'] ?? '',
        arabicText: json['arabic_text'] ?? '',
        transcriptionEn: json['transcription_en'] ?? '',
        transcriptionFr: json['transcription_fr'] ?? '',
        translationEn: json['translation_en'] ?? '',
        translationFr: json['translation_fr'] ?? '',
        whenEn: json['when_en'] ?? '',
        whenFr: json['when_fr'] ?? '',
        whenAr: json['when_ar'] ?? '',
        referenceEn: json['reference_en'] ?? '',
        referenceFr: json['reference_fr'] ?? '',
        referenceAr: json['reference_ar'] ?? '',
        tafsirEn: json['tafsir_en'] ?? '',
        tafsirFr: json['tafsir_fr'] ?? '',
        tafsirAr: json['tafsir_ar'] ?? '',
        audioUrl: (json['audio_url'] as String?)?.trim().isEmpty ?? true
            ? null
            : json['audio_url'] as String,
        ajr: json['ajr'] ?? 5,
        likesCount: json['likes_count'] ?? 0,
        position: json['position'] ?? 0,
        isActive: json['is_active'] ?? true,
      );

  bool get hasAudio => audioUrl != null && audioUrl!.isNotEmpty;

  /// Localized heading (e.g. "After salah"). Falls back to the reference, then
  /// the translation, so the card always has something to show.
  String title(String langCode) {
    final t = switch (langCode) {
      'fr' => titleFr.isNotEmpty ? titleFr : titleEn,
      'ar' => titleAr.isNotEmpty ? titleAr : titleEn,
      _ => titleEn,
    };
    if (t.isNotEmpty) return t;
    final ref = reference(langCode);
    if (ref.isNotEmpty) return ref;
    return translation(langCode);
  }

  /// Short preview line shown under the title in the library list.
  /// Falls back to the translation when no "when" guidance is set.
  String description(String langCode) {
    final w = when(langCode);
    if (w.isNotEmpty) return w;
    return translation(langCode);
  }

  /// Latin transcription toggled by the "Aa" action (none for Arabic).
  String transcription(String langCode) =>
      langCode == 'fr' ? transcriptionFr : transcriptionEn;

  String translation(String langCode) =>
      langCode == 'fr' ? translationFr : translationEn;

  /// "When to recite" guidance shown under the translation in the reader.
  String when(String langCode) => switch (langCode) {
        'fr' => whenFr.isNotEmpty ? whenFr : whenEn,
        'ar' => whenAr.isNotEmpty ? whenAr : whenEn,
        _ => whenEn,
      };

  /// Source reference, e.g. "Sahih Muslim 3302".
  String reference(String langCode) => switch (langCode) {
        'fr' => referenceFr.isNotEmpty ? referenceFr : referenceEn,
        'ar' => referenceAr.isNotEmpty ? referenceAr : referenceEn,
        _ => referenceEn,
      };

  String tafsir(String langCode) => switch (langCode) {
        'fr' => tafsirFr.isNotEmpty ? tafsirFr : tafsirEn,
        'ar' => tafsirAr.isNotEmpty ? tafsirAr : tafsirEn,
        _ => tafsirEn,
      };

  DuaModel copyWith({int? likesCount}) => DuaModel(
        id: id,
        titleEn: titleEn,
        titleFr: titleFr,
        titleAr: titleAr,
        arabicText: arabicText,
        transcriptionEn: transcriptionEn,
        transcriptionFr: transcriptionFr,
        translationEn: translationEn,
        translationFr: translationFr,
        whenEn: whenEn,
        whenFr: whenFr,
        whenAr: whenAr,
        referenceEn: referenceEn,
        referenceFr: referenceFr,
        referenceAr: referenceAr,
        tafsirEn: tafsirEn,
        tafsirFr: tafsirFr,
        tafsirAr: tafsirAr,
        audioUrl: audioUrl,
        ajr: ajr,
        likesCount: likesCount ?? this.likesCount,
        position: position,
        isActive: isActive,
      );

  @override
  List<Object?> get props => [
        id,
        titleEn,
        titleFr,
        titleAr,
        arabicText,
        transcriptionEn,
        transcriptionFr,
        translationEn,
        translationFr,
        whenEn,
        whenFr,
        whenAr,
        referenceEn,
        referenceFr,
        referenceAr,
        tafsirEn,
        tafsirFr,
        tafsirAr,
        audioUrl,
        ajr,
        likesCount,
        position,
        isActive,
      ];
}
