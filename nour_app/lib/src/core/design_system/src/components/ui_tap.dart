import 'package:flutter/material.dart';


class UITap extends StatelessWidget {
	const UITap({
		super.key,
		this.onTap,
    this.onLongPress,
		this.child,
	});

	final VoidCallback? onTap;
	final VoidCallback? onLongPress;
	final Widget? child;

	@override
	Widget build(BuildContext context) {
		final color = Colors.transparent;
		return Material(
			color: Colors.transparent,
		  child: InkWell(
		  	onTap: onTap,
        onLongPress: onLongPress,
        hoverColor: color,
        focusColor: color,
		  	highlightColor: color,
		  	splashColor: color,
        overlayColor: WidgetStateProperty.all(color),
		  	child: child,
		  ),
		);
	}
}
