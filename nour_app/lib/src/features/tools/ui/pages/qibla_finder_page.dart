import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';

import '../state_management/qibla_provider.dart';

@RoutePage()
class QiblaFinderPage extends HookConsumerWidget {
  const QiblaFinderPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(l10nProvider);
    final presenter = ref.read(qiblaProvider.notifier);
    final state = ref.watch(qiblaProvider);

    return UIGradientLinedScaffold(
      bgArabicText: 'القبلة',
      appBar: UIAppBar(
        title: l10n.tools_qibla_finder,
        onBack: context.pop,
      ),
      body: SafeArea(top: false, bottom: false, child: Container()),
    );
  }
}
