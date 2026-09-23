import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/gen/assets.gen.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';
import 'package:nour/src/core/providers/routing/navigation_services_provider.dart';
import 'package:nour/src/core/utils/constants/constants.dart';
import 'package:nour/src/features/auth/ui/state_management/auth_provider.dart';
import 'package:nour/src/features/mosques/data/models/mosque_enums.dart';
import 'package:nour/src/features/mosques/ui/state_management/my_mosque_provider.dart';
import 'package:url_launcher/url_launcher.dart';

/// Gate shown to a mosque account whose mosque is not approved yet
/// (pending_review / rejected / suspended). Nothing else is reachable until a
/// Nour admin approves the mosque (§3.4). Realtime flips to the admin shell.
@RoutePage()
class MosqueReviewPage extends HookConsumerWidget {
  const MosqueReviewPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = UITheme.of(context);
    final l10n = ref.watch(l10nProvider);
    final nav = ref.read(navigationServicesProvider);
    final presenter = ref.read(myMosqueProvider.notifier);
    final state = ref.watch(myMosqueProvider);
    final authLoading = ref.watch(authProvider.select((s) => s.isLoading));

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (state.mosque == null) await presenter.load();
        presenter.watchStatus();
      });
      return presenter.stopWatching;
    }, const []);

    // Approved → straight into the admin shell.
    ref.listen(myMosqueProvider.select((s) => s.isApproved), (_, approved) {
      if (approved) nav.toMosqueAdmin();
    });

    final mosque = state.mosque;
    final status = mosque?.status ?? MosqueStatus.pendingReview;

    final (title, message) = switch (status) {
      MosqueStatus.pendingReview => (l10n.mosque_review_pending_title, l10n.mosque_review_pending_message),
      MosqueStatus.rejected => (l10n.mosque_review_rejected_title, l10n.mosque_review_rejected_message),
      MosqueStatus.suspended => (l10n.mosque_review_suspended_title, l10n.mosque_review_suspended_message),
      MosqueStatus.approved => (l10n.mosque_review_pending_title, l10n.mosque_review_pending_message),
    };

    Future<void> logout() async {
      if (await ref.read(authProvider.notifier).logout()) nav.toRoot();
    }

    return UIGradientLinedScaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: kPageHorzPadding),
        child: Column(
          children: [
            Expanded(
              child: state.isLoading && mosque == null
                  ? const Center(child: UICircularProgressBar())
                  : SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const UISpace.vert(60),
                          UIAppearAnimation(
                            beginScale: 0.9,
                            child: UIGlowingBlock(
                              child: Assets.images.illustration3.image(width: 160, filterQuality: FilterQuality.high),
                            ),
                          ),
                          const SizedBox(height: 32),
                          if (mosque != null)
                            Text(
                              mosque.name,
                              textAlign: TextAlign.center,
                              style: theme.typo.inter.title.copyWith(color: UIColorsToken.textYellow),
                            ),
                          const SizedBox(height: 8),
                          UIAppearAnimation(
                            delay: const Duration(milliseconds: 200),
                            child: Text(
                              title,
                              textAlign: TextAlign.center,
                              style: theme.typo.inter.display.copyWith(color: UIColorsToken.white),
                            ),
                          ),
                          const SizedBox(height: 12),
                          UIAppearAnimation(
                            delay: const Duration(milliseconds: 320),
                            child: Text(
                              message,
                              textAlign: TextAlign.center,
                              style: theme.typo.inter.bodyLarge.copyWith(color: UIColorsToken.textParagraph),
                            ),
                          ),
                          if ((mosque?.reviewNote ?? '').isNotEmpty) ...[
                            const SizedBox(height: 20),
                            UICard(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              child: Text(
                                mosque!.reviewNote!,
                                style: theme.typo.inter.body.copyWith(color: UIColorsToken.white),
                              ),
                            ),
                          ],
                          const SizedBox(height: 24),
                          if (status != MosqueStatus.pendingReview)
                            UIButton.secondary(
                              label: l10n.mosque_review_contact_support,
                              fullWidth: true,
                              onTap: () => launchUrl(Uri.parse('$kSupportUrl?subject=${Uri.encodeComponent('Mosque ${mosque?.name ?? ''} — review')}')),
                            ),
                        ],
                      ),
                    ),
            ),
            UIButton.primary(
              label: l10n.common_refresh,
              fullWidth: true,
              isBusy: state.isLoading,
              onTap: () => presenter.load(),
            ),
            const UISpace.vert(10),
            UIButton.textual(
              label: l10n.profile_logout,
              fullWidth: true,
              isBusy: authLoading,
              contentColor: UIColorsToken.textParagraph,
              onTap: logout,
            ),
            const UISpace.vert(10),
          ],
        ),
      ),
    );
  }
}
