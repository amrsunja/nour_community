import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/utils/state_management/presenter.dart';

import 'qibla_state.dart';

final qiblaProvider =
    StateNotifierProvider<QiblaPresenter, QiblaState>((ref) {
  return QiblaPresenter();
});

class QiblaPresenter extends Presenter<QiblaState> {
  QiblaPresenter() : super(QiblaState());

}
