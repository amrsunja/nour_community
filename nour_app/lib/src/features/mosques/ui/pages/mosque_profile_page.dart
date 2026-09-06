import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:nour/src/core/design_system/design_system.dart';

/// TODO(mosques): implemented in a later phase — placeholder keeps the router compiling.
@RoutePage()
class MosqueProfilePage extends StatelessWidget {
  const MosqueProfilePage({super.key, @PathParam('id') required this.mosqueId, @QueryParam('tab') this.tab, @QueryParam('postId') this.postId});
  final int mosqueId;
  final String? tab;
  final int? postId;
  @override
  Widget build(BuildContext context) {
    return UIGradientLinedScaffold(
      appBar: UIAppBar(title: 'MosqueProfilePage', onBack: () => context.router.maybePop()),
      body: const Center(child: UICircularProgressBar()),
    );
  }
}
