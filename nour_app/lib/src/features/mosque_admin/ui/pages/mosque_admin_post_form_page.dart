import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:nour/src/core/design_system/design_system.dart';

/// TODO(mosques): implemented in a later phase — placeholder keeps the router compiling.
@RoutePage()
class MosqueAdminPostFormPage extends StatelessWidget {
  const MosqueAdminPostFormPage({super.key, @PathParam('type') required this.type, this.postId});
  final String type;
  final int? postId;
  @override
  Widget build(BuildContext context) {
    return UIGradientLinedScaffold(
      appBar: UIAppBar(title: 'MosqueAdminPostFormPage', onBack: () => context.router.maybePop()),
      body: const Center(child: UICircularProgressBar()),
    );
  }
}
