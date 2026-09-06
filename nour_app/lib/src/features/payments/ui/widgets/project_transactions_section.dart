import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';
import 'package:nour/src/features/impact/ui/widgets/impact_money.dart';
import 'package:nour/src/features/payments/data/models/payout_model.dart';

import '../state_management/project_payouts_provider.dart';
import 'payout_proof_image.dart';

/// The "Transactions" transparency block on a project detail page: shows the
/// confirmed disbursement proofs (justificatifs de décaissement) so donors can
/// see how collected funds were used. Reads only `confirmed` payouts (RLS).
class ProjectTransactionsSection extends ConsumerWidget {
  const ProjectTransactionsSection({
    super.key,
    required this.projectId,
    required this.currency,
  });

  final int projectId;
  final String currency;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(l10nProvider);
    final typo = UITheme.of(context).typo;
    final payoutsAsync = ref.watch(projectPayoutsProvider(projectId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.impact_transactions_title,
          style: typo.inter.title.copyWith(
            color: UIColorsToken.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        const UISpace.vert(4),
        Text(
          l10n.impact_transactions_subtitle,
          style: typo.inter.bodySmall
              .copyWith(color: UIColorsToken.textParagraph),
        ),
        const UISpace.vert(14),
        payoutsAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: UICircularProgressBar()),
          ),
          error: (_, __) => _empty(context, l10n.impact_transactions_empty),
          data: (payouts) {
            if (payouts.isEmpty) {
              return _empty(context, l10n.impact_transactions_empty);
            }
            final total = payouts.fold<double>(0, (s, p) => s + p.amount);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                UICard(
                  disableBorder: true,
                  padding: const EdgeInsets.all(14),
                  color: UIColorsToken.bgSurface,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.impact_transactions_distributed,
                        style: typo.inter.bodyMedium
                            .copyWith(color: UIColorsToken.textParagraph),
                      ),
                      Text(
                        ImpactFormat.money(total, currency),
                        style: typo.inter.title.copyWith(
                          color: UIColorsToken.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const UISpace.vert(10),
                for (final payout in payouts)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _PublicPayoutTile(payout: payout, l10n: l10n),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _empty(BuildContext context, String message) {
    final typo = UITheme.of(context).typo;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(
        message,
        style: typo.inter.bodySmall
            .copyWith(color: UIColorsToken.textParagraph),
      ),
    );
  }
}

class _PublicPayoutTile extends StatelessWidget {
  const _PublicPayoutTile({required this.payout, required this.l10n});

  final PayoutModel payout;
  final AppLocale l10n;

  @override
  Widget build(BuildContext context) {
    final typo = UITheme.of(context).typo;
    final date = payout.executedAt ?? payout.createdAt;

    return UICard(
      disableBorder: true,
      color: UIColorsToken.bgPrimary,
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (payout.hasProof) ...[
            PayoutProofImage(proofPath: payout.proofPath!, height: 56, width: 56),
            const UISpace.horz(12),
          ] else ...[
            Container(
              height: 56,
              width: 56,
              decoration: BoxDecoration(
                color: UIColorsToken.bgSurface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.check_circle,
                  color: UIColorsToken.greenAccent, size: 22),
            ),
            const UISpace.horz(12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ImpactFormat.money(payout.amount, payout.currency),
                  style: typo.inter.bodyMedium.copyWith(
                    color: UIColorsToken.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const UISpace.vert(2),
                Text(
                  '${payout.method.value.toUpperCase()} · '
                  '${DateFormat.yMMMd().format(date)}',
                  style: typo.inter.smallCaption
                      .copyWith(color: UIColorsToken.textParagraph),
                ),
                if (payout.note != null && payout.note!.isNotEmpty) ...[
                  const UISpace.vert(6),
                  Text(
                    payout.note!,
                    style: typo.inter.bodySmall
                        .copyWith(color: UIColorsToken.textParagraph),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
