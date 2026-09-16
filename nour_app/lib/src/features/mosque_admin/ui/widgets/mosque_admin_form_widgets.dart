import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';

/// Field label with the optional "· optional" suffix (matches the post form).
class AdminLabel extends StatelessWidget {
  const AdminLabel(this.text, {super.key, this.optional = false, this.l10n, this.muted = false});
  final String text;
  final bool optional;
  final AppLocale? l10n;

  /// Section heading style used by the sadaqa settings page: headline weight,
  /// paragraph colour.
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final theme = UITheme.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: muted ? 12 : 8),
      child: Row(
        children: [
          Text(
            text,
            style: muted
                ? theme.typo.inter.headline.copyWith(color: UIColorsToken.textParagraph)
                : theme.typo.inter.bodyMedium.copyWith(color: UIColorsToken.white),
          ),
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
            Icon(Icons.expand_more, size: 18, color: UIColorsToken.textParagraph),
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
                      Icon(Icons.image_outlined, color: UIColorsToken.textParagraph),
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
      width: .infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 8
      ),
      decoration: BoxDecoration(color: UIColorsToken.bgSurface, borderRadius: BorderRadius.circular(10)),
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

/// Icon + title/subtitle + toggle row used at the bottom of the post forms
/// ("Notify followers", "Mark as urgent").
class PostToggleRow extends StatelessWidget {
  const PostToggleRow({
    super.key,
    required this.icon,
    this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  final String icon;
  final Color? iconColor;
  final String title;
  final String subtitle;
  final bool value;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = UITheme.of(context);
    return Row(
      children: [
        UIIcon(icon, color: iconColor ?? UIColorsToken.textYellow, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: theme.typo.inter.bodyMedium.copyWith(color: UIColorsToken.white)),
              Text(subtitle, style: theme.typo.inter.smallCaption.copyWith(color: UIColorsToken.textParagraph)),
            ],
          ),
        ),
        UIToggle(checked: value, disabled: !enabled, onCheck: onChanged),
      ],
    );
  }
}

/// Two-column editor for a short list of preset amounts (sadaqa suggested
/// amounts, membership fees). Each tile is an inline number field prefixed by
/// the currency symbol with a "×" to remove it; a full-width outlined button
/// appends a new empty tile and focuses it.
class AdminAmountsEditor extends StatefulWidget {
  const AdminAmountsEditor({
    super.key,
    required this.values,
    required this.onChanged,
    required this.addLabel,
    this.currencySymbol = '€',
    this.maxItems = 6,
  });

  final List<int> values;
  final ValueChanged<List<int>> onChanged;
  final String addLabel;
  final String currencySymbol;
  final int maxItems;

  @override
  State<AdminAmountsEditor> createState() => _AdminAmountsEditorState();
}

class _AdminAmountsEditorState extends State<AdminAmountsEditor> {
  final List<TextEditingController> _controllers = [];
  final List<FocusNode> _nodes = [];
  List<int> _emitted = const [];

  @override
  void initState() {
    super.initState();
    _seed(widget.values);
  }

  @override
  void didUpdateWidget(covariant AdminAmountsEditor old) {
    super.didUpdateWidget(old);
    // Re-seed only when the list changed outside of this editor (async load,
    // reset), never on the rebuild caused by our own onChanged.
    if (!_sameValues(widget.values, _emitted)) _seed(widget.values);
  }

