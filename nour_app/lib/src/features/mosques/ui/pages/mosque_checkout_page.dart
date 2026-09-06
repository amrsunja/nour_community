import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:nour/src/core/design_system/design_system.dart';

/// TODO(mosques): implemented in a later phase — placeholder keeps the router compiling.
@RoutePage()
class MosqueCheckoutPage extends StatelessWidget {
  const MosqueCheckoutPage({super.key, @PathParam('id') required this.mosqueId, @QueryParam('amount') required this.amount, @QueryParam('frequency') required this.frequency, @QueryParam('campaignId') this.campaignId, @QueryParam('membershipId') this.membershipId});
  final int mosqueId;
  final double amount;
  final String frequency;
  final int? campaignId;
  final int? membershipId;
  @override
  Widget build(BuildContext context) {
    return UIGradientLinedScaffold(
      appBar: UIAppBar(title: 'MosqueCheckoutPage', onBack: () => context.router.maybePop()),
      body: const Center(child: UICircularProgressBar()),
    );
  }
}
