import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/locale/l10n.dart';
import 'package:nour/src/core/utils/state_management/single_events.dart';

import '../../providers/widgets/snackbar_provider.dart';
import 'mixins.dart';

final appEventProvider = Provider((ref) => AppEvents());

final appEventsListenerProvider = Provider<void>((ref) {
  final events = ref.read(appEventProvider);

  final sub = events.singleEvents.listen((event) {
    final snackbar = ref.read(snackbarProvider);

    if (event is ShowErrorEvent) {
      snackbar.showError(event.message(
        ref.read(l10nProvider)
      ));
    } else if (event is ShowSuccessMessageEvent) {
      snackbar.showSuccess(event.message);
    } else if (event is ShowInfoMessageEvent) {
      snackbar.showInfo(event.message);
    }
  });

  ref.onDispose(sub.cancel);
});

class AppEvents with SingleEventMixin {
	AppEvents() : super();
}
