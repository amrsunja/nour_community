import 'package:flutter/material.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/utils/constants/constants.dart';

/// Shared layout of every mosque-onboarding step: scrollable content +
/// bottom action(s).
class MosqueOnboardingStepScaffold extends StatelessWidget {
  const MosqueOnboardingStepScaffold({
    super.key,
    required this.children,
    required this.bottom,
    this.centered = false,
  });

  final List<Widget> children;
  final Widget bottom;
  final bool centered;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: kPageHorzPadding),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisAlignment: centered ? MainAxisAlignment.center : MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: children,
              ),
            ),
          ),
          UIAppearAnimation(
            delay: const Duration(milliseconds: 700),
            offsetY: 16,
            child: bottom,
          ),
          const UISpace.vert(10),
        ],
      ),
    );
  }
}

/// Title + description block used by the three feature screens.
class MosqueOnboardingHeadline extends StatelessWidget {
  const MosqueOnboardingHeadline({super.key, required this.title, required this.description});

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = UITheme.of(context);
    return Column(
      children: [
        UIAppearAnimation(
          delay: const Duration(milliseconds: 400),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: theme.typo.inter.display.copyWith(color: UIColorsToken.white),
          ),
        ),
        const SizedBox(height: 12),
        UIAppearAnimation(
          delay: const Duration(milliseconds: 550),
          child: Text(
            description,
            textAlign: TextAlign.center,
            style: theme.typo.inter.bodyLarge.copyWith(color: UIColorsToken.textParagraph),
          ),
        ),
      ],
    );
  }
}
