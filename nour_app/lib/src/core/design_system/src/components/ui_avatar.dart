import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nour/src/core/design_system/design_system.dart';

/// Circular (or rounded-square) identity avatar.
///
/// The image is rendered through [CachedNetworkImage] — **not** a
/// `DecorationImage` — so a missing object, a 4xx from Storage or a slow
/// network falls back to the initials instead of leaving an empty coloured
/// circle. An empty/blank [url] is treated exactly like `null`.
class UIAvatar extends StatelessWidget {
  const UIAvatar({
    super.key,
    required this.url,
    required this.initial,
    required this.color,
    required this.size,
    this.onTap,
    this.borderRadius,
  });

  final String? url;
  final String initial;
  final Color color;
  final double size;
  final VoidCallback? onTap;

  /// `null` → circle (default). Any value renders a rounded square.
  final double? borderRadius;

  @override
  Widget build(BuildContext context) {
    final typo = UITheme.of(context).typo;

    final src = url?.trim();
    final hasImage = src != null && src.isNotEmpty;

    Widget fallback() => Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          color: color,
          child: Text(
            initial,
            style: typo.inter.largeTitle.copyWith(fontSize: size / 2),
          ),
        );

    return UITap(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius ?? size / 2),
        child: SizedBox(
          width: size,
          height: size,
          child: hasImage
              ? CachedNetworkImage(
                  imageUrl: src,
                  width: size,
                  height: size,
                  fit: BoxFit.cover,
                  fadeInDuration: const Duration(milliseconds: 150),
                  placeholder: (_, __) => fallback(),
                  errorWidget: (_, __, ___) => fallback(),
                )
              : fallback(),
        ),
      ),
    );
  }
}
