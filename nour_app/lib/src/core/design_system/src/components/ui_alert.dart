import 'package:flutter/material.dart';
import 'package:nour/src/core/design_system/design_system.dart';


class UIAlert extends StatelessWidget {
	final String label;
	final String? assetIcon;
	final Color color;
	final Color contentColor;

	UIAlert.success({
		super.key,
		required this.label,
	}) : color = Color(0xff00A280).withValues(alpha: .2),
       assetIcon = UIIconsToken.icons.check,
			 contentColor = UIColorsToken.white;

	UIAlert.error({
		super.key,
		required this.label
	}) : color = Color(0xffFF5353).withValues(alpha: .2),
       assetIcon = UIIconsToken.icons.check,
			 contentColor = UIColorsToken.white;

	const UIAlert.info({
		super.key,
		required this.label
	}) : color = UIColorsToken.bgTertiaryGreen,
       assetIcon = null,
			 contentColor = UIColorsToken.white;

	@override
	Widget build(BuildContext context) {
    final theme = UITheme.of(context);
		return Container(
			padding: const EdgeInsets.all(12),
			decoration: BoxDecoration(
				color: color,
				borderRadius: BorderRadius.circular(12)
			),
			child: Row(
			  children: [
          if (assetIcon != null)
            UIIcon(
              assetIcon!,
            ),
			    Flexible(
			      child: Text(
        label,
              style: theme.typo.inter.bodySmall.copyWith(
                color: contentColor
              ),
			      ),
			    ),
			  ],
			),
		);
	}
}
