import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/widgets/splash_widget.dart';

import 'auth/ui/state_management/auth_provider.dart';

@RoutePage()
class RootPage extends HookConsumerWidget {
  const RootPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final initFuture = useMemoized(() async {
      await ref.read(authProvider.notifier).isAuthorized();
    });

    return FutureBuilder(
      future: initFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == .waiting) {
          return SplashWidget();
        }
        return AutoRouter(
          placeholder: (context) => SplashWidget(),
        );
      },
    );
  }
}
