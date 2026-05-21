import 'package:flutter/widgets.dart';
import 'package:nour/src/core/design_system/design_system.dart';

/// Greeting app bar showing the user's avatar, a greeting + name on the
/// leading edge, and an optional [trailing] widget (e.g. [UIStreakCard]).
///
/// ```dart
/// UIProfileAppBar(
///   name: 'Karim',
///   trailing: UIStreakCard(current: 2, total: 7),
/// )
/// ```
class UIProfileAppBar extends StatelessWidget implements PreferredSizeWidget {
  const UIProfileAppBar({
    super.key,
    required this.name,
    this.greeting = 'Salam Alaykoum,',
    this.avatarUrl,
    this.avatarInitial,
    this.avatarColor = const Color(0xff4F5BF0),
    this.avatarSize = 48,
    this.onAvatarTap,
    this.trailing,
    this.height = 72,
  });

  final String name;
  final String greeting;
  final String? avatarUrl;

  /// Initial rendered inside the avatar when [avatarUrl] is null.
  /// Falls back to the first character of [name].
  final String? avatarInitial;
  final Color avatarColor;
  final double avatarSize;
  final VoidCallback? onAvatarTap;
  final Widget? trailing;
  final double height;

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    final typo = UITheme.of(context).typo;

    return SafeArea(
      bottom: false,
      child: SizedBox(
        height: height,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              UIAvatar(
                url: avatarUrl,
                initial: (avatarInitial ?? (name.isNotEmpty ? name[0] : '?')) .toUpperCase(),
                color: avatarColor,
                size: avatarSize,
                onTap: onAvatarTap,
              ),
              const UISpace.horz(12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      greeting,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: typo.inter.bodyMedium
                          .copyWith(color: UIColorsToken.textParagraph),
                    ),
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: typo.inter.bodyMedium
                          .copyWith(color: UIColorsToken.white),
                    ),
                  ],
                ),
              ),
              if (trailing != null) ...[
                const UISpace.horz(12),
                trailing!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({
    required this.url,
    required this.initial,
    required this.color,
    required this.size,
    required this.typo,
    this.onTap,
  });

  final String? url;
  final String initial;
  final Color color;
  final double size;
  final UITypographyToken typo;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
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
                style: typo.inter.title.copyWith(color: UIColorsToken.white),
              )
            : null,
      ),
    );
  }
}
