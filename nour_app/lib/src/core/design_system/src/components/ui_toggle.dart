import 'package:flutter/cupertino.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/utils/app_vibrations.dart';


/// iOS-style switch with local state synced from [checked].
///
/// Track: [UIColorsToken.pri500] when on, [UIColorsToken.neu200] when off;
/// thumb: [UIColorsToken.neu0]. Scaled for a compact layout ([scale] default `0.72`).
class UIToggle extends StatefulWidget {
  const UIToggle({
    super.key,
    this.checked = false,
    this.disabled = false,
    this.changeOpacity = true,
    this.onCheck,
    this.scale = 0.72,
  });

  /// Initial / controlled value from parent; updates sync via [didUpdateWidget].
  final bool checked;

  /// Invoked after internal state changes when the user toggles (not when syncing from [checked]).
  final void Function(bool)? onCheck;

  final bool disabled;

  /// When [disabled] is true, reduces opacity to 0.5 if `true`.
  final bool changeOpacity;

  /// Visual scale around [CupertinoSwitch] (default `0.72`).
  final double scale;

  /// Default switch intrinsic size before scaling (~56×34).
  static const double _switchWidth = 56;
  static const double _switchHeight = 34;

  @override
  State<UIToggle> createState() => _UIToggleState();
}

class _UIToggleState extends State<UIToggle> {
  late bool _checked;

  @override
  void initState() {
    super.initState();
    _checked = widget.checked;
  }

  @override
  void didUpdateWidget(covariant UIToggle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.checked != widget.checked) {
      setState(() => _checked = widget.checked);
    }
  }

  void _onChange(bool isChecked) {
    AppVibrations.buttonClick();
    setState(() => _checked = isChecked);
    widget.onCheck?.call(_checked);
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: widget.disabled && widget.changeOpacity ? 0.5 : 1,
      child: Transform.scale(
        scale: widget.scale,
        child: SizedBox(
          width: UIToggle._switchWidth,
          height: UIToggle._switchHeight,
          child: CupertinoSwitch(
            value: _checked,
            onChanged: widget.disabled ? null : _onChange,
            activeTrackColor: UIColorsToken.yellow,
            inactiveTrackColor: UIColorsToken.bgDeemphasize,
            thumbColor: UIColorsToken.white,
          ),
        ),
      ),
    );
  }
}
