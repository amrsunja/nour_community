import 'package:equatable/equatable.dart';

import '../../data/models/notifications_settings_model.dart';

class NotificationsState extends Equatable {
  final bool isLoading;
  final NotificationsSettingsModel settings;

  const NotificationsState({
    required this.isLoading,
    required this.settings,
  });

  static const NotificationsState initial = NotificationsState(
    isLoading: false,
    settings: NotificationsSettingsModel.initial,
  );

  NotificationsState copyWith({
    bool? isLoading,
    NotificationsSettingsModel? settings,
  }) {
    return NotificationsState(
      isLoading: isLoading ?? this.isLoading,
      settings: settings ?? this.settings,
    );
  }

  @override
  List<Object?> get props => [isLoading, settings];
}
