import 'package:flutter/material.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';


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
    final locale = Localizations.localeOf(context);

		return UITap(
			onTap: onTap,
			child: Transform.flip(
        flipX: locale.languageCode == L10n.ar.languageCode,// || locale.languageCode == L10n.ur.languageCode,
			  child: Padding(
			    padding: padding ?? const EdgeInsets.all(0),
			    child: UIIconsToken.toIcon(
			    	assetIcon,
			    	color: color ?? theme.iconColor,
			    	size: size,
			    	alignment: alignment
			    ),
			  ),
			)
		);
	}
}
