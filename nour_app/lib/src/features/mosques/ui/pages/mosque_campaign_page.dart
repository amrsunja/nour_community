import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:nour/src/core/design_system/design_system.dart';

/// TODO(mosques): implemented in a later phase — placeholder keeps the router compiling.
@RoutePage()
class MosqueCampaignPage extends StatelessWidget {
  const MosqueCampaignPage({super.key, @PathParam('id') required this.mosqueId, @PathParam('campaignId') required this.campaignId});
  final int mosqueId;
  final int campaignId;
  @override
  Widget build(BuildContext context) {
    return UIGradientLinedScaffold(
      appBar: UIAppBar(title: 'MosqueCampaignPage', onBack: () => context.router.maybePop()),
      body: const Center(child: UICircularProgressBar()),
    );
  }
}
