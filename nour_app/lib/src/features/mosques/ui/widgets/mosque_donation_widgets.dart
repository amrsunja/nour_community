import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';

import '../../data/models/mosque_donation_models.dart';
import 'mosque_format.dart';

/// Pill chip used by frequency / amount pickers (Figma "Sadaqa card").
class MosqueChip extends StatelessWidget {
  const MosqueChip({super.key, required this.label, required this.selected, this.onTap, this.dense = false});

  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final typo = UITheme.of(context).typo;
    return UITap(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(horizontal: dense ? 12 : 16, vertical: dense ? 8 : 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: selected ? UIColorsToken.bgPriYellow : null,
          color: selected ? null : UIColorsToken.bgSurface,
          border: Border.all(color: selected ? Colors.transparent : UIColorsToken.black80),
        ),
        child: Text(label, style: typo.inter.bodyMedium.copyWith(color: selected ? UIColorsToken.black : UIColorsToken.white, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

/// Suggested amounts + "Other" custom entry. Emits the chosen amount.
class MosqueAmountPicker extends StatefulWidget {
  const MosqueAmountPicker({super.key, required this.amounts, required this.value, required this.onChanged, required this.l10n, this.symbol = '€'});

  final List<int> amounts;
  final double value;
  final ValueChanged<double> onChanged;
  final AppLocale l10n;
  final String symbol;

  @override
  State<MosqueAmountPicker> createState() => _MosqueAmountPickerState();
}

class _MosqueAmountPickerState extends State<MosqueAmountPicker> {
  late final TextEditingController _custom;
  bool _customMode = false;

  @override
  void initState() {
    super.initState();
    _customMode = !widget.amounts.contains(widget.value.round());
    _custom = TextEditingController(text: _customMode ? widget.value.round().toString() : '');
  }

  @override
  void dispose() {
    _custom.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final typo = UITheme.of(context).typo;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final a in widget.amounts)
              MosqueChip(
                label: '$a${widget.symbol}',
                selected: !_customMode && widget.value.round() == a,
                onTap: () {
                  setState(() => _customMode = false);
                  widget.onChanged(a.toDouble());
                },
              ),
            MosqueChip(label: widget.l10n.mosque_donation_other_amount, selected: _customMode, onTap: () => setState(() => _customMode = true)),
          ],
        ),
        if (_customMode) ...[
          const UISpace.vert(10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(color: UIColorsToken.bgSurface, borderRadius: BorderRadius.circular(12)),
            child: TextField(
              controller: _custom,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(decimal: false),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(6)],
              style: typo.inter.title.copyWith(color: UIColorsToken.white),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: widget.l10n.mosque_donation_custom_amount_hint,
                hintStyle: typo.inter.body.copyWith(color: UIColorsToken.textParagraph),
                suffixText: widget.symbol,
                suffixStyle: typo.inter.title.copyWith(color: UIColorsToken.white),
              ),
              onChanged: (v) {
                final n = double.tryParse(v);
                if (n != null && n > 0) widget.onChanged(n);
              },
            ),
          ),
        ],
      ],
    );
  }
}

/// Campaign card (list item) — cover, title, progress, collected / goal,
/// days left. Used on the worshipper tab and the admin list.
class MosqueCampaignCard extends StatelessWidget {
  const MosqueCampaignCard({super.key, required this.campaign, required this.l10n, this.onTap, this.trailing});

  final MosqueCampaignModel campaign;
  final AppLocale l10n;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final typo = UITheme.of(context).typo;
    final c = campaign;
    return UITap(
      onTap: onTap,
      child: UICard(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (c.coverUrl != null && c.coverUrl!.isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                child: AspectRatio(
                  aspectRatio: 16 / 7,
                  child: CachedNetworkImage(imageUrl: c.coverUrl!, fit: BoxFit.cover, errorWidget: (_, __, ___) => Container(color: UIColorsToken.bgSurface)),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(c.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: typo.inter.title.copyWith(color: UIColorsToken.white, fontWeight: FontWeight.w600))),
                      if (trailing != null) trailing! else MosqueCampaignStatusPill(campaign: c, l10n: l10n),
                    ],
                  ),
                  const UISpace.vert(10),
                  UIProgressLine(current: c.collectedAmount, total: c.goalAmount <= 0 ? 1 : c.goalAmount, height: 8),
                  const UISpace.vert(8),
                  Row(
                    children: [
                      Text(MosqueFormat.money(c.collectedAmount), style: typo.inter.title.copyWith(color: UIColorsToken.textYellow, fontWeight: FontWeight.w700)),
                      const UISpace.horz(4),
                      Expanded(
                        child: Text(l10n.mosque_campaign_of_goal(MosqueFormat.money(c.goalAmount)), style: typo.inter.bodySmall.copyWith(color: UIColorsToken.textParagraph)),
                      ),
                      Text('${c.percent}%', style: typo.inter.bodyMedium.copyWith(color: UIColorsToken.white)),
                    ],
                  ),
                  const UISpace.vert(6),
                  Text(
                    [
                      l10n.mosque_campaign_donors_count(c.donorsCount),
                      if (c.isOpen) l10n.mosque_campaign_days_left(c.daysLeft) else l10n.mosque_campaign_closed,
                    ].join(' · '),
                    style: typo.inter.smallCaption.copyWith(color: UIColorsToken.textParagraph),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MosqueCampaignStatusPill extends StatelessWidget {
  const MosqueCampaignStatusPill({super.key, required this.campaign, required this.l10n});
  final MosqueCampaignModel campaign;
  final AppLocale l10n;

  @override
  Widget build(BuildContext context) {
    final typo = UITheme.of(context).typo;
    final (label, color) = campaign.isOpen
        ? campaign.isEndingSoon
            ? (l10n.mosque_campaign_ending_soon, UIColorsToken.yellow)
            : (l10n.mosque_campaign_active, UIColorsToken.green)
        : (l10n.mosque_campaign_closed, UIColorsToken.textParagraph);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: color.withValues(alpha: 0.18)),
      child: Text(label, style: typo.inter.smallCaption.copyWith(color: color, fontWeight: FontWeight.w600)),
    );
  }
}

/// Small "Tax receipt available" badge (devis B2).
class MosqueTaxBadge extends StatelessWidget {
  const MosqueTaxBadge({super.key, required this.l10n});
  final AppLocale l10n;

  @override
  Widget build(BuildContext context) {
    final typo = UITheme.of(context).typo;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: UIColorsToken.green.withValues(alpha: 0.16)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.verified_outlined, size: 14, color: UIColorsToken.green),
          const UISpace.horz(4),
          Text(l10n.mosque_donation_tax_badge, style: typo.inter.smallCaption.copyWith(color: UIColorsToken.green, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

/// Section header with optional trailing action.
class MosqueSectionHeader extends StatelessWidget {
  const MosqueSectionHeader({super.key, required this.title, this.actionLabel, this.onAction});
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final typo = UITheme.of(context).typo;
    return Row(
      children: [
        Expanded(child: Text(title, style: typo.inter.title.copyWith(color: UIColorsToken.white, fontWeight: FontWeight.w700))),
        if (actionLabel != null)
          UITap(onTap: onAction, child: Text(actionLabel!, style: typo.inter.bodyMedium.copyWith(color: UIColorsToken.textYellow))),
      ],
    );
  }
}
