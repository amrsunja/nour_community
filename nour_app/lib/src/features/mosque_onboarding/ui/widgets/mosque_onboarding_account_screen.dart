import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/gen/assets.gen.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';
import 'package:nour/src/features/analytics/data/analytics_repo.dart';
import 'package:nour/src/features/auth/ui/state_management/auth_provider.dart';
import 'package:nour/src/features/auth/ui/widgets/social_auth_button.dart';

import '../state_management/mosque_onboarding_provider.dart';
import 'mosque_onboarding_scaffold.dart';

const _kResendCooldown = 60;

/// "Let's create your account" (Figma Onboarding 23). Same methods as the
/// worshipper sign-in (email OTP, Google, Apple) — there is NO session at this
/// point, so the datasource falls back to plain sign-in / sign-up. Once the
/// session exists [AuthPresenter._afterLogin] registers the mosque from the
/// pending draft (§3.1) and navigates; this screen never pops itself.
class MosqueOnboardingAccountScreen extends HookConsumerWidget {
  const MosqueOnboardingAccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = UITheme.of(context);
    final l10n = ref.watch(l10nProvider);
    final auth = ref.read(authProvider.notifier);
    final isLoading = ref.watch(authProvider.select((s) => s.isLoading));
    final analytics = ref.read(analyticsRepoProvider);

    final formKey = useMemoized(GlobalKey<FormState>.new);
    final emailController = useTextEditingController();
    final otpController = useTextEditingController();
    final codeSent = useState(false);
    final secondsLeft = useState(0);

    useEffect(() {
      if (secondsLeft.value <= 0) return null;
      final timer = Timer(const Duration(seconds: 1), () => secondsLeft.value -= 1);
      return timer.cancel;
    }, [secondsLeft.value]);

    // The draft must be attached before ANY auth call so the presenter can
    // register the mosque right after the session is created.
    void attachDraft() => auth.setPendingMosqueDraft(ref.read(mosqueOnboardingProvider).draft);

    Future<void> onSubmit() async {
      if (isLoading) return;
      if (!(formKey.currentState?.validate() ?? false)) return;
      FocusScope.of(context).unfocus();
      attachDraft();

      if (!codeSent.value) {
        analytics.trackSignInClick(method: 'email');
        final res = await auth.connectEmail(email: emailController.text.trim());
        if (res == EmailConnectResult.otpSent) {
          codeSent.value = true;
          secondsLeft.value = _kResendCooldown;
        }
        return;
      }

      await auth.linkEmailWithOTP(
        email: emailController.text.trim(),
        token: otpController.text.trim(),
      );
    }

    Future<void> onResend() async {
      if (isLoading || secondsLeft.value > 0) return;
      attachDraft();
      if (await auth.connectEmail(email: emailController.text.trim()) == EmailConnectResult.otpSent) {
        secondsLeft.value = _kResendCooldown;
      }
    }

    Future<void> onGoogle() async {
      if (isLoading) return;
      analytics.trackSignInClick(method: 'google');
      attachDraft();
      await auth.linkWithGoogle();
    }

    Future<void> onApple() async {
      if (isLoading) return;
      analytics.trackSignInClick(method: 'apple');
      attachDraft();
      await auth.linkWithApple();
    }

    final canResend = secondsLeft.value == 0 && !isLoading;

    return MosqueOnboardingStepScaffold(
      children: [
        const UISpace.vert(60),
        UIAppearAnimation(
          delay: const Duration(milliseconds: 100),
          child: Text(
            l10n.mosque_account_title,
            textAlign: TextAlign.center,
            style: theme.typo.inter.largeTitle.copyWith(color: UIColorsToken.white),
          ),
        ),
        const SizedBox(height: 8),
        UIAppearAnimation(
          delay: const Duration(milliseconds: 200),
          child: Text(
            l10n.mosque_account_subtitle,
            textAlign: TextAlign.center,
            style: theme.typo.inter.bodyLarge.copyWith(color: UIColorsToken.textParagraph),
          ),
        ),
        const SizedBox(height: 32),
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
                textInputAction: codeSent.value ? TextInputAction.done : TextInputAction.next,
                onSubmitted: (_) => onSubmit(),
                validator: (value) {
                  final email = value?.trim() ?? '';
                  if (email.isEmpty) return l10n.auth_email_required;
                  if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) return l10n.auth_email_invalid;
                  return null;
                },
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                alignment: Alignment.topCenter,
                child: codeSent.value
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const UISpace.vert(20),
                          UIInputField(
                            controller: otpController,
                            labelText: l10n.auth_otp,
                            hintText: l10n.auth_otp_hint,
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) => onSubmit(),
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(8),
                            ],
                            validator: (v) {
                              final code = v?.trim() ?? '';
                              if (code.isEmpty) return l10n.auth_otp_required;
                              if (code.length != 8) return l10n.auth_otp_invalid;
                              return null;
                            },
                          ),
                          const UISpace.vert(8),
                          Align(
                            alignment: AlignmentDirectional.centerEnd,
                            child: UIButton.textual(
                              label: canResend
                                  ? l10n.auth_resend_code
                                  : '${l10n.auth_resend_code} (${secondsLeft.value} s)',
                              isSmall: true,
                              contentColor: canResend ? null : UIColorsToken.textParagraph,
                              onTap: canResend ? onResend : null,
                            ),
                          ),
                        ],
                      )
                    : const SizedBox(width: double.infinity),
              ),
            ],
          ),
        ),
        const UISpace.vert(28),
        Row(
          children: [
            Expanded(child: Divider(color: UIColorsToken.stroke, height: 1)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                l10n.auth_or_sign_up_with,
                style: theme.typo.inter.bodyMedium.copyWith(color: UIColorsToken.textParagraph),
              ),
            ),
            Expanded(child: Divider(color: UIColorsToken.stroke, height: 1)),
          ],
        ),
        const UISpace.vert(20),
        Row(
          children: [
            Expanded(
              child: SocialAuthButton(image: Assets.images.google, enabled: !isLoading, onTap: onGoogle),
            ),
            if (Platform.isIOS) ...[
              const UISpace.horz(16),
              Expanded(
                child: SocialAuthButton(image: Assets.images.apple, enabled: !isLoading, onTap: onApple),
              ),
            ],
          ],
        ),
        const UISpace.vert(24),
        Text(
          l10n.mosque_account_existing_hint,
          textAlign: TextAlign.center,
          style: theme.typo.inter.bodySmall.copyWith(color: UIColorsToken.textParagraph),
        ),
      ],
      bottom: UIButton.primary(
        label: codeSent.value ? l10n.auth_connect : l10n.mosque_account_cta,
        fullWidth: true,
        isBusy: isLoading,
        onTap: onSubmit,
      ),
    );
  }
}
