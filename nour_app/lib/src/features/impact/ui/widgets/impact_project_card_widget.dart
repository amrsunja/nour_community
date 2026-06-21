import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';
import 'package:nour/src/features/impact/ui/widgets/donors_avatars_widget.dart';

import '../../data/datasources/impact_remote_datasource.dart';
import '../../data/models/impact_project_model.dart';
import 'category_badge_widget.dart';
import 'impact_money.dart';

/// Reusable impact-project card used on the Impact list and the profile
/// Favourites tab. A cover image with a dark bottom scrim, a category badge,
/// the title, a funding progress line, the `collected / required` amount and a
/// donors row.
class ImpactProjectCardWidget extends StatelessWidget {
  const ImpactProjectCardWidget({
    super.key,
    required this.project,
    required this.onTap,
  });

  final ImpactProjectModel project;
  final VoidCallback onTap;

  static const double _height = 230;

  @override
  Widget build(BuildContext context) {
    final typo = UITheme.of(context).typo;
    final l10n = AppLocale.of(context);
    final langCode = Localizations.localeOf(context).languageCode;

    final coverUrl =
        ImpactRemoteDatasource.publicStoryImageUrl(project.coverImageUrl);
    final categoryTitle = project.category?.title(langCode);
    final isUrgent = project.category?.titleEn == 'Urgent';

    return UIAppearAnimation(
      child: UITap(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: SizedBox(
            height: _height,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Cover image.
                if (coverUrl != null)
                  CachedNetworkImage(
                    imageUrl: coverUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, _) => Container(color: UIColorsToken.bgSurface),
                    errorWidget: (_, _, _) => Container(color: UIColorsToken.bgSurface),
                  )
                else
                  Container(color: UIColorsToken.bgSurface),

                // Bottom scrim so text stays legible.
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.center,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, UIColorsToken.bgSecondaryGreen],
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (categoryTitle != null && categoryTitle.isNotEmpty)
                        CategoryBadgeWidget(label: categoryTitle, urgent: isUrgent),
                      const UISpace.vert(10),
                      Text(
                        project.title(langCode),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: typo.inter.headline.copyWith(
                          color: UIColorsToken.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const UISpace.vert(10),
                      UIProgressLine(
                        current: project.collectedAmount,
                        total: project.requiredAmount,
                        height: 4,
                      ),
                      const UISpace.vert(8),
                      Text(
                        '${ImpactFormat.money(project.collectedAmount, project.currency)}'
                        ' / '
                        '${ImpactFormat.money(project.requiredAmount, project.currency)}',
                        style: typo.inter.bodyMedium.copyWith(
                          color: UIColorsToken.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (project.donorsCount > 0) ...[
                        const UISpace.vert(8),
                        Row(
                          children: [
                            const DonorsAvatarsWidget(),
                            const UISpace.horz(8),
                            Flexible(
                              child: Text(
                                l10n.impact_donors(
                                  ImpactFormat.compactCount(project.donorsCount),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: typo.inter.bodySmall.copyWith(
                                  color: UIColorsToken.textParagraph,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
