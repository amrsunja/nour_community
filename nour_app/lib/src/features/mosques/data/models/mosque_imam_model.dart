import 'package:equatable/equatable.dart';
import 'package:nour/src/core/utils/typedefs.dart';

class MosqueImamModel extends Equatable {
  final int id;
  final int mosqueId;
  final String fullName;
  final String? role;
  final int? sinceYear;
  final String? bio;
  final String? photoUrl;
  final int position;

  const MosqueImamModel({
    required this.id,
    required this.mosqueId,
    required this.fullName,
    this.role,
    this.sinceYear,
    this.bio,
    this.photoUrl,
    this.position = 0,
  });

  String get initials {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    final letters = parts.where((p) => p.isNotEmpty).take(2).map((p) => p[0].toUpperCase());
    return letters.join();
  }

  factory MosqueImamModel.fromJson(Json json) => MosqueImamModel(
        id: json['id'] as int,
        mosqueId: json['mosque_id'] as int,
        fullName: json['full_name'] as String? ?? '',
        role: json['role'] as String?,
        sinceYear: json['since_year'] as int?,
        bio: json['bio'] as String?,
        photoUrl: json['photo_url'] as String?,
        position: json['position'] as int? ?? 0,
      );

  Json toInsertJson() => {
        'mosque_id': mosqueId,
        'full_name': fullName,
        'role': role,
        'since_year': sinceYear,
        'bio': bio,
        'photo_url': photoUrl,
        'position': position,
      };

  @override
  List<Object?> get props => [id, mosqueId, fullName, role, sinceYear, bio, photoUrl, position];
}
