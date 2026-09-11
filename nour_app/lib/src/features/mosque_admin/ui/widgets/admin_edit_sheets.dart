import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';
import 'package:nour/src/features/mosques/data/models/mosque_imam_model.dart';
import 'package:nour/src/features/mosques/ui/widgets/mosque_information_tab.dart';

/// Small bottom sheets used by the admin Information editor.
class AdminEditSheets {
  static Widget _shell(BuildContext ctx, {required String title, required List<Widget> children}) {
    final theme = UITheme.of(ctx);
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 16 + MediaQuery.of(ctx).viewInsets.bottom + MediaQuery.of(ctx).padding.bottom),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(child: Container(width: 72, height: 5, decoration: BoxDecoration(color: UIColorsToken.white, borderRadius: BorderRadius.circular(3)))),
            const SizedBox(height: 20),
            Text(title, textAlign: TextAlign.center, style: theme.typo.inter.display.copyWith(color: UIColorsToken.white)),
            const SizedBox(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }

  static Future<T?> _open<T>(BuildContext context, Widget Function(BuildContext) builder) => showModalBottomSheet<T>(
        context: context,
        isScrollControlled: true,
        backgroundColor: UIColorsToken.bgPrimary,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        builder: builder,
      );

  /// (total, men, women)
  static Future<(int?, int?, int?)?> capacity(BuildContext context, {required AppLocale l10n, int? total, int? men, int? women}) {
    final t = TextEditingController(text: total?.toString() ?? '');
    final m = TextEditingController(text: men?.toString() ?? '');
    final w = TextEditingController(text: women?.toString() ?? '');
    int? p(String s) => int.tryParse(s.trim());
    return _open<(int?, int?, int?)>(context, (ctx) => _shell(ctx, title: l10n.mosque_capacity, children: [
          UIInputField(controller: t, labelText: l10n.mosque_capacity, keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly]),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: UIInputField(controller: m, labelText: l10n.mosque_capacity_men, keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly])),
              const SizedBox(width: 12),
              Expanded(child: UIInputField(controller: w, labelText: l10n.mosque_capacity_women, keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly])),
            ],
          ),
          const SizedBox(height: 20),
          UIButton.primary(label: l10n.common_save, fullWidth: true, onTap: () => Navigator.of(ctx).pop((p(t.text), p(m.text), p(w.text)))),
        ]));
  }

  static Future<int?> founded(BuildContext context, {required AppLocale l10n, int? year}) {
    final c = TextEditingController(text: year?.toString() ?? '');
    return _open<int>(context, (ctx) => _shell(ctx, title: l10n.mosque_founded, children: [
          UIInputField(controller: c, hintText: '1973', keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(4)]),
          const SizedBox(height: 20),
          UIButton.primary(label: l10n.common_save, fullWidth: true, onTap: () {
            final y = int.tryParse(c.text.trim());
            if (y != null && y > 1000 && y <= DateTime.now().year) Navigator.of(ctx).pop(y);
          }),
        ]));
  }

  static const _languages = ['fr', 'ar', 'en', 'tr', 'ur', 'bn', 'de', 'nl', 'es', 'it', 'id', 'ms', 'ru', 'so', 'wo', 'ber'];

  static Future<List<String>?> languages(BuildContext context, {required AppLocale l10n, required List<String> selected}) {
    final sel = [...selected];
    String query = '';
    return _open<List<String>>(context, (ctx) => StatefulBuilder(builder: (ctx, setState) {
          final theme = UITheme.of(ctx);
          final visible = _languages.where((c) => query.isEmpty || MosqueInformationTab.languageName(c).toLowerCase().contains(query.toLowerCase())).toList();
          return _shell(ctx, title: l10n.mosque_khutbah_languages, children: [
            UIInputField(hintText: l10n.mosque_search_language, onChanged: (v) => setState(() => query = v)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final c in visible)
                  UITap(
                    onTap: () => setState(() => sel.contains(c) ? sel.remove(c) : sel.add(c)),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: sel.contains(c) ? const Color(0xff252219) : UIColorsToken.bgSurface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: sel.contains(c) ? UIColorsToken.textYellow : Colors.transparent),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(MosqueInformationTab.languageFlag(c), style: const TextStyle(fontSize: 16)),
                          const SizedBox(width: 8),
                          Text(MosqueInformationTab.languageName(c), style: theme.typo.inter.bodyMedium.copyWith(color: sel.contains(c) ? UIColorsToken.textYellow : UIColorsToken.white)),
                          if (sel.contains(c)) ...[const SizedBox(width: 6), Icon(Icons.close, size: 14, color: UIColorsToken.textParagraph)],
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            UIButton.primary(label: l10n.common_save, fullWidth: true, onTap: () => Navigator.of(ctx).pop(sel)),
          ]);
        }));
  }

  /// "Add an Imam" (Figma 1137:1802). Returns the model to upsert, or the
  /// sentinel [deleteImam] when the admin removed it.
  static const deleteImam = -1;

  static Future<MosqueImamModel?> imam(BuildContext context, {
    required AppLocale l10n,
    required int mosqueId,
    MosqueImamModel? existing,
    required Future<String?> Function(File) upload,
  }) {
    final name = TextEditingController(text: existing?.fullName ?? '');
    final role = TextEditingController(text: existing?.role ?? '');
    final since = TextEditingController(text: existing?.sinceYear?.toString() ?? '');
    final bio = TextEditingController(text: existing?.bio ?? '');
    String? photo = existing?.photoUrl;
    bool busy = false;
    return _open<MosqueImamModel>(context, (ctx) => StatefulBuilder(builder: (ctx, setState) {
          final theme = UITheme.of(ctx);
          return _shell(ctx, title: existing == null ? l10n.mosque_add_imam : l10n.mosque_edit_imam, children: [
            Center(
              child: UITap(
                onTap: () async {
                  final x = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 800, imageQuality: 85);
                  if (x == null) return;
                  setState(() => busy = true);
                  final url = await upload(File(x.path));
                  setState(() {
                    busy = false;
                    if (url != null) photo = url;
                  });
                },
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: UIColorsToken.bgSurface,
                      backgroundImage: photo != null ? NetworkImage(photo!) : null,
                      child: photo == null ? const Icon(Icons.add_a_photo_outlined, color: UIColorsToken.textYellow) : null,
                    ),
                    const SizedBox(height: 6),
                    Text('${l10n.mosque_add_photo} · ${l10n.common_optional}', style: theme.typo.inter.smallCaption.copyWith(color: UIColorsToken.textParagraph)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            UIInputField(controller: name, labelText: l10n.mosque_imam_full_name, hintText: 'Yassine El-Amri'),
            const SizedBox(height: 12),
            UIInputField(controller: role, labelText: '${l10n.mosque_imam_role} · ${l10n.common_optional}', hintText: 'Principal Imam'),
            const SizedBox(height: 12),
            UIInputField(controller: since, labelText: l10n.mosque_imam_since, hintText: '2017', keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(4)]),
            const SizedBox(height: 12),
            UIInputField(controller: bio, labelText: '${l10n.mosque_imam_bio} · ${l10n.common_optional}', hintText: l10n.mosque_imam_bio_hint, textInputAction: TextInputAction.done),
            const SizedBox(height: 20),
            UIButton.primary(
              label: l10n.common_save,
              fullWidth: true,
              isBusy: busy,
              onTap: () {
                if (name.text.trim().length < 2) return;
                Navigator.of(ctx).pop(MosqueImamModel(
                  id: existing?.id ?? 0,
                  mosqueId: mosqueId,
                  fullName: name.text.trim(),
                  role: role.text.trim().isEmpty ? null : role.text.trim(),
                  sinceYear: int.tryParse(since.text.trim()),
                  bio: bio.text.trim().isEmpty ? null : bio.text.trim(),
                  photoUrl: photo,
                  position: existing?.position ?? 0,
                ));
              },
            ),
            if (existing != null) ...[
              const SizedBox(height: 8),
              UIButton.textual(
                label: l10n.common_delete,
                fullWidth: true,
                contentColor: UIColorsToken.red,
                onTap: () => Navigator.of(ctx).pop(MosqueImamModel(id: deleteImam, mosqueId: mosqueId, fullName: '')),
              ),
            ],
          ]);
        }));
  }
}
