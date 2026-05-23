import 'package:equatable/equatable.dart';
import 'package:nour/src/core/utils/typedefs.dart';

/// Per-user reading position inside the single dua library. Mirrors
/// `public.dua_progress` (one row per user, seeded by handle_new_auth_user).
/// The client only ever writes `current_dua_id`.
///
/// [currentPosition] is derived (the 1-based order of [currentDuaId] within the
/// library) so the library card can show "x/total" without loading everything.
/// It is 0 when nothing has been read yet.
class DuaProgressModel extends Equatable {
  final int? currentDuaId;
  final int currentPosition;
  final DateTime? updatedAt;

  const DuaProgressModel({
    this.currentDuaId,
    this.currentPosition = 0,
    this.updatedAt,
  });

  static const empty = DuaProgressModel();

  factory DuaProgressModel.fromJson(Json json) => DuaProgressModel(
        currentDuaId: json['current_dua_id'] as int?,
        updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? ''),
      );

  bool get hasProgress => currentDuaId != null && currentPosition > 0;

  DuaProgressModel copyWith({
    int? currentDuaId,
    int? currentPosition,
  }) =>
      DuaProgressModel(
        currentDuaId: currentDuaId ?? this.currentDuaId,
        currentPosition: currentPosition ?? this.currentPosition,
        updatedAt: updatedAt,
      );

  @override
  List<Object?> get props => [currentDuaId, currentPosition, updatedAt];
}
