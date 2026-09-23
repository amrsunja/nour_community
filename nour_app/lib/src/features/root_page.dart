import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/widgets/splash_widget.dart';

import 'package:nour/src/core/routing/deep_links_services.dart';

import 'auth/ui/state_management/auth_provider.dart';
import 'notifications/ui/state_management/push_provider.dart';

@RoutePage()
class RootPage extends HookConsumerWidget {
  const RootPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final initFuture = useMemoized(() async {
      // Delay for logo animation
      await Future.delayed(Duration(seconds: 3));

      await ref.read(authProvider.notifier).authorization();

      // Push: FCM init + replay of the notification that launched the app.
      final push = ref.read(pushProvider.notifier);
      await push.initialize();
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await push.consumeInitialMessage();
        await ref.read(deepLinksServicesProvider).flushPending();
      });
    });

    return FutureBuilder(
      future: initFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == .waiting) {
          return SplashWidget();
        }
        return AutoRouter(
          placeholder: (context) => SplashWidget(
            playSound: false,
          ),
        );
      },
    );
  }
}
