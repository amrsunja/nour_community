import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';

import '../../data/datasources/impact_remote_datasource.dart';
import '../../data/models/project_story_model.dart';

/// One "story from the field" entry rendered as a timeline row: a left rail
/// (dot + connecting line) and the story content card on the right.
///
/// [isFirst] omits the line above the dot, [isLast] omits the line below it,
/// so a list of these draws a continuous vertical timeline.
class ProjectStoryCardWidget extends StatelessWidget {
  const ProjectStoryCardWidget({
    super.key,
    required this.story,
    required this.isFirst,
    required this.isLast,
    required this.langCode,
  });

  final ProjectStoryModel story;
  final bool isFirst;
  final bool isLast;
  final String langCode;

  static String relativeTime(AppLocale l10n, DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inHours < 1) return l10n.impact_time_just_now;
    if (diff.inHours < 24) return l10n.impact_time_hours_ago(diff.inHours);
    final days = diff.inDays;
    if (days < 7) return l10n.impact_time_days_ago(days);
    if (days < 30) return l10n.impact_time_weeks_ago(days ~/ 7);
    return l10n.impact_time_months_ago(days ~/ 30);
  }

  @override
  Widget build(BuildContext context) {
    final typo = UITheme.of(context).typo;
    final l10n = AppLocale.of(context);
    final imageUrls = [
      for (final ref in story.images)
        if (ImpactRemoteDatasource.publicStoryImageUrl(ref) case final url?) url,
    ];

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _TimelineRail(isFirst: isFirst, isLast: isLast),
          const UISpace.horz(12),
          Expanded(
            child: UICard(
              padding: const EdgeInsets.all(16),
              color: UIColorsToken.black80,
              disableBorder: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (imageUrls.isNotEmpty) ...[
                    _StoryImageSlider(imageUrls: imageUrls),
                    const UISpace.vert(10),
                  ],
                  Text(
                    relativeTime(l10n, story.createdAt),
                    style: typo.inter.caption.copyWith(
                      color: isFirst ? UIColorsToken.greenAccent : UIColorsToken.textYellowDarker,
                    ),
                  ),
                  const UISpace.vert(4),
                  Text(
                    story.title(langCode),
                    style: typo.inter.title.copyWith(
                      color: UIColorsToken.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (story.description(langCode).isNotEmpty) ...[
                    const UISpace.vert(4),
                    Text(
                      story.description(langCode),
                      style: typo.inter.bodySmall.copyWith(
                        color: UIColorsToken.textParagraph,
                        height: 1.4,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Horizontal image carousel for a story. Falls back to a single static image
/// when there is only one, otherwise a swipeable [PageView] with a dot indicator.
class _StoryImageSlider extends HookWidget {
  const _StoryImageSlider({required this.imageUrls});

  final List<String> imageUrls;

  static const double _height = 150;

  @override
  Widget build(BuildContext context) {
    if (imageUrls.length == 1) {
      return _SliderImage(url: imageUrls.first);
    }

    final controller = usePageController();
    final index = useState(0);

    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: SizedBox(
            height: _height,
            width: double.infinity,
            child: PageView.builder(
              controller: controller,
              onPageChanged: (i) => index.value = i,
              itemCount: imageUrls.length,
              itemBuilder: (_, i) => _SliderImage(url: imageUrls[i]),
            ),
          ),
        ),
        const UISpace.vert(8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < imageUrls.length; i++)
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: index.value == i ? 18 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: index.value == i
                      ? UIColorsToken.yellow
                      : UIColorsToken.yellow.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

/// A single cached, rounded image used inside the slider.
class _SliderImage extends StatelessWidget {
  const _SliderImage({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: CachedNetworkImage(
        imageUrl: url,
        height: _StoryImageSlider._height,
        width: double.infinity,
        fit: BoxFit.cover,
        placeholder: (_, _) => Container(
          height: _StoryImageSlider._height,
          color: UIColorsToken.bgSurface,
        ),
        errorWidget: (_, _, _) => Container(
          height: _StoryImageSlider._height,
          color: UIColorsToken.bgSurface,
        ),
      ),
    );
  }
}

/// The left timeline column: a gold dot with a connecting line above / below.
class _TimelineRail extends StatelessWidget {
  const _TimelineRail({required this.isFirst, required this.isLast});

  final bool isFirst;
  final bool isLast;

  static const double _width = 22;
  static const double _dot = 12;
  static const double _dotTop = 4;

  @override
  Widget build(BuildContext context) {
    final lineColor = UIColorsToken.yellow.withValues(alpha: 0.3);
    const center = (_width - 2) / 2;

    return SizedBox(
      width: _width,
      child: Stack(
        children: [
          // Line below the dot, stretching to the bottom of the row.
          if (!isLast)
            Positioned(
              top: _dotTop + _dot / 2,
              bottom: 0,
              left: center,
              child: Container(
                margin: .only(top: 14),
                width: 0.5,
                color: lineColor
              ),
            ),
          // The dot.
          Positioned(
            top: _dotTop,
            left: (_width - _dot) / 2.5,
            child: Container(
              width: _dot,
              height: _dot,
              decoration: BoxDecoration(
                color: isFirst ? UIColorsToken.yellow : UIColorsToken.yellow.withValues(alpha: 0.2),
                shape: BoxShape.circle,
                boxShadow: isFirst ? UIShadowToken.sliderBull : null
              ),
            ),
          ),
        ],
      ),
    );
  }
}
