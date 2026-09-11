import 'package:flutter/material.dart';
import 'package:nour/src/core/design_system/design_system.dart';

/// One `value / label` pair of the bottom stats row of
/// [UIMosqueDonationInformationCard].
class UIMosqueDonationStat {
  const UIMosqueDonationStat({required this.value, required this.label});

  final String value;
  final String label;
}

/// Donation overview card (Figma "Mosque profile – donation", node 1153:1824).
///
/// Dark-green gradient card with a faint Arabic calligraphy watermark:
///
/// * total raised + optional growth badge (`+24% vs 2025`)
/// * split bar: support share (grey) vs campaigns share (gold)
/// * amounts / labels for both shares
/// * three stats separated by dividers (donors · recurring · avg gift)
///
/// Purely presentational — pass already formatted strings.
class UIMosqueDonationInformationCard extends StatelessWidget {
  const UIMosqueDonationInformationCard({
    super.key,
    required this.total,
    required this.totalLabel,
    this.growthLabel,
    required this.supportAmount,
    required this.supportLabel,
    required this.campaignsAmount,
    required this.campaignsLabel,
    required this.supportRatio,
    required this.stats,
    this.arabicBgText = 'احصل على',
    this.padding = const EdgeInsets.all(16),
    this.width,
    this.shadows,
    this.onTap,
  });

  /// e.g. `€103,570`
  final String total;
  /// e.g. `Total raised this year`
  final String totalLabel;
  /// e.g. `+24% vs 2025`. Hidden when null.
  final String? growthLabel;

  final String supportAmount;
  /// e.g. `Support` — the percentage is appended by the card.
  final String supportLabel;
  final String campaignsAmount;
  final String campaignsLabel;
  /// Support share of the total, `0..1`. Campaigns = `1 - supportRatio`.
  final double supportRatio;

  /// Bottom row, 2–4 entries; first is start-aligned, last end-aligned.
  final List<UIMosqueDonationStat> stats;
  final String? arabicBgText;
  final EdgeInsets padding;
  final double? width;
  /// `null` = [UICard] default drop shadow; pass `const []` for a flat card.
  final List<BoxShadow>? shadows;
  final VoidCallback? onTap;

  static const double radius = 10;

  @override
  Widget build(BuildContext context) {
    final theme = UITheme.of(context);
    final ratio = supportRatio.clamp(0.0, 1.0);
    final supportPct = (ratio * 100).round();
    final campaignsPct = 100 - supportPct;

    return UICard(
      onTap: onTap,
      width: width ?? double.infinity,
      borderRadius: radius,
      disableBorder: true,
      shadows: shadows,
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: UIColorsToken.bgPriGreen.colors,
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Stack(
          children: [
            if (arabicBgText != null)
              Positioned.fill(
                child: FittedBox(
                  fit: BoxFit.fitWidth,
                  clipBehavior: Clip.hardEdge,
                  child: Text(
                    arabicBgText!,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: UIColorsToken.textYellow.withValues(alpha: 0.05)),
                  ),
                ),
              ),
            Padding(
              padding: padding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Total + growth ─────────────────────────────────────
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              total,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.typo.inter.largeTitle.copyWith(
                                color: UIColorsToken.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 20

                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              totalLabel,
                              style: theme.typo.inter.bodySmall.copyWith(
                                color: UIColorsToken.textParagraph,
                                fontSize: 10
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (growthLabel != null) ...[
                        const SizedBox(width: 12),
                        _GrowthBadge(label: growthLabel!),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ── Split bar ──────────────────────────────────────────
                  _SplitBar(ratio: ratio),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _Share(
                          amount: supportAmount,
                          label: '$supportLabel · $supportPct%',
                          labelColor: UIColorsToken.textParagraph,
                        ),
                      ),
                      Expanded(
                        child: _Share(
                          amount: campaignsAmount,
                          label: '$campaignsLabel · $campaignsPct%',
                          labelColor: UIColorsToken.textYellow,
                          alignEnd: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ── Stats ──────────────────────────────────────────────
                  IntrinsicHeight(
                    child: Row(
                      children: [
                        for (var i = 0; i < stats.length; i++) ...[
                          if (i > 0)
                            Container(
                              width: 1,
                              margin: const EdgeInsets.symmetric(horizontal: 12),
                              color: UIColorsToken.white.withValues(alpha: 0.15),
                            ),
                          Expanded(
                            child: _StatCell(
                              stat: stats[i],
                              align: i == 0
                                  ? CrossAxisAlignment.start
                                  : i == stats.length - 1
                                      ? CrossAxisAlignment.end
                                      : CrossAxisAlignment.center,
                            ),
                          ),
                        ],
                      ],
                    ),
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

class _GrowthBadge extends StatelessWidget {
  const _GrowthBadge({required this.label});
  final String label;

  static const _fg = UIColorsToken.greenAccent;

  @override
  Widget build(BuildContext context) {
    final theme = UITheme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: UIColorsToken.pastelGreen.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: UIColorsToken.greenAccent, width: 0.5)
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.north_east_rounded, size: 12, color: _fg),
          const SizedBox(width: 4),
          Text(label, style: theme.typo.inter.smallCaption.copyWith(color: _fg, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

/// Two fully-filled segments whose widths follow the support / campaigns share.
class _SplitBar extends StatelessWidget {
  const _SplitBar({required this.ratio});
  final double ratio;

  static const _height = 4.0;
  static const _gap = 6.0;

  @override
  Widget build(BuildContext context) {
    final support = (ratio * 1000).round().clamp(1, 999);
    return Row(
      children: [
        Expanded(
          flex: support,
          child: Container(
            height: _height,
            decoration: BoxDecoration(
              color: UIColorsToken.white.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(100),
            ),
          ),
        ),
        const SizedBox(width: _gap),
        Expanded(
          flex: 1000 - support,
          child: Container(
            height: _height,
            decoration: BoxDecoration(
              color: UIColorsToken.textYellow,
              borderRadius: BorderRadius.circular(100),
            ),
          ),
        ),
      ],
    );
  }
}

class _Share extends StatelessWidget {
  const _Share({
    required this.amount,
    required this.label,
    required this.labelColor,
    this.alignEnd = false,
  });

  final String amount;
  final String label;
  final Color labelColor;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    final theme = UITheme.of(context);
    return Column(
      crossAxisAlignment: alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(amount, style: theme.typo.inter.title.copyWith(
          color: UIColorsToken.white,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        )),
        const SizedBox(height: 2),
        Text(
          label,
          style: theme.typo.inter.bodySmall.copyWith(
            color: labelColor,
            fontSize: 10
          )
        ),
      ],
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({required this.stat, required this.align});
  final UIMosqueDonationStat stat;
  final CrossAxisAlignment align;

  @override
  Widget build(BuildContext context) {
    final theme = UITheme.of(context);
    return Column(
      crossAxisAlignment: align,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          stat.value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.typo.inter.titleMedium.copyWith(
            color: UIColorsToken.white,
            fontWeight: FontWeight.w600,
            fontSize: 17
          ),
        ),
        const SizedBox(height: 2),
        Text(
          stat.label,
          style: theme.typo.inter.bodySmall.copyWith(
            color: UIColorsToken.textParagraph,
            fontSize: 10
          )),
      ],
    );
  }
}
