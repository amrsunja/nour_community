import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';
import 'package:nour/src/features/mosques/data/models/mosque_enums.dart';

import '../../data/models/mosque_onboarding_draft.dart';
import '../state_management/mosque_onboarding_provider.dart';
import 'mosque_onboarding_scaffold.dart';

/// "Let's register your mosque" (Figma Onboarding 31): legal name, legal
/// status, RNA, SIREN. Values are kept in the local draft until the account
/// exists (§3.3).
class MosqueOnboardingRegisterScreen extends HookConsumerWidget {
  const MosqueOnboardingRegisterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = UITheme.of(context);
    final l10n = ref.watch(l10nProvider);
    final presenter = ref.read(mosqueOnboardingProvider.notifier);
    final draft = ref.watch(mosqueOnboardingProvider.select((s) => s.draft));

    final formKey = useMemoized(GlobalKey<FormState>.new);
    final nameController = useTextEditingController(text: draft.legalName ?? '');
    final rnaController = useTextEditingController(text: draft.rna ?? '');
    final sirenController = useTextEditingController(text: draft.siren ?? '');
    final legalStatus = useState<MosqueLegalStatus?>(draft.legalStatus);

    String statusLabel(MosqueLegalStatus s) => switch (s) {
          MosqueLegalStatus.association1901 => l10n.mosque_legal_status_1901,
          MosqueLegalStatus.association1905 => l10n.mosque_legal_status_1905,
          MosqueLegalStatus.other => l10n.mosque_legal_status_other,
        };

    Future<void> pickStatus() async {
      final picked = await showModalBottomSheet<MosqueLegalStatus>(
        context: context,
        backgroundColor: UIColorsToken.bgSurface,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (ctx) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              Text(l10n.mosque_register_legal_status,
                  style: theme.typo.inter.title.copyWith(color: UIColorsToken.white)),
              const SizedBox(height: 8),
              for (final s in MosqueLegalStatus.values)
                ListTile(
                  title: Text(statusLabel(s), style: theme.typo.inter.body.copyWith(color: UIColorsToken.white)),
                  trailing: legalStatus.value == s
                      ? const Icon(Icons.check, color: UIColorsToken.textYellow)
                      : null,
                  onTap: () => Navigator.of(ctx).pop(s),
                ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      );
      if (picked != null) legalStatus.value = picked;
    }

    Future<void> onRegister() async {
      if (!(formKey.currentState?.validate() ?? false)) return;
      if (legalStatus.value == null) return;
      FocusScope.of(context).unfocus();
      await presenter.setRegistration(
        legalName: nameController.text,
        legalStatus: legalStatus.value!,
        rna: rnaController.text,
        siren: sirenController.text,
      );
      await presenter.next();
    }

    final rnaRequired = legalStatus.value != MosqueLegalStatus.other;

    return MosqueOnboardingStepScaffold(
      children: [
        const UISpace.vert(60),
        UIAppearAnimation(
          delay: const Duration(milliseconds: 100),
          child: Text(
            l10n.mosque_register_title,
            textAlign: TextAlign.center,
            style: theme.typo.inter.largeTitle.copyWith(color: UIColorsToken.white),
          ),
        ),
        const SizedBox(height: 28),
        Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              UIAppearAnimation(
                delay: const Duration(milliseconds: 250),
                offsetY: 16,
                child: UIInputField(
                  controller: nameController,
                  labelText: l10n.mosque_register_legal_name,
                  hintText: l10n.mosque_register_legal_name_hint,
                  keyboardType: TextInputType.name,
                  validator: (v) => (v ?? '').trim().length < 2 ? l10n.common_required_field : null,
                ),
              ),
              const SizedBox(height: 20),
              UIAppearAnimation(
                delay: const Duration(milliseconds: 350),
                offsetY: 16,
                child: _SelectField(
                  label: l10n.mosque_register_legal_status,
                  value: legalStatus.value == null ? null : statusLabel(legalStatus.value!),
                  placeholder: l10n.mosque_register_legal_status_hint,
                  onTap: pickStatus,
                ),
              ),
              const SizedBox(height: 20),
              UIAppearAnimation(
                delay: const Duration(milliseconds: 450),
                offsetY: 16,
                child: UIInputField(
                  controller: rnaController,
                  labelText: rnaRequired ? l10n.mosque_register_rna : '${l10n.mosque_register_rna} · ${l10n.common_optional}',
                  hintText: 'W751123456',
                  keyboardType: TextInputType.text,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[wW0-9]')),
                    LengthLimitingTextInputFormatter(10),
                  ],
                  validator: (v) {
                    final t = (v ?? '').trim();
                    if (t.isEmpty) return rnaRequired ? l10n.common_required_field : null;
                    return MosqueOnboardingDraft.isValidRna(t) ? null : l10n.mosque_register_rna_invalid;
                  },
                ),
              ),
              const SizedBox(height: 20),
              UIAppearAnimation(
                delay: const Duration(milliseconds: 550),
                offsetY: 16,
                child: UIInputField(
                  controller: sirenController,
                  labelText: l10n.mosque_register_siren,
                  hintText: '384 719 288',
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(9),
                  ],
                  validator: (v) =>
                      MosqueOnboardingDraft.isValidSiren(v ?? '') ? null : l10n.mosque_register_siren_invalid,
                ),
              ),
            ],
          ),
        ),
      ],
      bottom: UIButton.primary(
        label: l10n.mosque_register_cta,
        fullWidth: true,
        onTap: onRegister,
      ),
    );
  }
}

class _SelectField extends StatelessWidget {
  const _SelectField({required this.label, required this.value, required this.placeholder, required this.onTap});
  final String label;
  final String? value;
  final String placeholder;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = UITheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.typo.inter.bodyMedium.copyWith(color: UIColorsToken.white)),
        const SizedBox(height: 8),
        UITap(
          onTap: onTap,
          child: Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: UIColorsToken.bgSurface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: UIColorsToken.stroke.withValues(alpha: .2)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value ?? placeholder,
                    style: theme.typo.inter.body.copyWith(
                      color: value == null ? UIColorsToken.textParagraph : UIColorsToken.white,
                    ),
                  ),
                ),
                const Icon(Icons.expand_more, color: UIColorsToken.textYellow),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
