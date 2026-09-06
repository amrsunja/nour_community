import 'package:flutter/material.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';

/// Field label with the optional "· optional" suffix (matches the post form).
class AdminLabel extends StatelessWidget {
  const AdminLabel(this.text, {super.key, this.optional = false, this.l10n});
  final String text;
  final bool optional;
  final AppLocale? l10n;

  @override
  Widget build(BuildContext context) {
    final theme = UITheme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(text, style: theme.typo.inter.bodyMedium.copyWith(color: UIColorsToken.white)),
          if (optional && l10n != null) Text(' · ${l10n!.common_optional}', style: theme.typo.inter.caption.copyWith(color: UIColorsToken.textParagraph)),
        ],
      ),
    );
  }
}

/// Multi-line filled text area.
class AdminTextArea extends StatelessWidget {
  const AdminTextArea({super.key, required this.controller, this.hint, this.minLines = 3, this.maxLines = 8, this.onChanged});
  final TextEditingController controller;
  final String? hint;
  final int minLines;
  final int maxLines;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = UITheme.of(context);
    return TextField(
      controller: controller,
      minLines: minLines,
      maxLines: maxLines,
      onChanged: onChanged,
      style: theme.typo.inter.body.copyWith(color: UIColorsToken.white),
      decoration: InputDecoration(
        filled: true,
        fillColor: UIColorsToken.bgSurface,
        hintText: hint,
        hintStyle: theme.typo.inter.body.copyWith(color: UIColorsToken.textParagraph),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
      ),
    );
  }
}

/// Tappable "picker" box (date, select…).
class AdminPickerBox extends StatelessWidget {
  const AdminPickerBox({super.key, required this.icon, required this.text, required this.onTap});
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = UITheme.of(context);
    return UITap(
      onTap: onTap,
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(color: UIColorsToken.bgSurface, borderRadius: BorderRadius.circular(10)),
        child: Row(
          children: [
            Icon(icon, size: 18, color: UIColorsToken.textParagraph),
            const SizedBox(width: 8),
            Expanded(child: Text(text, style: theme.typo.inter.body.copyWith(color: UIColorsToken.white))),
            const Icon(Icons.expand_more, size: 18, color: UIColorsToken.textParagraph),
          ],
        ),
      ),
    );
  }
}

/// Cover picker box (image or placeholder).
class AdminCoverBox extends StatelessWidget {
  const AdminCoverBox({super.key, required this.url, required this.onTap, required this.placeholder, this.busy = false});
  final String? url;
  final VoidCallback onTap;
  final String placeholder;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final theme = UITheme.of(context);
    return UITap(
      onTap: busy ? null : onTap,
      child: Container(
        height: url == null ? 150 : 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: UIColorsToken.stroke.withValues(alpha: .4)),
          image: url == null ? null : DecorationImage(image: NetworkImage(url!), fit: BoxFit.cover),
        ),
        child: busy
            ? const Center(child: UICircularProgressBar())
            : url != null
                ? null
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.image_outlined, color: UIColorsToken.textParagraph),
                      const SizedBox(height: 6),
                      Text(placeholder, style: theme.typo.inter.caption.copyWith(color: UIColorsToken.textParagraph)),
                    ],
                  ),
      ),
    );
  }
}

/// Row with a label + UIToggle (settings pages).
class AdminToggleRow extends StatelessWidget {
  const AdminToggleRow({super.key, required this.title, this.subtitle, required this.value, required this.onChanged, this.enabled = true});
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = UITheme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(color: UIColorsToken.bgSurface, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.typo.inter.bodyMedium.copyWith(color: UIColorsToken.white)),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(subtitle!, style: theme.typo.inter.caption.copyWith(color: UIColorsToken.textParagraph)),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          UIToggle(checked: value, disabled: !enabled, onCheck: onChanged),
        ],
      ),
    );
  }
}

/// KPI tile used by the donation analytics (Figma "Total raised…").
class AdminStatTile extends StatelessWidget {
  const AdminStatTile({super.key, required this.label, required this.value, this.hint, this.accent = false});
  final String label;
  final String value;
  final String? hint;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final theme = UITheme.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: UIColorsToken.bgSurface, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.typo.inter.caption.copyWith(color: UIColorsToken.textParagraph)),
          const SizedBox(height: 6),
          Text(value, style: theme.typo.inter.title.copyWith(color: accent ? UIColorsToken.textYellow : UIColorsToken.white, fontWeight: FontWeight.w700)),
          if (hint != null) ...[
            const SizedBox(height: 2),
            Text(hint!, style: theme.typo.inter.smallCaption.copyWith(color: UIColorsToken.textParagraph)),
          ],
        ],
      ),
    );
  }
}
