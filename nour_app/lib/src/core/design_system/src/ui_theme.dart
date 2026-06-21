import 'package:flutter/widgets.dart';

import '../design_system.dart';


class UITheme extends InheritedWidget {
  const UITheme({
		super.key,
		required this.data,
		required super.child,
	});

	final UIThemeData data;

	/// Return ThemeData
	static UIThemeData of(BuildContext context)
		=> context.dependOnInheritedWidgetOfExactType<UITheme>()!.data;

  @override
  bool updateShouldNotify(covariant UITheme oldWidget) {
		return data != oldWidget.data;
  }
}
