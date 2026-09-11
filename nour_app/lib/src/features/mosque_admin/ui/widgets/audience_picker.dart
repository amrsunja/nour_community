import 'package:flutter/material.dart';
import 'package:nour/gen/assets.gen.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';
import 'package:nour/src/features/mosques/data/models/mosque_enums.dart';

/// "Public ▾ / Followers ▾" pill of the post forms.
class AudiencePicker extends StatelessWidget {
  const AudiencePicker({super.key, required this.value, required this.onChanged, required this.l10n});

  final MosquePostAudience value;
  final ValueChanged<MosquePostAudience> onChanged;
  final AppLocale l10n;

  @override
  Widget build(BuildContext context) {
    final theme = UITheme.of(context);
    return PopupMenuButton<MosquePostAudience>(
      onSelected: onChanged,
      color: UIColorsToken.bgSurface,
      itemBuilder: (_) => [
        PopupMenuItem(value: MosquePostAudience.public, child: Text(l10n.mosque_post_audience_public, style: theme.typo.inter.body.copyWith(color: UIColorsToken.white))),
        PopupMenuItem(value: MosquePostAudience.followers, child: Text(l10n.mosque_post_audience_followers, style: theme.typo.inter.body.copyWith(color: UIColorsToken.white))),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(100), border: Border.all(color: UIColorsToken.stroke)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            UIIcon(
              value == MosquePostAudience.public
                ? Assets.icons.earth
                : Assets.icons.persons,
                color: UIColorsToken.textParagraph,
                size: 16,
            ),
            const SizedBox(width: 6),
            Text(value == MosquePostAudience.public ? l10n.mosque_post_audience_public : l10n.mosque_post_audience_followers,
                style: theme.typo.inter.bodyMedium.copyWith(color: UIColorsToken.textParagraph)),
            Icon(Icons.expand_more, size: 16, color: UIColorsToken.textParagraph),
          ],
        ),
      ),
    );
  }
}
