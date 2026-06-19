import 'package:flutter/material.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';

/// Destructive confirmation sheet for permanent account deletion.
///
/// Returns `true` when the user confirms, `false`/`null` otherwise. Mirrors the
/// avatar-remove confirmation style but uses a red confirm action to signal the
/// irreversible nature of the operation.
class DeleteAccountSheet extends StatelessWidget {
  const DeleteAccountSheet({super.key});

  static Future<bool?> show(BuildContext context) {
    return showModalBottomSheet<bool>(
      context: context,
      backgroundColor: UIColorsToken.bgPrimary,
      isDismissible: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const DeleteAccountSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = UITheme.of(context);
    final l10n = AppLocale.of(context);

    return SafeArea(
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
              l10n.profile_delete_account_title,
              style: theme.typo.inter.title.copyWith(color: UIColorsToken.red),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.profile_delete_account_message,
              style: theme.typo.inter.bodyMedium
                  .copyWith(color: UIColorsToken.textParagraph),
            ),
            const SizedBox(height: 24),
            UIButton.primary(
              label: l10n.profile_delete_account_confirm,
              fullWidth: true,
              onTap: () => Navigator.of(context).pop(true),
            ),
            const SizedBox(height: 8),
            UIButton.textual(
              label: l10n.profile_delete_account_cancel,
              fullWidth: true,
              onTap: () => Navigator.of(context).pop(false),
            ),
          ],
        ),
      ),
    );
  }
}
