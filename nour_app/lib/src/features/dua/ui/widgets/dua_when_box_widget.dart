import 'package:flutter/material.dart';
import 'package:nour/gen/assets.gen.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';

/// The "When to recite" guidance box shown beneath the dua translation in the
/// reader (matches the design: a lightbulb icon + gold header, then the
/// localized guidance text). Renders nothing when [text] is empty.
class DuaWhenBoxWidget extends StatelessWidget {
  const DuaWhenBoxWidget({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    if (text.trim().isEmpty) return const SizedBox.shrink();

    final typo = UITheme.of(context).typo;
    final l10n = AppLocale.of(context);

    return UICard(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: Color(0xff2A3225).withValues(alpha: 0.2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              UIIcon(
                Assets.icons.idea,
                color: UIColorsToken.yellow,
                size: 25,
              ),
              const UISpace.horz(8),
              Text(
                l10n.dua_when_to_recite,
                style: typo.inter.headline.copyWith(
                  color: UIColorsToken.yellow,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const UISpace.vert(10),
          UIGlowingBlock(
            child: Text(
              text,
              style: typo.inter.bodyMedium.copyWith(
                color: UIColorsToken.yellow,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
