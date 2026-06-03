import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';
import 'package:nour/src/features/profile/ui/state_management/profile_provider.dart';
import 'package:nour/src/features/profile/ui/state_management/profile_state.dart';
import 'package:nour/src/features/profile/ui/widgets/avatar_action_sheet.dart';

/// Identity avatar with an action badge.
///
/// - No avatar yet  → camera badge; tapping the badge or the avatar opens the
///   image-source sheet (camera / gallery).
/// - Avatar set     → trash badge; tapping the badge asks to confirm removal,
///   tapping the avatar opens the full action sheet (change / remove).
/// While an upload or delete is in flight the avatar shows a spinner overlay
/// and all taps are absorbed.
class ProfileAvatar extends HookConsumerWidget {
  const ProfileAvatar({super.key, required this.initial});

  final String initial;

  static const double _size = 100;
  static final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final url = ref.watch(profileProvider.select((s) => s.profile?.avatar));
    final status = ref.watch(profileProvider.select((s) => s.avatarStatus));

    final hasAvatar = url != null && url.isNotEmpty;
    final busy = status != AvatarStatus.idle;

    Future<void> pick(ImageSource source) async {
      final XFile? file = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (file == null) return;
      await ref.read(profileProvider.notifier).uploadAvatar(File(file.path));
    }

    Future<bool> confirmRemove() async {
      final result = await _confirmRemove(context);
      return result ?? false;
    }

    Future<void> handleAction(AvatarAction action) async {
      switch (action) {
        case AvatarAction.camera:
          await pick(ImageSource.camera);
        case AvatarAction.gallery:
          await pick(ImageSource.gallery);
        case AvatarAction.remove:
          if (await confirmRemove()) {
            await ref.read(profileProvider.notifier).deleteAvatar();
          }
      }
    }

    Future<void> openSheet() async {
      final action =
          await AvatarActionSheet.show(context, hasAvatar: hasAvatar);
      if (action == null) return;
      await handleAction(action);
    }

    Future<void> onBadgeTap() async {
      if (!hasAvatar) {
        await openSheet();
        return;
      }
      if (await confirmRemove()) {
        await ref.read(profileProvider.notifier).deleteAvatar();
      }
    }

    return SizedBox(
      width: _size,
      height: _size,
      child: Stack(
        children: [
          UIAvatar(
            url: url,
            initial: initial.toUpperCase(),
            color: const Color(0xff4F5BF0),
            size: _size,
            onTap: busy ? null : openSheet,
          ),
          if (busy)
            Container(
              width: _size,
              height: _size,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: UIColorsToken.black.withValues(alpha: 0.45),
              ),
              child: const UICircularProgressBar(
                color: UIColorsToken.white,
                size: 28,
              ),
            ),
          PositionedDirectional(
            end: 4,
            bottom: 4,
            child: UITap(
              onTap: busy ? null : onBadgeTap,
              child: Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: UIColorsToken.bgSurface,
                  border: Border.all(
                    color: hasAvatar ? UIColorsToken.red : UIColorsToken.yellow,
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  hasAvatar
                      ? Icons.delete_outline
                      : Icons.photo_camera_outlined,
                  size: 16,
                  color: hasAvatar ? UIColorsToken.red : UIColorsToken.yellow,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<bool?> _confirmRemove(BuildContext context) {
    final theme = UITheme.of(context);
    final l10n = AppLocale.of(context);

    return showModalBottomSheet<bool>(
      context: context,
      backgroundColor: UIColorsToken.bgPrimary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: UIColorsToken.stroke,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                l10n.profile_avatar_remove_title,
                style: theme.typo.inter.title
                    .copyWith(color: UIColorsToken.white),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.profile_avatar_remove_message,
                style: theme.typo.inter.bodyMedium
                    .copyWith(color: UIColorsToken.textParagraph),
              ),
              const SizedBox(height: 24),
              UIButton.primary(
                label: l10n.profile_avatar_remove,
                fullWidth: true,
                onTap: () => Navigator.of(ctx).pop(true),
              ),
              const SizedBox(height: 8),
              UIButton.textual(
                label: l10n.profile_avatar_cancel,
                fullWidth: true,
                onTap: () => Navigator.of(ctx).pop(false),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
