import 'package:equatable/equatable.dart';
import 'package:nour/src/core/utils/enums/gender_type.dart';
import 'package:nour/src/core/utils/enums/language_type.dart';
import 'package:nour/src/core/utils/enums/level_type.dart';
import 'package:nour/src/core/utils/typedefs.dart';

// ignore: must_be_immutable
class ProfileModel extends Equatable {
  final String id;
  String? name;
  final String? avatar;
  GenderType? gender;
  LevelType? level;
  LanguageType language;
  bool onboardingCompleted;
  int lastOnboardingScreen;
  int dailyPracticeTime;
  final int currentStreak;
  final DateTime? lastStreakDate;
  final int earnedAjrCount;
  final bool isAdmin;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ProfileModel({
    required this.id,
    required this.name,
    required this.avatar,
    required this.gender,
    required this.level,
    required this.language,
    required this.onboardingCompleted,
    required this.lastOnboardingScreen,
    required this.dailyPracticeTime,
    required this.currentStreak,
    required this.lastStreakDate,
    required this.earnedAjrCount,
    required this.isAdmin,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProfileModel.fromJson(Json json) => ProfileModel(
    id: json['id'],
    name: json['name'],
    avatar: json['avatar_url'],
    gender: json['gender'] == null ? null : GenderType.fromString(json['gender']),
    level: json['level'] == null ? null : LevelType.fromString(json['level']),
    language: LanguageType.fromString(json['language']),
    onboardingCompleted: json['onboarding_completed'],
    lastOnboardingScreen: json['last_onboarding_screen'],
    dailyPracticeTime: json['daily_practice_time'],
    currentStreak: json['current_streak'],
    lastStreakDate: DateTime.tryParse(json['last_streak_date'] ?? ''),
    earnedAjrCount: json['earned_ajr_count'],
    isAdmin: json['is_admin'],
    createdAt: DateTime.tryParse(json['created_at'] ?? ''),
    updatedAt: DateTime.tryParse(json['updated_at'] ?? ''),
  );

  @override
  List<Object?> get props => [
    id,
    name,
    avatar,
    gender,
    level,
    language,
    onboardingCompleted,
    lastOnboardingScreen,
    dailyPracticeTime,
    currentStreak,
    lastStreakDate,
    earnedAjrCount,
    isAdmin,
    createdAt,
    updatedAt,
  ];
}
