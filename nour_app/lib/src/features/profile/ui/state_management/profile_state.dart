import 'package:freezed_annotation/freezed_annotation.dart';

import '../../data/models/profile_model.dart';

part 'profile_state.freezed.dart';

@freezed
abstract class ProfileState with _$ProfileState {
  const factory ProfileState ({
    required bool isLoading,
    ProfileModel? profile,
  }) = _ProfileState;
}
