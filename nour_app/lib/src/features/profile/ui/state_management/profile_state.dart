import 'package:freezed_annotation/freezed_annotation.dart';

import '../../data/models/profile_model.dart';

part 'profile_state.freezed.dart';

/// UI status for the avatar mutation flow (upload / delete) so the avatar
/// widget can render its own busy state independently of [ProfileState.isLoading].
enum AvatarStatus { idle, uploading, deleting }

@freezed
abstract class ProfileState with _$ProfileState {
  const factory ProfileState ({
    required bool isLoading,
    @Default(AvatarStatus.idle) AvatarStatus avatarStatus,
    ProfileModel? profile,
  }) = _ProfileState;
}
