import 'package:flutter/material.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';

import '../../data/models/mosque_model.dart';

/// Donation tab (P3 — Sadaqa card + campaigns). Placeholder until P3 lands.
class MosqueDonationTab extends StatelessWidget {
  const MosqueDonationTab({super.key, required this.mosque, required this.l10n});

  final MosqueModel mosque;
  final AppLocale l10n;

  @override
  Widget build(BuildContext context) {
    final theme = UITheme.of(context);
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Center(
        child: Text(l10n.mosque_donations_coming_soon, textAlign: TextAlign.center, style: theme.typo.inter.body.copyWith(color: UIColorsToken.textParagraph)),
      ),
    );
  }
}
