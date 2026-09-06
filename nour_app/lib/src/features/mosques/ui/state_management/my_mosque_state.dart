import 'package:equatable/equatable.dart';
import 'package:nour/src/features/mosques/data/models/mosque_enums.dart';
import 'package:nour/src/features/mosques/data/models/mosque_model.dart';

/// The mosque managed by the current (mosque) account.
class MyMosqueState extends Equatable {
  final bool isLoading;
  final bool loaded;
  final MosqueModel? mosque;
  final MosqueAdminRole? role;

  const MyMosqueState({
    this.isLoading = false,
    this.loaded = false,
    this.mosque,
    this.role,
  });

  bool get isApproved => mosque?.status == MosqueStatus.approved;

  MyMosqueState copyWith({
    bool? isLoading,
    bool? loaded,
    MosqueModel? mosque,
    MosqueAdminRole? role,
    bool clearMosque = false,
  }) {
    return MyMosqueState(
      isLoading: isLoading ?? this.isLoading,
      loaded: loaded ?? this.loaded,
      mosque: clearMosque ? null : (mosque ?? this.mosque),
      role: clearMosque ? null : (role ?? this.role),
    );
  }

  @override
  List<Object?> get props => [isLoading, loaded, mosque, role];
}