  static bool _sameValues(List<int> a, List<int> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  void _seed(List<int> values) {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final n in _nodes) {
      n.dispose();
    }
    _controllers
      ..clear()
      ..addAll(values.map((v) => TextEditingController(text: '$v')));
    _nodes
      ..clear()
      ..addAll(values.map((_) => FocusNode()));
    _emitted = List.of(values);
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final n in _nodes) {
      n.dispose();
    }
    super.dispose();
  }

  void _emit() {
    _emitted = _controllers
        .map((c) => int.tryParse(c.text.trim()))
        .whereType<int>()
        .where((v) => v > 0)
        .toList();
    widget.onChanged(_emitted);
  }

  void _add() {
    setState(() {
      _controllers.add(TextEditingController());
      _nodes.add(FocusNode());
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _nodes.last.requestFocus());
    _emit();
  }

  void _removeAt(int i) {
    setState(() {
      _controllers.removeAt(i).dispose();
      _nodes.removeAt(i).dispose();
    });
    _emit();
  }

  @override
  Widget build(BuildContext context) {
    final theme = UITheme.of(context);
    const gap = 12.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final tileWidth = (constraints.maxWidth - gap) / 2;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_controllers.isNotEmpty)
              Wrap(
                spacing: gap,
                runSpacing: gap,
                children: [
                  for (var i = 0; i < _controllers.length; i++)
                    SizedBox(
                      width: tileWidth,
                      child: _AmountTile(
                        controller: _controllers[i],
                        focusNode: _nodes[i],
                        currencySymbol: widget.currencySymbol,
                        onChanged: (_) => _emit(),
                        onRemove: () => _removeAt(i),
                      ),
                    ),
                ],
              ),
            if (_controllers.isNotEmpty && _controllers.length < widget.maxItems) const SizedBox(height: gap),
            if (_controllers.length < widget.maxItems)
              UITap(
                onTap: _add,
                child: Container(
                  height: 56,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: UIColorsToken.yellow.withValues(alpha: .10),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: UIColorsToken.yellow.withValues(alpha: .35)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add, size: 20, color: UIColorsToken.textYellow),
                      const SizedBox(width: 8),
                      Text(
                        widget.addLabel,
                        style: theme.typo.inter.bodyMedium.copyWith(color: UIColorsToken.textYellow),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _AmountTile extends StatelessWidget {
  const _AmountTile({
    required this.controller,
    required this.focusNode,
    required this.currencySymbol,
    required this.onChanged,
    required this.onRemove,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String currencySymbol;
  final ValueChanged<String> onChanged;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = UITheme.of(context);
    return Container(
      height: 56,
      padding: const EdgeInsets.only(left: 14, right: 6),
      decoration: BoxDecoration(
        color: UIColorsToken.bgSurface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Text(
            currencySymbol,
            style: theme.typo.inter.body.copyWith(color: UIColorsToken.textYellow, fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              onChanged: onChanged,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(6)],
              style: theme.typo.inter.bodyMedium.copyWith(color: UIColorsToken.white),
              cursorColor: UIColorsToken.textYellow,
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.zero,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
            ),
          ),
          UITap(
            onTap: onRemove,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Icon(Icons.close, size: 18, color: UIColorsToken.white.withValues(alpha: .45)),
            ),
          ),
        ],
      ),
    );
  }
}

/// Locked field: shows a value the admin can read but not edit (account email,
/// SIREN…), styled like [UIInputField] so it sits inline in the same forms.
class AdminReadOnlyField extends StatelessWidget {
  const AdminReadOnlyField({
    super.key,
    required this.label,
    required this.value,
    this.hint,
    this.placeholder,
    this.icon = Icons.lock_outline,
  });

  final String label;
  final String? value;
  final String? hint;
  final String? placeholder;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = UITheme.of(context);
    final text = (value?.trim().isNotEmpty ?? false) ? value!.trim() : (placeholder ?? '—');
    final empty = !(value?.trim().isNotEmpty ?? false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.typo.inter.caption.copyWith(color: UIColorsToken.textParagraph)),
        const SizedBox(height: 6),
        Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: UIColorsToken.bgSurface.withValues(alpha: .6),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: UIColorsToken.white.withValues(alpha: .06)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.typo.inter.body.copyWith(
                    color: empty ? UIColorsToken.textParagraph : UIColorsToken.white.withValues(alpha: .75),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(icon, size: 16, color: UIColorsToken.textParagraph),
            ],
          ),
        ),
        if (hint != null) ...[
          const SizedBox(height: 6),
          Text(hint!, style: theme.typo.inter.caption.copyWith(color: UIColorsToken.textParagraph)),
        ],
      ],
    );
  }
}
