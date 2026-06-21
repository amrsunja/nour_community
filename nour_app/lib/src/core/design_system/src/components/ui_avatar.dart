import 'package:flutter/material.dart';
import 'package:nour/src/core/design_system/design_system.dart';

class UIAvatar extends StatelessWidget {
  const UIAvatar({
    super.key,
    required this.url,
    required this.initial,
    required this.color,
    required this.size,
    this.onTap,
  });

  final String? url;
  final String initial;
  final Color color;
  final double size;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final typo = UITheme.of(context).typo;
    return UITap(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          image: url != null
            ? DecorationImage(image: NetworkImage(url!), fit: BoxFit.cover)
            : null,
        ),
        child: url == null
          ? Text(
              initial,
              style: typo.inter.largeTitle.copyWith(
                fontSize: size / 2
              ),
            )
          : null,
      ),
    );
  }
}
