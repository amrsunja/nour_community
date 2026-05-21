import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';


@RoutePage()
class ImpactPage extends StatelessWidget {
	const ImpactPage({super.key});

	@override
	Widget build(BuildContext context) {
		return Scaffold(
      body: Center(
        child: Text('Impact')
      )
    );
	}
}
