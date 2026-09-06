import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';
import 'package:nour/src/features/mosques/data/models/mosque_model.dart';

/// Admin Donation tab (P3). Placeholder until Stripe Connect lands.
class MosqueAdminDonationTab extends ConsumerWidget {
  const MosqueAdminDonationTab({super.key, required this.mosque});

  final MosqueModel mosque;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = UITheme.of(context);
    final l10n = ref.watch(l10nProvider);
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Center(
        child: Text(l10n.mosque_donations_coming_soon, textAlign: TextAlign.center, style: theme.typo.inter.body.copyWith(color: UIColorsToken.textParagraph)),
      ),
    );
  }
}
