import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nour/src/core/design_system/design_system.dart';

/// Design-system text input. Works standalone or inside a [Form] (it is a
/// [TextFormField], so [validator] participates in form validation).
///
/// Behaviour:
/// - Tapping outside the field unfocuses it (via [TextField.onTapOutside]).
/// - Pressing the keyboard action (default [TextInputAction.next]) moves focus
///   to the next focusable field; on the last field pass
///   [TextInputAction.done] to dismiss the keyboard instead.
class UIInputField extends StatefulWidget {
  const UIInputField({
    super.key,
    this.controller,
    this.focusNode,
    this.labelText,
    this.hintText,
    this.validator,
    this.keyboardType,
    this.textAlign = TextAlign.start,
    this.textInputAction = TextInputAction.next,
    this.obscureText = false,
    this.enabled = true,
    this.inputFormatters,
    this.onSubmitted,
    this.onChanged,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? labelText;
  final String? hintText;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final TextAlign textAlign;
  final TextInputAction textInputAction;
  final bool obscureText;
  final bool enabled;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;

  @override
  State<UIInputField> createState() => _UIInputFieldState();
}

class _UIInputFieldState extends State<UIInputField> {
  FocusNode? _internalNode;

  FocusNode get _focusNode =>
      widget.focusNode ?? (_internalNode ??= FocusNode());

  @override
  void dispose() {
    _internalNode?.dispose();
    super.dispose();
  }

  void _handleSubmitted(String value) {
    if (widget.onSubmitted != null) {
      widget.onSubmitted!(value);
      return;
    }
    // Default: advance to the next focusable field, or close the keyboard
    // when there is none.
    if (widget.textInputAction == TextInputAction.next) {
      FocusScope.of(context).nextFocus();
    } else {
      FocusScope.of(context).unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = UITheme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.labelText != null) ...[
          Text(
            widget.labelText!,
            style: theme.typo.inter.title.copyWith(
              color: UIColorsToken.white,
            ),
          ),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: widget.controller,
          focusNode: _focusNode,
          validator: widget.validator,
          keyboardType: widget.keyboardType,
          textAlign: widget.textAlign,
          textInputAction: widget.textInputAction,
          obscureText: widget.obscureText,
          enabled: widget.enabled,
          inputFormatters: widget.inputFormatters,
          onChanged: widget.onChanged,
          onFieldSubmitted: _handleSubmitted,
          onTapOutside: (_) => _focusNode.unfocus(),
          cursorColor: UIColorsToken.textYellow,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          style: theme.typo.inter.headline.copyWith(
            color: UIColorsToken.white,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: UIColorsToken.bgSurface,
            hintText: widget.hintText,
            hintStyle: theme.typo.inter.bodyMedium.copyWith(
              color: UIColorsToken.textParagraph,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            border: _border(Colors.transparent),
            enabledBorder: _border(Colors.transparent),
            focusedBorder: _border(UIColorsToken.textYellow, width: 1.5),
            errorBorder: _border(UIColorsToken.red),
            focusedErrorBorder: _border(UIColorsToken.red, width: 1.5),
            errorStyle: theme.typo.inter.bodySmall.copyWith(
              color: UIColorsToken.red,
            ),
          ),
        ),
      ],
    );
  }

  OutlineInputBorder _border(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}
