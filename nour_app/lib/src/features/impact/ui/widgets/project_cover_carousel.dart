import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:nour/src/core/design_system/design_system.dart';

import '../../data/datasources/impact_remote_datasource.dart';

/// Detail-page hero: swipeable gallery with a dot indicator overlaid at the
/// bottom (single static image when there is only one).
class ProjectCoverCarousel extends HookWidget {
  const ProjectCoverCarousel({
    super.key,
    required this.images,
    this.height = 230,
  });

  final List<String> images;
  final double height;

  @override
  Widget build(BuildContext context) {
    final urls = [
      for (final i in images)
        ?ImpactRemoteDatasource.publicStoryImageUrl(i),
    ];
    if (urls.isEmpty) {
      return Container(
        height: height,
        decoration: BoxDecoration(
          color: UIColorsToken.bgSurface,
          borderRadius: BorderRadius.circular(20),
        ),
      );
    }

    final controller = usePageController();
    final index = useState(0);

    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (urls.length == 1)
            _Slide(url: urls.first)
          else
            PageView.builder(
              controller: controller,
              onPageChanged: (i) => index.value = i,
              itemCount: urls.length,
              itemBuilder: (_, i) => _Slide(url: urls[i]),
            ),
          // Bottom fade so the dots stay readable on bright photos.
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 60,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    UIColorsToken.black.withValues(alpha: 0.45),
                  ],
                ),
              ),
            ),
          ),
          if (urls.length > 1)
            Positioned(
              left: 0,
              right: 0,
              bottom: 12,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < urls.length; i++)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: index.value == i ? 18 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: index.value == i
                            ? UIColorsToken.white
                            : UIColorsToken.white.withValues(alpha: 0.45),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _Slide extends StatelessWidget {
  const _Slide({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      placeholder: (_, _) => Container(color: UIColorsToken.bgSurface),
      errorWidget: (_, _, _) => Container(color: UIColorsToken.bgSurface),
    );
  }
}
