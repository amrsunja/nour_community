import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';


@RoutePage()
class SourceRouterPage extends StatelessWidget {
	const SourceRouterPage({super.key});

	@override
	Widget build(BuildContext context) {
		return HeroControllerScope(
			controller: HeroController(),
			child: const AutoRouter()
		);
	}
}
