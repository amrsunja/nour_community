import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nour/gen/assets.gen.dart';
import 'package:nour/src/core/design_system/design_system.dart';

import '../../data/datasources/adhkar_remote_datasource.dart';

/// Renders a subcategory illustration from the `app_images` storage bucket.
///
/// [imgUrl] may be a full URL or a storage object path; both are resolved via
/// [AdhkarRemoteDatasource.publicImageUrl]. Falls back to a bundled
/// illustration while loading, on error, or when [imgUrl] is null.
class AdhkarImageWidget extends StatelessWidget {
  const AdhkarImageWidget({
    super.key,
    required this.imgUrl,
    this.size = 36,
  });

  final String? imgUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    final url = AdhkarRemoteDatasource.publicImageUrl(imgUrl);

    final fallback = Image.asset(
      Assets.images.illustration1.path,
      width: size,
      height: size,
      fit: BoxFit.contain,
    );

    if (url == null) return fallback;

    return CachedNetworkImage(
      imageUrl: url,
      width: size,
      height: size,
      fit: BoxFit.contain,
      placeholder: (_, __) => SizedBox(
        width: size,
        height: size,
        child: const Center(child: UICircularProgressBar(size: 16)),
      ),
      errorWidget: (_, __, ___) => fallback,
    );
  }
}
