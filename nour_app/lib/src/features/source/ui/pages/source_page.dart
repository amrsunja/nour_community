import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';


@RoutePage()
class SourcePage extends StatelessWidget {
	const SourcePage({super.key});

	@override
	Widget build(BuildContext context) {
		return Scaffold(
      body: Center(
        child: Text('Source')
      )
    );
	}
}
