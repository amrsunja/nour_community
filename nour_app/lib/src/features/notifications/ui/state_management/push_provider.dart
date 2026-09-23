import 'dart:async';
import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/notifications/push_notifications_services.dart';
import 'package:nour/src/core/routing/deep_links_services.dart';
import 'package:nour/src/core/utils/state_management/presenter.dart';
import 'package:nour/src/core/utils/talker/talker.dart';
import 'package:nour/src/features/profile/ui/state_management/profile_provider.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../data/datasrouces/push_remote_datasource.dart';

class PushState extends Equatable {
  final bool initialized;
  final String? token;
  final bool tokenRegistered;

  const PushState({this.initialized = false, this.token, this.tokenRegistered = false});

  PushState copyWith({bool? initialized, String? token, bool? tokenRegistered}) => PushState(
        initialized: initialized ?? this.initialized,
        token: token ?? this.token,
        tokenRegistered: tokenRegistered ?? this.tokenRegistered,
      );

  @override
  List<Object?> get props => [initialized, token, tokenRegistered];
}

final pushProvider = StateNotifierProvider<PushPresenter, PushState>((ref) {
  return PushPresenter(
    services: ref.read(pushNotificationsServicesProvider),
    remote: ref.read(pushRemoteDataProvider),
    deepLinks: ref.read(deepLinksServicesProvider),
    ref: ref,
  );
});

/// Glue between FCM ([PushNotificationsServices]), the backend
/// ([PushRemoteDatasource]) and navigation ([DeepLinksServices]).
class PushPresenter extends Presenter<PushState> {
  final PushNotificationsServices services;
  final PushRemoteDatasource remote;
  final DeepLinksServices deepLinks;
  final Ref ref;

  StreamSubscription? _openedSub;
  StreamSubscription? _tokenSub;

  PushPresenter({
    required this.services,
    required this.remote,
    required this.deepLinks,
    required this.ref,
  }) : super(const PushState());

  @override
  void dispose() {
    _openedSub?.cancel();
    _tokenSub?.cancel();
    super.dispose();
  }

  /// Call once after Firebase is ready. Safe to call again (no-op).
  Future<void> initialize() async {
    if (state.initialized) return;
    await services.initialize();
    _openedSub = services.onOpened.listen(_handleOpened);
    _tokenSub = services.onTokenRefresh.listen((t) => _register(t));
    state = state.copyWith(initialized: true);
  }

  /// Registers the current FCM token for the signed-in user. Called after
  /// every successful authorization / login. Never throws.
  Future<void> syncToken() async {
    if (!state.initialized) await initialize();
    final token = await services.currentToken();
    if (token == null) return;
    await _register(token);
  }

  Future<void> _register(String token) async {
    try {
      final info = await PackageInfo.fromPlatform();
      await remote.registerToken(
        token: token,
        platform: Platform.isIOS ? 'ios' : 'android',
        appVersion: '${info.version}+${info.buildNumber}',
        locale: WidgetsBinding.instance.platformDispatcher.locale.toLanguageTag(),
        timezone: DateTime.now().timeZoneName,
      );
      state = state.copyWith(token: token, tokenRegistered: true);
    } catch (e, st) {
      talker.handle(e, st, 'push register token');
      state = state.copyWith(token: token, tokenRegistered: false);
    }
  }

  /// Logout / delete account: detach the token from the user.
  Future<void> revoke() async {
    final token = state.token ?? await services.currentToken();
    if (token != null) await remote.deleteToken(token);
    await services.deleteToken();
    state = state.copyWith(tokenRegistered: false);
  }

  /// Opens the notification that launched the app, if any. Call once the
  /// router is ready (after authorization).
  Future<void> consumeInitialMessage() async {
    final data = services.takeInitialMessage();
    if (data != null) await _handleOpened(data);
  }

  Future<void> _handleOpened(Map<String, dynamic> data) async {
    final logId = int.tryParse(data['logId']?.toString() ?? '');
    if (logId != null) unawaited(remote.markOpened(logId));
    final link = data['link']?.toString();
    if (link != null && link.isNotEmpty) await deepLinks.open(link);
  }

  Future<bool> setPref(String kind, bool enabled) async {
    final profile = ref.read(profileProvider).profile;
    final prefs = Map<String, dynamic>.from(profile?.pushPrefs ?? const {});
    prefs[kind] = enabled;
    try {
      await remote.setPushPrefs(prefs);
      await ref.read(profileProvider.notifier).initProfile();
      return true;
    } catch (e, st) {
      talker.handle(e, st, 'push prefs');
      return false;
    }
  }
}
