import 'package:equatable/equatable.dart';
import 'package:nour/src/core/utils/typedefs.dart';

/// Row of `mosque_members` (the viewer's own membership or, for admins, a
/// member of their mosque).
class MosqueMemberModel extends Equatable {
  final int id;
  final int mosqueId;
  final String userId;
  final String firstName;
  final String lastName;
  final DateTime birthDate;
  final String? profession;
  final String email;
  final String phone;
  final bool volunteer;
  final String status;
  final int? feeSubscriptionId;
  final DateTime createdAt;

  const MosqueMemberModel({
    required this.id,
    required this.mosqueId,
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.birthDate,
    this.profession,
    required this.email,
    required this.phone,
    this.volunteer = false,
    this.status = 'active',
    this.feeSubscriptionId,
    required this.createdAt,
  });

  bool get isActive => status == 'active';
  String get fullName => '$firstName $lastName'.trim();

  factory MosqueMemberModel.fromJson(Json json) => MosqueMemberModel(
        id: json['id'] as int,
        mosqueId: json['mosque_id'] as int,
        userId: json['user_id'] as String,
        firstName: json['first_name'] as String? ?? '',
        lastName: json['last_name'] as String? ?? '',
        birthDate: DateTime.tryParse(json['birth_date']?.toString() ?? '') ?? DateTime(1970),
        profession: json['profession'] as String?,
        email: json['email'] as String? ?? '',
        phone: json['phone'] as String? ?? '',
        volunteer: json['volunteer'] as bool? ?? false,
        status: json['status'] as String? ?? 'active',
        feeSubscriptionId: json['fee_subscription_id'] as int?,
        createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
      );

  @override
  List<Object?> get props => [id, mosqueId, userId, firstName, lastName, birthDate, profession, email, phone, volunteer, status, feeSubscriptionId, createdAt];
}

/// Row of `fn_mosque_community` (admin Community tab).
class MosqueCommunityMember extends Equatable {
  final String userId;
  final String? name;
  final String? avatarUrl;
  final String kind; // member | follower
  final DateTime since;
  final String? email;
  final String? phone;
  final bool volunteer;
  final int? memberId;

  const MosqueCommunityMember({
    required this.userId,
    this.name,
    this.avatarUrl,
    required this.kind,
    required this.since,
    this.email,
    this.phone,
    this.volunteer = false,
    this.memberId,
  });

  bool get isMember => kind == 'member';

  String get initials {
    final n = (name ?? '').trim();
    if (n.isEmpty) return '?';
    return n.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).take(2).map((p) => p[0].toUpperCase()).join();
  }

  factory MosqueCommunityMember.fromJson(Json json) => MosqueCommunityMember(
        userId: json['user_id'] as String,
        name: json['name'] as String?,
        avatarUrl: json['avatar_url'] as String?,
        kind: json['kind'] as String? ?? 'follower',
        since: DateTime.tryParse(json['since']?.toString() ?? '') ?? DateTime.now(),
        email: json['email'] as String?,
        phone: json['phone'] as String?,
        volunteer: json['volunteer'] as bool? ?? false,
        memberId: json['member_id'] as int?,
      );

  @override
  List<Object?> get props => [userId, name, avatarUrl, kind, since, email, phone, volunteer, memberId];
}
