import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';
import 'package:nour/src/core/network/supabase_client.dart';
import 'package:nour/src/core/providers/routing/navigation_services_provider.dart';
import 'package:nour/src/core/providers/widgets/snackbar_provider.dart';
import 'package:nour/src/core/utils/constants/constants.dart';
import 'package:nour/src/core/utils/state_management/app_events.dart';
import 'package:nour/src/core/utils/state_management/single_events.dart';
import 'package:nour/src/features/profile/ui/state_management/profile_provider.dart';
import 'package:nour/src/features/settings/ui/state_management/app_config_provider.dart';

import '../../data/mosque_repo.dart';
import '../state_management/mosque_profile_provider.dart';

/// "Join our membership" form (Figma 1105:5936) + optional yearly
/// contribution (60 / 120 / 240 € or custom, P3 checkout).
@RoutePage()
class MosqueBecomeMemberPage extends HookConsumerWidget {
  const MosqueBecomeMemberPage({super.key, @PathParam('id') required this.mosqueId});

  final int mosqueId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = UITheme.of(context);
    final l10n = ref.watch(l10nProvider);
    final nav = ref.read(navigationServicesProvider);
    final snackbar = ref.read(snackbarProvider);
    final appEvents = ref.read(appEventProvider);
    final profile = ref.watch(profileProvider).profile;
    final feeEnabled = ref.watch(appConfigProvider.select((c) => c.mosqueMembershipFeeEnabled && c.mosqueDonationsEnabled));
    final mosque = ref.watch(mosqueProfileProvider(mosqueId).select((s) => s.mosque));

    final formKey = useMemoized(GlobalKey<FormState>.new);
    final nameParts = (profile?.name ?? '').trim().split(RegExp(r'\s+'));
    final firstName = useTextEditingController(text: nameParts.isNotEmpty ? nameParts.first : '');
    final lastName = useTextEditingController(text: nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '');
    final profession = useTextEditingController();
    final email = useTextEditingController(text: supabaseClient.auth.currentUser?.email ?? '');
    final phone = useTextEditingController();
    final birthDate = useState<DateTime?>(null);
    final volunteer = useState<bool?>(null);
    final consent = useState(false);
    final contribute = useState(false);
    final feeAmount = useState<double?>(120);
    final customFee = useTextEditingController();
    final isLoading = useState(false);

    Future<void> pickBirthDate() async {
      final now = DateTime.now();
      final picked = await showDatePicker(
        context: context,
        initialDate: birthDate.value ?? DateTime(now.year - 25),
        firstDate: DateTime(1900),
        lastDate: now,
      );
      if (picked != null) birthDate.value = picked;
    }

    Future<void> submit() async {
      if (!(formKey.currentState?.validate() ?? false)) return;
      if (birthDate.value == null || volunteer.value == null || !consent.value) {
        snackbar.showError(l10n.mosque_member_fill_required);
        return;
      }
      isLoading.value = true;
      final res = await ref.read(mosqueRepoProvider).joinAsMember({
        'mosque_id': mosqueId,
        'first_name': firstName.text.trim(),
        'last_name': lastName.text.trim(),
        'birth_date': DateFormat('yyyy-MM-dd').format(birthDate.value!),
        'profession': profession.text.trim().isEmpty ? null : profession.text.trim(),
        'email': email.text.trim(),
        'phone': phone.text.trim(),
        'volunteer': volunteer.value,
      });
      isLoading.value = false;
      await res.when(
        (member) async {
          ref.read(mosqueProfileProvider(mosqueId).notifier).setMembership(member);
          final amount = contribute.value
              ? (feeAmount.value ?? double.tryParse(customFee.text.replaceAll(',', '.')))
              : null;
          if (feeEnabled && amount != null && amount > 0) {
            if (!context.mounted) return;
            await context.router.maybePop();
            nav.toMosqueCheckout(mosqueId: mosqueId, amount: amount, frequency: 'yearly', membershipId: member.id);
            return;
          }
          snackbar.showSuccess(l10n.mosque_member_welcome);
          if (context.mounted) await context.router.maybePop();
        },
        (error) async => appEvents.send(ShowErrorEvent(error)),
      );
    }

