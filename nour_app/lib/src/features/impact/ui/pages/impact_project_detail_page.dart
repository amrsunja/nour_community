import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/gen/assets.gen.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';
import 'package:nour/src/core/utils/share_services.dart';
import 'package:nour/src/features/impact/ui/widgets/category_badge_widget.dart';
import 'package:nour/src/features/impact/ui/widgets/donors_avatars_widget.dart';

import '../../data/datasources/impact_remote_datasource.dart';
import '../../data/models/impact_project_model.dart';
import '../../data/models/partner_organization_model.dart';
import '../state_management/impact_project_detail_provider.dart';
import '../widgets/impact_money.dart';
import '../widgets/project_story_card_widget.dart';

/// Impact project detail. Cover, funding progress, about section, partner
/// organization and the field-stories timeline. The donation CTA / "Your
/// donation provides" block is intentionally left out (handled separately).
@RoutePage()
class ImpactProjectDetailPage extends HookConsumerWidget {
  const ImpactProjectDetailPage({super.key, required this.projectId});

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
      body: SafeArea(
        top: false,
        child: state.isLoading && project == null
            ? const Center(child: UICircularProgressBar())
            : project == null
            ? _DetailError(onRetry: presenter.init)
            : _DetailBody(project: project, langCode: langCode, l10n: l10n),
      ),
    );
  }
}

class _DetailBody extends HookWidget {
  const _DetailBody({
    required this.project,
    required this.langCode,
    required this.l10n,
  });

  final ImpactProjectModel project;
  final String langCode;
  final AppLocale l10n;

  @override
  Widget build(BuildContext context) {
    final typo = UITheme.of(context).typo;
    final expanded = useState(false);
    final coverUrl =
        ImpactRemoteDatasource.publicStoryImageUrl(project.coverImageUrl);
    final description = project.description(langCode);
    final subtitle = project.subtitle(langCode);
    final isUrgent = project.category?.titleEn == 'Urgent';
    final categoryTitle = project.category?.title(langCode);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cover.
          if (coverUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: CachedNetworkImage(
                imageUrl: coverUrl,
                height: 210,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (_, _) => Container(height: 210, color: UIColorsToken.bgSurface),
                errorWidget: (_, _, _) => Container(height: 210, color: UIColorsToken.bgSurface),
              ),
            ),
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
                  DonorsAvatarsWidget(),
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

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.urgent});

  final String label;
  final bool urgent;

  @override
  Widget build(BuildContext context) {
    final typo = UITheme.of(context).typo;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: urgent ? UIColorsToken.red : null,
        gradient: urgent ? null : UIColorsToken.bgPriYellow,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        label,
        style: typo.inter.bodySmall.copyWith(
          color: urgent ? UIColorsToken.white : UIColorsToken.black,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
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
