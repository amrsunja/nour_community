import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';
import 'package:nour/src/core/utils/constants/constants.dart';
import 'package:nour/gen/assets.gen.dart';
import 'package:nour/src/features/profile/ui/state_management/profile_provider.dart';

import '../state_management/auth_provider.dart';
import '../widgets/social_auth_button.dart';

@RoutePage()
class SignInPage extends HookConsumerWidget {
  const SignInPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = UITheme.of(context);
    final l10n = ref.watch(l10nProvider);
    final isLoading = ref.watch(authProvider.select((s) => s.isLoading));
    final notifier = ref.read(authProvider.notifier);

    final formKey = useMemoized(GlobalKey<FormState>.new);
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();

    Future<void> close() async {
      if (context.router.canPop()) {
        await context.router.maybePop();
      }
    }

    Future<void> onConnect() async {
      if (isLoading) return;
      if (!(formKey.currentState?.validate() ?? false)) return;
      FocusScope.of(context).unfocus();

      final ok = await notifier.linkWithEmail(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      if (!ok) return ;

      await ref.read(profileProvider.notifier).initProfile();
      await close();
    }

    Future<void> onGoogle() async {
      if (isLoading) return;
      if (await notifier.linkWithGoogle()) await close();
    }

    Future<void> onApple() async {
      if (isLoading) return;
      if (await notifier.linkWithApple()) await close();
    }

    return UIGradientLinedScaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          UIAppBar(onBack: close),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                kPageHorzPadding,
                8,
                kPageHorzPadding,
                16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            l10n.auth_connect_title,
                            textAlign: .center,
                            style: theme.typo.inter.largeTitle.copyWith(
                              color: UIColorsToken.white,
                            ),
                          ),
                          const UISpace.vert(8),
                          Text(
                            l10n.auth_connect_subtitle,
                            textAlign: TextAlign.center,
                            style: theme.typo.inter.bodyLarge.copyWith(
                              color: UIColorsToken.textParagraph,
                            ),
                          ),
                          const UISpace.vert(32),
                          Form(
                            key: formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                UIInputField(
                                  controller: emailController,
                                  labelText: l10n.auth_email,
                                  hintText: l10n.auth_email_hint,
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.next,
                                  validator: (value) => _validateEmail(value, l10n),
                                ),
                                const UISpace.vert(20),
                                UIInputField(
                                  controller: passwordController,
                                  labelText: l10n.auth_password,
                                  hintText: l10n.auth_password_hint,
                                  obscureText: true,
                                  textInputAction: TextInputAction.done,
                                  onSubmitted: (_) => onConnect(),
                                  validator: (value) =>
                                      _validatePassword(value, l10n),
                                ),
                              ],
                            ),
                          ),
                          const UISpace.vert(28),
                          _OrDivider(label: l10n.auth_or_sign_up_with),
                          const UISpace.vert(20),
                          Row(
                            children: [
                              Expanded(
                                child: SocialAuthButton(
                                  image: Assets.images.google,
                                  enabled: !isLoading,
                                  onTap: onGoogle,
                                ),
                              ),
                              const UISpace.horz(16),
                              Expanded(
                                child: SocialAuthButton(
                                  image: Assets.images.apple,
                                  enabled: !isLoading,
                                  onTap: onApple,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const UISpace.vert(12),
                  UIButton.primary(
                    label: l10n.auth_connect,
                    fullWidth: true,
                    isBusy: isLoading,
                    onTap: onConnect,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String? _validateEmail(String? value, AppLocale l10n) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return l10n.auth_email_required;
    final regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!regex.hasMatch(email)) return l10n.auth_email_invalid;
    return null;
  }

  String? _validatePassword(String? value, AppLocale l10n) {
    if ((value ?? '').length < 8) return l10n.auth_password_too_short;
    return null;
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = UITheme.of(context);
    final line = Expanded(
      child: Divider(color: UIColorsToken.stroke, height: 1),
    );

    return Row(
      children: [
        line,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            label,
            style: theme.typo.inter.bodyMedium.copyWith(
              color: UIColorsToken.textParagraph,
            ),
          ),
        ),
        line,
      ],
    );
  }
}
