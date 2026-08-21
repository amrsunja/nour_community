import 'package:flutter/material.dart';
import 'package:nour/src/core/design_system/design_system.dart';

import '../../data/models/impact_project_tier_model.dart';
import 'impact_money.dart';

/// "Your donation provides" — tappable outcome tiers. Tapping one opens the
/// donation flow with that amount pre-selected.
class ProjectTiersSection extends StatelessWidget {
  const ProjectTiersSection({
    super.key,
    required this.title,
    required this.tiers,
    required this.currency,
    required this.langCode,
    required this.onTierTap,
  });

  final String title;
  final List<ImpactProjectTierModel> tiers;
  final String currency;
  final String langCode;
  final ValueChanged<ImpactProjectTierModel> onTierTap;

  @override
  Widget build(BuildContext context) {
    final typo = UITheme.of(context).typo;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: typo.inter.title.copyWith(
            color: UIColorsToken.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        const UISpace.vert(12),
        for (final tier in tiers) ...[
          UICard(
            color: UIColorsToken.black80,
            disableBorder: true,
            shadows: const [],
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            onTap: () => onTierTap(tier),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tier.title(langCode),
                        style: typo.inter.title.copyWith(color: UIColorsToken.white),
                      ),
                      if (tier.subtitle(langCode).isNotEmpty) ...[
                        const UISpace.vert(2),
                        Text(
                          tier.subtitle(langCode),
                          style: typo.inter.bodySmall.copyWith(
                            color: UIColorsToken.textParagraph,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const UISpace.horz(12),
                Text(
                  ImpactFormat.money(tier.amount, currency),
                  style: typo.inter.largeTitle.copyWith(
                    color: UIColorsToken.textYellow,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const UISpace.vert(10),
        ],
      ],
    );
  }
}
