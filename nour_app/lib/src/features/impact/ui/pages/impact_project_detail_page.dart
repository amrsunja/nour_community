import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/gen/assets.gen.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';
import 'package:nour/src/core/providers/routing/navigation_services_provider.dart';
import 'package:nour/src/core/utils/share_services.dart';
import 'package:nour/src/features/impact/ui/widgets/category_badge_widget.dart';
import 'package:nour/src/features/impact/ui/widgets/donors_avatars_widget.dart';
import 'package:nour/src/features/impact/ui/widgets/project_cover_carousel.dart';
import 'package:nour/src/features/impact/ui/widgets/project_tiers_section.dart';
import 'package:nour/src/features/payments/ui/widgets/donation_amount_sheet.dart';
import 'package:nour/src/features/payments/ui/widgets/project_transactions_section.dart';

import '../../data/datasources/impact_remote_datasource.dart';
import '../../data/models/impact_project_model.dart';
import '../../data/models/impact_project_tier_model.dart';
import '../../data/models/partner_organization_model.dart';
import '../state_management/impact_project_detail_provider.dart';
import '../widgets/impact_money.dart';
import '../widgets/project_story_card_widget.dart';

/// Impact project detail. Cover carousel, funding progress, about section,
/// "Your donation provides" tiers, partner organization, field-stories timeline
/// and the transparency section. The "Donate now" CTA (and a tier tap) opens the
/// amount sheet → Checkout page → Donation reward page.
@RoutePage()
class ImpactProjectDetailPage extends HookConsumerWidget {
  const ImpactProjectDetailPage({
    super.key,
    @PathParam('id') required this.projectId,
  });

  final int projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(l10nProvider);
    final langCode = Localizations.localeOf(context).languageCode;
    final presenter = ref.read(impactProjectDetailProvider(projectId).notifier);
    final state = ref.watch(impactProjectDetailProvider(projectId));

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) => presenter.init());
      return null;
    }, const []);

    final project = state.project;

    Future<void> share() {
      if (project == null) return Future.value();
      return ShareServices.shareProject(
        title: project.title(langCode),
        description: project.subtitle(langCode),
        projectId: project.id,
      );
    }

    final nav = ref.read(navigationServicesProvider);

    /// Step 1 (amount sheet) → step 2 (checkout). The impact-project flow is
    /// always a sadaqa (`isZakat = false`); the zakat calculator will reuse the
    /// checkout with `isZakat = true`.
    Future<void> donate({double? initialAmount}) async {
      if (project == null) return;
      final selection = await DonationAmountSheet.show(
        context,
        currency: project.currency,
        presetAmounts: project.presetAmounts,
        initialAmount: initialAmount,
      );
      if (selection == null) return;
      nav.toCheckout(
        projectId: project.id,
        amount: selection.amount,
        frequency: selection.frequency,
        isZakat: false,
      );
    }

    return Scaffold(
      appBar: UIAppBar(
        onBack: context.pop,
        leadingIcons: [
          UIIcon(
            UIIconsToken.icons.share,
            color: UIColorsToken.white,
            size: 22,
            onTap: project == null ? null : share,
          ),
          _FavoriteIcon(
            isFavorite: state.isFavorite,
            onTap: project == null ? null : presenter.toggleFavorite,
          ),
        ],
      ),
      bottomNavigationBar: project == null
          ? null
          : SafeArea(
              minimum: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: UIButton.primary(
                label: l10n.impact_donate_now,
                fullWidth: true,
                onTap: () => donate(),
              ),
            ),
      body: SafeArea(
        top: false,
        child: state.isLoading && project == null
            ? const Center(child: UICircularProgressBar())
            : project == null
            ? _DetailError(onRetry: presenter.init)
            : _DetailBody(
                project: project,
                langCode: langCode,
                l10n: l10n,
                onTierTap: (tier) => donate(initialAmount: tier.amount),
              ),
      ),
    );
  }
}

class _DetailBody extends HookWidget {
  const _DetailBody({
    required this.project,
    required this.langCode,
    required this.l10n,
    required this.onTierTap,
  });

  final ImpactProjectModel project;
  final String langCode;
  final AppLocale l10n;
  final ValueChanged<ImpactProjectTierModel> onTierTap;

