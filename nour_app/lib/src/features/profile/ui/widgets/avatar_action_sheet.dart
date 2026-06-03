import 'package:flutter/material.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';

/// Action chosen from the avatar bottom sheet.
enum AvatarAction { camera, gallery, remove }

/// Bottom sheet offering avatar actions. [remove] is only listed when the user
/// already has an avatar set. Returns the picked [AvatarAction] (or null when
/// dismissed).
class AvatarActionSheet extends StatelessWidget {
  const AvatarActionSheet({super.key, required this.hasAvatar});

  final bool hasAvatar;

  static Future<AvatarAction?> show(
    BuildContext context, {
    required bool hasAvatar,
  }) {
    return showModalBottomSheet<AvatarAction>(
      context: context,
      backgroundColor: UIColorsToken.bgPrimary,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => AvatarActionSheet(hasAvatar: hasAvatar),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = UITheme.of(context);
    final l10n = AppLocale.of(context);

    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: UIColorsToken.stroke,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                l10n.profile_avatar_title,
                style: theme.typo.inter.largeTitle.copyWith(
                  color: UIColorsToken.white,
                ),
              ),
            ),
          ),
          _ActionRow(
            icon: Icons.photo_camera_outlined,
            label: l10n.profile_avatar_take_photo,
            onTap: () => Navigator.of(context).pop(AvatarAction.camera),
          ),
          _ActionRow(
            icon: Icons.photo_library_outlined,
            label: l10n.profile_avatar_choose_gallery,
            onTap: () => Navigator.of(context).pop(AvatarAction.gallery),
          ),
          if (hasAvatar)
            _ActionRow(
              icon: Icons.delete_outline,
              label: l10n.profile_avatar_remove,
              color: UIColorsToken.red,
              onTap: () => Navigator.of(context).pop(AvatarAction.remove),
            ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = UITheme.of(context);
    final fg = color ?? UIColorsToken.white;

    return UITap(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: fg, size: 22),
            const SizedBox(width: 14),
            Text(
              label,
              style: theme.typo.inter.bodyMedium.copyWith(color: fg),
            ),
          ],
        ),
      ),
    );
  }
}
