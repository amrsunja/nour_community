import 'package:flutter/material.dart';
import 'package:nour/src/core/design_system/design_system.dart';


class UIIcon extends StatelessWidget {
	final String assetIcon;
	final Color? color;
	final double? size;
	final Alignment? alignment;
	final EdgeInsetsGeometry? padding;
	final VoidCallback? onTap;

	const UIIcon(
		this.assetIcon, {
		super.key,
		this.color,
		this.size,
		this.alignment,
		this.padding,
		this.onTap,
	});

	@override
	Widget build(BuildContext context) {
    final theme = UITheme.of(context).colors;
		return UITap(
			onTap: onTap,
			child: Padding(
			  padding: padding ?? const EdgeInsets.all(0),
			  child: UIIconsToken.toIcon(
			  	assetIcon,
			  	color: color ?? theme.iconColor,
			  	size: size,
			  	alignment: alignment
			  ),
			)
		);
	}
}