  @override
  Widget build(BuildContext context) {
    final typo = UITheme.of(context).typo;
    final expanded = useState(false);
    final description = project.description(langCode);
    final subtitle = project.subtitle(langCode);
    final isUrgent = project.category?.titleEn == 'Urgent';
    final categoryTitle = project.category?.title(langCode);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cover gallery (carousel + dots).
          ProjectCoverCarousel(images: project.galleryImages),
          const UISpace.vert(16),

          if (categoryTitle != null && categoryTitle.isNotEmpty) ...[
            CategoryBadgeWidget(label: categoryTitle, urgent: isUrgent),
            const UISpace.vert(10),
          ],

          Text(
            project.title(langCode),
            style: typo.inter.largeTitle.copyWith(
              color: UIColorsToken.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (subtitle.isNotEmpty) ...[
            const UISpace.vert(6),
            Text(
              subtitle,
              style: typo.inter.bodyMedium.copyWith(
                color: UIColorsToken.textParagraph,
              ),
            ),
          ],
          const UISpace.vert(16),

          // Funding progress.
          _ProgressCard(project: project, l10n: l10n),

          _buildDivider(),

          // About.
          _SectionTitle(l10n.impact_about_project),
          const UISpace.vert(10),
          if (description.isNotEmpty) ...[
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              alignment: Alignment.topCenter,
              child: Text(
                description,
                maxLines: expanded.value ? null : 4,
                overflow: expanded.value
                    ? TextOverflow.visible
                    : TextOverflow.ellipsis,
                style: typo.inter.bodyMedium.copyWith(
                  color: UIColorsToken.textParagraph,
                  height: 1.5,
                ),
              ),
            ),
            const UISpace.vert(6),
            UITap(
              onTap: () => expanded.value = !expanded.value,
              child: Text(
                expanded.value ? l10n.impact_read_less : l10n.impact_read_more,
                style: typo.inter.bodySmall.copyWith(
                  color: UIColorsToken.textYellow,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],

          // "Your donation provides" — tiers (tap → amount sheet pre-filled).
          if (project.tiers.isNotEmpty) ...[
            _buildDivider(),
            ProjectTiersSection(
              title: l10n.impact_tiers_title,
              tiers: project.tiers,
              currency: project.currency,
              langCode: langCode,
              onTierTap: onTierTap,
            ),
          ],

          _buildDivider(),
          // Partner organization.
          if (project.organization != null) ...[
            _SectionTitle(l10n.impact_partner_org),
            const UISpace.vert(10),
            _PartnerCard(
              organization: project.organization!,
              langCode: langCode,
              l10n: l10n,
            ),
            const UISpace.vert(24),
          ],

          // Stories.
          if (project.stories.isNotEmpty) ...[
            _SectionTitle(l10n.impact_stories_title),
            const UISpace.vert(16),
            for (var i = 0; i < project.stories.length; i++)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: ProjectStoryCardWidget(
                  story: project.stories[i],
                  isFirst: i == 0,
                  isLast: i == project.stories.length - 1,
                  langCode: langCode,
                ),
              ),
          ],

          // Transparency — confirmed disbursement proofs for this project.
          _buildDivider(),
          ProjectTransactionsSection(
            projectId: project.id,
            currency: project.currency,
          ),
        ],
      ),
    );
  }

  Divider _buildDivider() {
    return Divider(
      color: UIColorsToken.textParagraph,
      height: 50,
      thickness: 0.3,
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({required this.project, required this.l10n});

  final ImpactProjectModel project;
  final AppLocale l10n;

  @override
  Widget build(BuildContext context) {
    final typo = UITheme.of(context).typo;
    return UICard(
      color: UIColorsToken.bgSecondaryGreen,
      disableBorder: true,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${ImpactFormat.money(project.collectedAmount, project.currency)}'
            ' / '
            '${ImpactFormat.money(project.requiredAmount, project.currency)}',
            style: typo.inter.title.copyWith(
              color: UIColorsToken.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const UISpace.vert(10),
          UIProgressLine(
            current: project.collectedAmount,
            height: 4,
            total: project.requiredAmount,
          ),
          if (project.donorsCount > 0)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Row(
                children: [
                  DonorsAvatarsWidget(projectId: project.id),
                  const UISpace.horz(6),
                  Text(
                    l10n.impact_donors(ImpactFormat.compactCount(project.donorsCount)),
                    style: typo.inter.bodySmall.copyWith(
                      color: UIColorsToken.textParagraph,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _PartnerCard extends StatelessWidget {
  const _PartnerCard({
    required this.organization,
    required this.langCode,
    required this.l10n,
  });

  final PartnerOrganizationModel organization;
  final String langCode;
  final AppLocale l10n;

  @override
  Widget build(BuildContext context) {
    final typo = UITheme.of(context).typo;
    final avatarUrl =
        ImpactRemoteDatasource.publicStoryImageUrl(organization.avatarUrl);

    return UICard(
      color: UIColorsToken.black80,
      disableBorder: true,
      shadows: const [],
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: avatarUrl != null
                ? CachedNetworkImage(
                    imageUrl: avatarUrl,
                    width: 44,
                    height: 44,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => _avatarFallback(),
                  )
                : _avatarFallback(),
          ),
          const UISpace.horz(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  organization.name(langCode),
                  style: typo.inter.title.copyWith(color: UIColorsToken.white),
                ),
                if (organization.isVerified) ...[
                  const UISpace.vert(2),
                  Row(
                    children: [
                      const Icon(
                        Icons.verified,
                        size: 14,
                        color: UIColorsToken.greenAccent,
                      ),
                      const UISpace.horz(4),
                      Text(
                        l10n.impact_verified,
                        style: typo.inter.smallCaption.copyWith(
                          color: UIColorsToken.textParagraph,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _avatarFallback() => Image.asset(
    Assets.images.illustration1.path,
    width: 44,
    height: 44,
    fit: BoxFit.contain,
  );
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final typo = UITheme.of(context).typo;
    return Text(
      text,
      style: typo.inter.title.copyWith(
        color: UIColorsToken.white,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _FavoriteIcon extends StatelessWidget {
  const _FavoriteIcon({required this.isFavorite, required this.onTap});

  final bool isFavorite;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return UITap(
      onTap: onTap,
      child: Icon(
        isFavorite ? Icons.favorite : Icons.favorite_border,
        color: isFavorite ? UIColorsToken.red : UIColorsToken.white,
        size: 24,
      ),
    );
  }
}

class _DetailError extends StatelessWidget {
  const _DetailError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final typo = UITheme.of(context).typo;
    final l10n = AppLocale.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              color: UIColorsToken.textYellow,
              size: 44,
            ),
            const UISpace.vert(12),
            Text(
              l10n.favorites_error_title,
              style: typo.inter.title.copyWith(color: UIColorsToken.white),
            ),
            const UISpace.vert(16),
            UIButton.primary(label: l10n.favorites_try_again, onTap: onRetry),
          ],
        ),
      ),
    );
  }
}
