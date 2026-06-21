import 'package:flutter/material.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';

import '../../data/models/dhikr_model.dart';

/// Single dhikr card built on [UIBgArabicTextCard].
///
/// Two flavours, driven by [showActions]:
///  * essential (default) — transcription + arabic, a [UIProgressLine] and a
///    `current/total` counter (with a check badge when completed). Tapping the
///    whole card opens the counter via [onTap].
///  * continue — same header + progress, plus a [UIButton.primary] "Continue"
///    and a circular reset action (used inside the "Continue dhikr" block).
class DhikrCardWidget extends StatelessWidget {
  const DhikrCardWidget({
    super.key,
    required this.dhikr,
    required this.currentCount,
    required this.totalCount,
    this.isCompleted = false,
    this.showActions = false,
    this.onTap,
    this.onContinue,
    this.onReset,
  });

  final DhikrModel dhikr;
  final int currentCount;
  final int totalCount;
  final bool isCompleted;

  /// Renders the "Continue dhikr" footer (Continue + reset buttons).
  final bool showActions;

  final VoidCallback? onTap;
  final VoidCallback? onContinue;
  final VoidCallback? onReset;

  @override
  Widget build(BuildContext context) {
    final theme = UITheme.of(context);
    final typo = theme.typo;
    final l10n = AppLocale.of(context);
    final langCode = Localizations.localeOf(context).languageCode;

    return UIAppearAnimation(
      child: UIBgArabicTextCard(
        onTap: onTap ?? onContinue,
        height: showActions ? 168 : 96,
        arabicBgText: dhikr.arabicText,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: .spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      dhikr.transcription(langCode),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: typo.inter.title.copyWith(
                        color: UIColorsToken.white,
                      ),
                    ),
                  ),
                  const UISpace.horz(12),
                  Flexible(
                    child: Text(
                      dhikr.arabicText,
                      textDirection: TextDirection.rtl,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: typo.inter.title.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const UISpace.vert(12),
              Row(
                children: [
                  Expanded(
                    child: UIProgressLine(
                      current: currentCount.toDouble(),
                      total: dhikr.minCount.toDouble(),
                      fillColor: isCompleted ? UIColorsToken.pastelGreen : null,
                    ),
                  ),
                  const UISpace.horz(12),
                  if (isCompleted)
                    _CompletedBadge(
                      count: currentCount,
                      totalCount: totalCount,
                    )
                  else
                    Text(
                      '$currentCount/${dhikr.minCount}',
                      style: typo.inter.bodySmall.copyWith(
                        color: UIColorsToken.textYellow,
                      ),
                    ),
                ],
              ),
              if (showActions) ...[
                const UISpace.vert(16),
                Row(
                  children: [
                    Expanded(
                      child: UIButton.primary(
                        label: l10n.common_continue,
                        fullWidth: true,
                        onTap: onContinue,
                      ),
                    ),
                    const UISpace.horz(12),
                    _ResetButton(onTap: onReset),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _CompletedBadge extends StatelessWidget {
  final int count;
  final int totalCount;

  const _CompletedBadge({
      required this.count,
      required this.totalCount,
  });

  @override
  Widget build(BuildContext context) {
    final typo = UITheme.of(context).typo;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$count/$totalCount',
          style: typo.inter.caption.copyWith(
            color: UIColorsToken.pastelGreen),
        ),
        const UISpace.horz(8),
        Container(
          padding: .symmetric(vertical: 4, horizontal: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            color: UIColorsToken.pastelGreen,
          ),
          child: const Icon(Icons.check, size: 15, color: UIColorsToken.white),
        ),
      ],
    );
  }
}

class _ResetButton extends StatelessWidget {
  const _ResetButton({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return UITap(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: UIColorsToken.bgPriYellow,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.refresh, size: 22, color: UIColorsToken.black),
      ),
    );
  }
}
