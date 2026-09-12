import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';
import 'package:nour/src/features/mosque_admin/ui/state_management/mosque_admin_mosque_provider.dart';
import 'package:nour/src/features/mosques/ui/state_management/my_mosque_provider.dart';
import 'package:nour/src/features/profile/ui/widgets/avatar_action_sheet.dart';

/// Mosque identity avatar with an action badge — the mosque counterpart of
/// `ProfileAvatar`. Reads `mosques.logo_url` (so a logo set from the mosque
/// editor shows up here) and writes it back through the admin presenter.
///
/// - No logo yet → camera badge; tapping opens the image-source sheet.
/// - Logo set    → trash badge; tapping the badge confirms removal, tapping
///   the avatar opens the full action sheet (change / remove).
class MosqueSettingsAvatar extends HookConsumerWidget {
  const MosqueSettingsAvatar({super.key});

  static const double _size = 100;
  static final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mosque = ref.watch(myMosqueProvider.select((s) => s.mosque));
    final url = mosque?.logoUrl;
    final admin = ref.read(mosqueAdminMosqueProvider.notifier);
    final uploading = useState(false);
    final busy = uploading.value ||
        ref.watch(mosqueAdminMosqueProvider.select((s) => s.isSaving));

    final hasLogo = url != null && url.trim().isNotEmpty;
    final initial = (mosque?.initials.isNotEmpty ?? false) ? mosque!.initials : '?';

    Future<void> pick(ImageSource source) async {
      if (mosque == null) return;
      final XFile? file = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (file == null) return;
      uploading.value = true;
      final uploaded = await admin.upload(File(file.path), folder: 'logo');
      uploading.value = false;
      if (uploaded == null) return;
      await admin.saveMosque(mosque.copyWith(logoUrl: uploaded));
    }

    Future<bool> confirmRemove() async =>
        await _confirmRemove(context) ?? false;

    Future<void> handleAction(AvatarAction action) async {
      switch (action) {
        case AvatarAction.camera:
          await pick(ImageSource.camera);
        case AvatarAction.gallery:
          await pick(ImageSource.gallery);
        case AvatarAction.remove:
          if (mosque != null && await confirmRemove()) {
            await admin.saveMosque(mosque.copyWith(clearLogo: true));
          }
      }
    }

    Future<void> openSheet() async {
      final action = await AvatarActionSheet.show(context, hasAvatar: hasLogo);
      if (action == null) return;
      await handleAction(action);
    }

    Future<void> onBadgeTap() async {
      if (!hasLogo) {
        await openSheet();
        return;
      }
      if (mosque != null && await confirmRemove()) {
        await admin.saveMosque(mosque.copyWith(clearLogo: true));
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
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: UIColorsToken.bgSurface,
                  border: Border.all(
                    color: hasLogo ? UIColorsToken.red : UIColorsToken.yellow,
                    width: 0.6,
                  ),
                ),
                child: Icon(
                  hasLogo ? Icons.delete_outline : Icons.photo_camera_outlined,
                  size: 16,
                  color: hasLogo ? UIColorsToken.red : UIColorsToken.yellow,
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
                l10n.mosque_settings_logo_remove_title,
                style:
                    theme.typo.inter.title.copyWith(color: UIColorsToken.white),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.mosque_settings_logo_remove_message,
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
