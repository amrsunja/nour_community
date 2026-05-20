import 'package:flutter/material.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/gen/assets.gen.dart';

/// Square-ish social provider button (Google / Apple) used on the connect
/// account screen. Renders a centered provider logo on a dark surface.
class SocialAuthButton extends StatelessWidget {
  const SocialAuthButton({
    super.key,
    required this.image,
    this.onTap,
    this.enabled = true,
    this.height = 64,
    this.logoSize = 26,
  });

  final AssetGenImage image;
  final VoidCallback? onTap;
  final bool enabled;
  final double height;
  final double logoSize;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: UITap(
        onTap: enabled ? onTap : null,
        child: Container(
          height: height,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: UIColorsToken.bgSurface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: image.image(
            width: logoSize,
            height: logoSize,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
