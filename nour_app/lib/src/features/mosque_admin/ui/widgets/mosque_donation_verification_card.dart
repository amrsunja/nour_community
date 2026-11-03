import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';
import 'package:nour/src/features/mosques/data/models/mosque_donation_models.dart';
import 'package:nour/src/features/mosques/ui/state_management/my_mosque_provider.dart';

import '../state_management/mosque_admin_donation_provider.dart';
import 'mosque_admin_form_widgets.dart';

/// The mosque's request to receive donations: status, and the Benevity details
/// form while there is no request yet or the last one was not approved.
class MosqueDonationVerificationCard extends HookConsumerWidget {
  const MosqueDonationVerificationCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = UITheme.of(context);
    final l10n = ref.watch(l10nProvider);
    final state = ref.watch(mosqueAdminDonationProvider);
    final presenter = ref.read(mosqueAdminDonationProvider.notifier);
    final verification = state.verification;
    final mosqueLegalName = ref.watch(myMosqueProvider.select((s) => s.mosque?.legalName));

    final charityId = useTextEditingController();
    final legalName = useTextEditingController();
    final certificate = useTextEditingController();
    final notes = useTextEditingController();
    useListenable(charityId);
    useListenable(legalName);

    // Prefill from the last request (or the registration's legal name).
    useEffect(() {
      charityId.text = verification?.benevityCharityId ?? '';
      legalName.text = verification?.legalName ?? mosqueLegalName ?? '';
      certificate.text = verification?.certificateUrl ?? '';
      notes.text = verification?.notes ?? '';
      return null;
    }, [verification]);

    final status = verification?.status;
    final showForm = status == null || status == MosqueDonationVerificationStatus.rejected;
    final (statusLabel, statusColor) = switch (status) {
      MosqueDonationVerificationStatus.approved => (l10n.mosque_admin_verification_status_approved, UIColorsToken.green),
      MosqueDonationVerificationStatus.pending => (l10n.mosque_admin_verification_status_pending, UIColorsToken.yellow),
      MosqueDonationVerificationStatus.rejected => (l10n.mosque_admin_verification_status_rejected, UIColorsToken.red),
      null => (null, UIColorsToken.textParagraph),
    };
    final message = switch (status) {
      MosqueDonationVerificationStatus.approved => l10n.mosque_admin_verification_approved_message,
      MosqueDonationVerificationStatus.pending => l10n.mosque_admin_verification_pending_message,
      MosqueDonationVerificationStatus.rejected => l10n.mosque_admin_verification_rejected_message,
      null => l10n.mosque_admin_verification_intro,
    };

    return UICard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(l10n.mosque_admin_verification_title, style: theme.typo.inter.title.copyWith(color: UIColorsToken.white, fontWeight: FontWeight.w600)),
              ),
              if (statusLabel != null) Text(statusLabel, style: theme.typo.inter.caption.copyWith(color: statusColor, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 8),
          Text(message, style: theme.typo.inter.bodySmall.copyWith(color: UIColorsToken.textParagraph)),
          if ((verification?.reviewNote ?? '').isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(verification!.reviewNote!, style: theme.typo.inter.bodySmall.copyWith(color: UIColorsToken.textYellow)),
          ],
          if (showForm) ...[
            const SizedBox(height: 16),
            AdminLabel(l10n.mosque_admin_verification_benevity_id),
            UIInputField(controller: charityId, bgColor: UIColorsToken.black),
            const SizedBox(height: 12),
            AdminLabel(l10n.mosque_admin_verification_legal_name),
            UIInputField(controller: legalName, bgColor: UIColorsToken.black),
            const SizedBox(height: 12),
            AdminLabel(l10n.mosque_admin_verification_certificate, optional: true, l10n: l10n),
            UIInputField(controller: certificate, keyboardType: TextInputType.url, bgColor: UIColorsToken.black),
            const SizedBox(height: 12),
            AdminLabel(l10n.mosque_admin_verification_notes, optional: true, l10n: l10n),
            AdminTextArea(controller: notes, minLines: 2, maxLines: 4, bgColor: UIColorsToken.black),
            const SizedBox(height: 16),
            UIButton.primary(
              label: l10n.mosque_admin_verification_submit,
              fullWidth: true,
              isBusy: state.busy,
              onTap: charityId.text.trim().isEmpty || legalName.text.trim().isEmpty
                  ? null
                  : () => presenter.requestVerification(
                        benevityCharityId: charityId.text.trim(),
                        legalName: legalName.text.trim(),
                        certificateUrl: certificate.text.trim(),
                        notes: notes.text.trim(),
                      ),
            ),
          ],
        ],
      ),
    );
  }
}
