import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';
import 'package:nour/src/core/utils/constants/constants.dart';
import 'package:nour/gen/assets.gen.dart';
import 'package:nour/src/features/profile/ui/state_management/profile_provider.dart';

import '../state_management/auth_provider.dart';
import '../widgets/social_auth_button.dart';

const _kResendCooldown = 60;

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
    final otpController = useTextEditingController();

    final codeSent = useState(false);
    final secondsLeft = useState(0);

    // Self-rescheduling 1s tick: decrements until it reaches zero.
    useEffect(() {
      if (secondsLeft.value <= 0) return null;
      final timer = Timer(const Duration(seconds: 1), () {
        secondsLeft.value -= 1;
      });
      return timer.cancel;
    }, [secondsLeft.value]);

    Future<void> close() async {
      if (context.router.canPop()) {
        await context.router.maybePop();
      }
    }

    Future<EmailConnectResult> sendCode() {
      return notifier.connectEmail(email: emailController.text.trim());
    }

    Future<void> onSubmit() async {
      if (isLoading) return;
      if (!(formKey.currentState?.validate() ?? false)) return;
      FocusScope.of(context).unfocus();

      if (!codeSent.value) {
        final res = await sendCode();
        switch (res) {
          case EmailConnectResult.failed:
            return;
          case EmailConnectResult.linked:
            // New email: linked instantly, already authenticated.
            await close();
            return;
          case EmailConnectResult.otpSent:
            codeSent.value = true;
            secondsLeft.value = _kResendCooldown;
            return;
        }
      }

      final ok = await notifier.linkEmailWithOTP(
        email: emailController.text.trim(),
        token: otpController.text.trim(),
      );
      if (!ok) return;

      await ref.read(profileProvider.notifier).initProfile();
      await close();
    }

    Future<void> onResend() async {
      if (isLoading || secondsLeft.value > 0) return;
      if (await sendCode() == EmailConnectResult.otpSent) {
        secondsLeft.value = _kResendCooldown;
      }
    }

    Future<void> onGoogle() async {
      if (isLoading) return;
      if (await notifier.linkWithGoogle()) await close();
    }

    Future<void> onApple() async {
      if (isLoading) return;
      if (await notifier.linkWithApple()) await close();
    }

    final canResend = secondsLeft.value == 0 && !isLoading;

    return UIGradientLinedScaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          UIAppBar(
            onBack: close,
            leadingIcons: [
              UITap(
                onTap: () => context.pop(),
                child: Text(
                  l10n.common_maybe_later,
                  style: theme.typo.inter.bodyMedium,
                ),
              ),
            ],
          ),
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
                    child: Center(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              l10n.auth_connect_title,
                              textAlign: TextAlign.center,
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
                                    enabled: !codeSent.value,
                                    textInputAction: codeSent.value
                                        ? TextInputAction.done
                                        : TextInputAction.next,
                                    onSubmitted: (_) => onSubmit(),
                                    validator: (value) =>
                                        _validateEmail(value, l10n),
                                  ),
                                  AnimatedSize(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeOutCubic,
                                    alignment: Alignment.topCenter,
                                    child: codeSent.value
                                        ? _OtpSection(
                                            controller: otpController,
                                            l10n: l10n,
                                            canResend: canResend,
                                            secondsLeft: secondsLeft.value,
                                            onResend: onResend,
                                            onSubmitted: onSubmit,
                                          )
                                        : const SizedBox(
                                            width: double.infinity,
                                          ),
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
                  ),
                  const UISpace.vert(12),
                  UIButton.primary(
                    label:l10n.auth_connect,
                    fullWidth: true,
                    isBusy: isLoading,
                    onTap: onSubmit,
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
}

class _OtpSection extends StatelessWidget {
  const _OtpSection({
    required this.controller,
    required this.l10n,
    required this.canResend,
    required this.secondsLeft,
    required this.onResend,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final AppLocale l10n;
  final bool canResend;
  final int secondsLeft;
  final VoidCallback onResend;
  final VoidCallback onSubmitted;

  @override
  Widget build(BuildContext context) {
    return UIAppearAnimation(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const UISpace.vert(20),
          UIInputField(
            controller: controller,
            labelText: l10n.auth_otp,
            hintText: l10n.auth_otp_hint,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => onSubmitted(),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(8),
            ],
            validator: (value) => _validateOtp(value, l10n),
          ),
          const UISpace.vert(8),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: UIButton.textual(
              label: canResend
                  ? l10n.auth_resend_code
                  : '${l10n.auth_resend_code} ($secondsLeft s)',
              isSmall: true,
              contentColor: canResend ? null : UIColorsToken.textParagraph,
              onTap: canResend ? onResend : null,
            ),
          ),
        ],
      ),
    );
  }

  String? _validateOtp(String? value, AppLocale l10n) {
    final code = value?.trim() ?? '';
    if (code.isEmpty) return l10n.auth_otp_required;
    if (code.length != 8) return l10n.auth_otp_invalid;
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