    return UIGradientLinedScaffold(
      appBar: UIAppBar(onBack: () => context.router.maybePop()),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(kPageHorzPadding, 8, kPageHorzPadding, 24),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(l10n.mosque_member_title, textAlign: TextAlign.center, style: theme.typo.inter.largeTitle.copyWith(color: UIColorsToken.white)),
                    const SizedBox(height: 6),
                    Text(l10n.mosque_member_subtitle, textAlign: TextAlign.center, style: theme.typo.inter.bodySmall.copyWith(color: UIColorsToken.textParagraph)),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: UIInputField(
                            controller: firstName,
                            labelText: '${l10n.mosque_member_first_name}*',
                            hintText: 'Ismael',
                            validator: (v) => (v ?? '').trim().isEmpty ? l10n.common_required_field : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: UIInputField(
                            controller: lastName,
                            labelText: '${l10n.mosque_member_last_name}*',
                            hintText: 'YASSA',
                            validator: (v) => (v ?? '').trim().isEmpty ? l10n.common_required_field : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text('${l10n.mosque_member_birth_date}*', style: theme.typo.inter.bodyMedium.copyWith(color: UIColorsToken.white)),
                    const SizedBox(height: 8),
                    UITap(
                      onTap: pickBirthDate,
                      child: Container(
                        height: 52,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        alignment: AlignmentDirectional.centerStart,
                        decoration: BoxDecoration(color: UIColorsToken.bgSurface, borderRadius: BorderRadius.circular(10)),
                        child: Text(
                          birthDate.value == null ? 'DD/MM/YYYY' : DateFormat('dd/MM/yyyy').format(birthDate.value!),
                          style: theme.typo.inter.body.copyWith(color: birthDate.value == null ? UIColorsToken.textParagraph : UIColorsToken.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    UIInputField(controller: profession, labelText: l10n.mosque_member_profession, hintText: 'Painter'),
                    const SizedBox(height: 16),
                    UIInputField(
                      controller: email,
                      labelText: '${l10n.auth_email}*',
                      hintText: l10n.auth_email_hint,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) => RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch((v ?? '').trim()) ? null : l10n.auth_email_invalid,
                    ),
                    const SizedBox(height: 16),
                    UIInputField(
                      controller: phone,
                      labelText: '${l10n.mosque_member_phone}*',
                      hintText: '+33 6 45 36 27 32',
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.done,
                      validator: (v) => (v ?? '').trim().length < 6 ? l10n.common_required_field : null,
                    ),
                    const SizedBox(height: 16),
                    Text('${l10n.mosque_member_volunteer_question}*', style: theme.typo.inter.bodyMedium.copyWith(color: UIColorsToken.white)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(child: _Choice(label: l10n.common_yes, selected: volunteer.value == true, onTap: () => volunteer.value = true)),
                        const SizedBox(width: 12),
                        Expanded(child: _Choice(label: l10n.common_no, selected: volunteer.value == false, onTap: () => volunteer.value = false)),
                      ],
                    ),
                    if (feeEnabled) ...[
                      const SizedBox(height: 20),
                      UICard(
                        padding: const EdgeInsets.all(16),
                        colors: const [Color(0xff2C3427), Color(0xff1A1A1A)],
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(l10n.mosque_member_fee_optional, style: theme.typo.inter.smallCaption.copyWith(color: UIColorsToken.textYellow)),
                                      Text(l10n.mosque_member_fee_title, style: theme.typo.inter.title.copyWith(color: UIColorsToken.white)),
                                    ],
                                  ),
                                ),
                                UIToggle(checked: contribute.value, onCheck: (v) => contribute.value = v),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(l10n.mosque_member_fee_hint, style: theme.typo.inter.caption.copyWith(color: UIColorsToken.textParagraph)),
                            if (contribute.value) ...[
                              const SizedBox(height: 14),
                              Text(l10n.mosque_member_fee_choose, style: theme.typo.inter.bodyMedium.copyWith(color: UIColorsToken.white)),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  for (final a in const [60.0, 120.0, 240.0]) ...[
                                    Expanded(
                                      child: _Choice(
                                        label: '${a.toInt()}€',
                                        selected: feeAmount.value == a,
                                        onTap: () {
                                          feeAmount.value = a;
                                          customFee.clear();
                                        },
                                      ),
                                    ),
                                    if (a != 240.0) const SizedBox(width: 8),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 10),
                              UIInputField(
                                controller: customFee,
                                hintText: l10n.mosque_donation_enter_amount,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                onChanged: (v) => feeAmount.value = v.trim().isEmpty ? 120 : null,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    UITap(
                      onTap: () => consent.value = !consent.value,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(consent.value ? Icons.check_box : Icons.check_box_outline_blank,
                              color: consent.value ? UIColorsToken.textYellow : UIColorsToken.textParagraph, size: 22),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(l10n.mosque_member_consent, style: theme.typo.inter.caption.copyWith(color: UIColorsToken.textParagraph)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(kPageHorzPadding, 8, kPageHorzPadding, 16),
            child: UIButton.primary(
              label: l10n.mosque_member_register,
              fullWidth: true,
              isBusy: isLoading.value,
              onTap: submit,
            ),
          ),
        ],
      ),
    );
  }
}

class _Choice extends StatelessWidget {
  const _Choice({required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = UITheme.of(context);
    return UITap(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? const Color(0xff252219) : UIColorsToken.bgSurface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: selected ? UIColorsToken.textYellow : Colors.transparent, width: 1.5),
        ),
        child: Text(label, style: theme.typo.inter.bodyMedium.copyWith(color: selected ? UIColorsToken.textYellow : UIColorsToken.white)),
      ),
    );
  }
}
