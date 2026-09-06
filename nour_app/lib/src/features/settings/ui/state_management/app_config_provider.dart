import 'package:equatable/equatable.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/network/supabase_client.dart';
import 'package:nour/src/core/utils/state_management/presenter.dart';
import 'package:nour/src/core/utils/talker/talker.dart';

/// Remote feature flags (`public.app_config`). Defaults are conservative so a
/// failed fetch never exposes an unfinished feature (§4.14).
class AppConfigState extends Equatable {
  final bool loaded;
  final bool mosquesEnabled;
  final bool mosqueDonationsEnabled;
  final bool mosqueMembershipFeeEnabled;
  final int mosqueBroadcastsPerWeek;

  const AppConfigState({
    this.loaded = false,
    this.mosquesEnabled = true,
    this.mosqueDonationsEnabled = false,
    this.mosqueMembershipFeeEnabled = false,
    this.mosqueBroadcastsPerWeek = 2,
  });

  AppConfigState copyWith({
    bool? loaded,
    bool? mosquesEnabled,
    bool? mosqueDonationsEnabled,
    bool? mosqueMembershipFeeEnabled,
    int? mosqueBroadcastsPerWeek,
  }) =>
      AppConfigState(
        loaded: loaded ?? this.loaded,
        mosquesEnabled: mosquesEnabled ?? this.mosquesEnabled,
        mosqueDonationsEnabled: mosqueDonationsEnabled ?? this.mosqueDonationsEnabled,
        mosqueMembershipFeeEnabled: mosqueMembershipFeeEnabled ?? this.mosqueMembershipFeeEnabled,
        mosqueBroadcastsPerWeek: mosqueBroadcastsPerWeek ?? this.mosqueBroadcastsPerWeek,
      );

  @override
  List<Object?> get props => [loaded, mosquesEnabled, mosqueDonationsEnabled, mosqueMembershipFeeEnabled, mosqueBroadcastsPerWeek];
}

final appConfigProvider = StateNotifierProvider<AppConfigPresenter, AppConfigState>((ref) => AppConfigPresenter());

class AppConfigPresenter extends Presenter<AppConfigState> {
  AppConfigPresenter() : super(const AppConfigState());

  Future<void> load() async {
    try {
      final rows = await supabaseClient.from('app_config').select('key, value');
      final map = {for (final r in rows as List) r['key'] as String: r['value']};
      bool flag(String k, bool d) => map[k] is bool ? map[k] as bool : d;
      state = AppConfigState(
        loaded: true,
        mosquesEnabled: flag('mosques_enabled', true),
        mosqueDonationsEnabled: flag('mosque_donations_enabled', false),
        mosqueMembershipFeeEnabled: flag('mosque_membership_fee_enabled', false),
        mosqueBroadcastsPerWeek: (map['mosque_broadcasts_per_week'] as num?)?.toInt() ?? 2,
      );
    } catch (e, st) {
      talker.handle(e, st, 'app_config');
      state = state.copyWith(loaded: true);
    }
  }
}
