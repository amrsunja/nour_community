import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:nour/src/core/design_system/design_system.dart';

/// TODO(mosques): implemented in a later phase — placeholder keeps the router compiling.
@RoutePage()
class PushSettingsPage extends StatelessWidget {
  const PushSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return UIGradientLinedScaffold(
      appBar: UIAppBar(title: 'PushSettingsPage', onBack: () => context.router.maybePop()),
      body: const Center(child: UICircularProgressBar()),
    );
  }
}
