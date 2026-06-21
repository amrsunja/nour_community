import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../audio/sound_effect_service.dart';

final soundEffectServiceProvider = Provider((ref) {
  final service = SoundEffectService();
  ref.onDispose(service.dispose);
  return service;
});
