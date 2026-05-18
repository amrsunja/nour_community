import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:nour/src/core/design_system/design_system.dart';

@RoutePage()
class SignInPage extends StatelessWidget {
  const SignInPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: .all(20),
        children: [
          UIButton.primary(
            label: 'Button text',
            assetIcon: UIIconsToken.icons.home,
            onTap: () {}
          ),
          UIButton.secondary(
            label: 'Button text',
            assetIcon: UIIconsToken.icons.home,
            onTap: () {}
          ),
          UIButton.textual(
            label: 'Button text',
            assetIcon: UIIconsToken.icons.home,
            onTap: () {}
          ),
        ],
      ),
    ).animate(effects: [FadeEffect(duration: Duration(milliseconds: 600))]);
  }
}
