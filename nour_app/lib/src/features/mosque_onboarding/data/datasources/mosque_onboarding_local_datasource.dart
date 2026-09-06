import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/mosque_onboarding_draft.dart';

final mosqueOnboardingLocalDataProvider = Provider(
  (ref) => MosqueOnboardingLocalDatasource(),
);

/// SharedPreferences-backed draft of the sessionless mosque onboarding.
class MosqueOnboardingLocalDatasource {
  static const _key = 'mosque_onboarding_draft_v1';

  Future<MosqueOnboardingDraft?> read() async {
    final prefs = await SharedPreferences.getInstance();
    return MosqueOnboardingDraft.decode(prefs.getString(_key));
  }

  Future<void> write(MosqueOnboardingDraft draft) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, draft.encode());
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
