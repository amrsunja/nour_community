import 'package:flutter/material.dart';
import 'package:nour/src/core/design_system/design_system.dart';


class UICircularProgressBar extends StatelessWidget {
	final Color? color;
	final double? size;

	const UICircularProgressBar({
		super.key,
		this.color,
		this.size
	});

	@override
	Widget build(BuildContext context) {
		final ksize = size ?? 15;
		return SizedBox(
			height: ksize,
			width: ksize,
			child: CircularProgressIndicator(
				color: color ?? UIColorsToken.white,
				strokeWidth: 1,
			),
		);
	}
}
