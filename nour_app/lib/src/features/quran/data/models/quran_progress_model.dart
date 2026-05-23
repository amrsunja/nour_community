import 'package:equatable/equatable.dart';
import 'package:nour/src/core/utils/typedefs.dart';

/// Per-user "continue reading" position. Mirrors `public.quran_progress`
/// (one row per user, created by `handle_new_auth_user`). The client only
/// ever writes `current_surah_number` / `current_ayah_number`.
class QuranProgressModel extends Equatable {
  final int surahNumber;
  final int ayahNumber;
  final DateTime? updatedAt;

  const QuranProgressModel({
    required this.surahNumber,
    required this.ayahNumber,
    this.updatedAt,
  });

  factory QuranProgressModel.fromJson(Json json) => QuranProgressModel(
        surahNumber: json['current_surah_number'] ?? 1,
        ayahNumber: json['current_ayah_number'] ?? 1,
        updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? ''),
      );

  /// Fallback for a brand-new reader (no row yet).
  static const QuranProgressModel initial =
      QuranProgressModel(surahNumber: 1, ayahNumber: 1);

  QuranProgressModel copyWith({int? surahNumber, int? ayahNumber}) =>
      QuranProgressModel(
        surahNumber: surahNumber ?? this.surahNumber,
        ayahNumber: ayahNumber ?? this.ayahNumber,
        updatedAt: updatedAt,
      );

  @override
  List<Object?> get props => [surahNumber, ayahNumber, updatedAt];
}
