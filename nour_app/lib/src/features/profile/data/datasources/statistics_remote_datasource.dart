import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/errors/exceptions/server/server_exception.dart';
import 'package:nour/src/core/network/supabase_client.dart';
import 'package:nour/src/core/utils/talker/talker.dart';

import '../models/statistics_models.dart';

final statisticsRemoteDataProvider = Provider(
  (ref) => StatisticsRemoteDatasource(),
);

class StatisticsRemoteDatasource {
  /// Single round-trip aggregate via the `fn_user_statistics` RPC. The function
  /// scopes to the caller through `auth.uid()`, so no user filter is needed
  /// client-side. [range] maps to the `p_from` lower bound.
  Future<UserStatistics> fetchStatistics(StatRange range) async {
    if (supabaseClient.auth.currentUser == null) {
      throw ServerException(
        type: .unauthorized,
        messageKey: ApiErrorKey.userNotAuthenticated,
      );
    }

    try {
      final from = range.from;
      final rows = await supabaseClient.rpc(
        'fn_user_statistics',
        params: {'p_from': from?.toUtc().toIso8601String()},
      );

      final list = rows as List;
      if (list.isEmpty) return const UserStatistics.empty();

      return UserStatistics.fromJson(
        Map<String, dynamic>.from(list.first as Map),
      );
    } catch (e) {
      talker.error(e);
      throw ServerException(
        type: .badRequest,
        messageKey: ApiErrorKey.statisticsLoadFailed,
      );
    }
  }
}
