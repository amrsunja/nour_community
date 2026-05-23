import 'package:flutter/material.dart';
import 'package:nour/src/core/design_system/design_system.dart';

/// Rounded search bar used at the top of the adhkar list.
///
/// Stateless/controlled: feed [onChanged] into the presenter's `search`.
class SearchFieldWidget extends StatelessWidget {
  const SearchFieldWidget({
    super.key,
    required this.hintText,
    this.controller,
    this.onChanged,
    this.onClear,
  });

  final String hintText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final typo = UITheme.of(context).typo;
    final hasText = controller?.text.isNotEmpty ?? false;

    return TextField(
      controller: controller,
      onChanged: onChanged,
      cursorColor: UIColorsToken.textYellow,
      textInputAction: TextInputAction.search,
      onTapOutside: (_) => FocusScope.of(context).unfocus(),
      style: typo.inter.bodyMedium.copyWith(color: UIColorsToken.white),
      decoration: InputDecoration(
        filled: true,
        fillColor: UIColorsToken.bgSurface,
        hintText: hintText,
        hintStyle: typo.inter.bodyMedium.copyWith(
          color: UIColorsToken.textParagraph,
        ),
        prefixIcon: Icon(
          Icons.search,
          color: UIColorsToken.textParagraph,
          size: 22,
        ),
        suffixIcon: hasText
            ? IconButton(
                icon: Icon(
                  Icons.close,
                  color: UIColorsToken.textParagraph,
                  size: 20,
                ),
                onPressed: () {
                  controller?.clear();
                  onChanged?.call('');
                  onClear?.call();
                },
              )
            : null,
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        border: _border,
        enabledBorder: _border,
        focusedBorder: _border,
      ),
    );
  }

  OutlineInputBorder get _border => OutlineInputBorder(
    borderRadius: BorderRadius.circular(14),
    borderSide: BorderSide.none,
  );
}
