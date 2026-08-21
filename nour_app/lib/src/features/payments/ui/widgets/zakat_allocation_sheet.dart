import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/gen/assets.gen.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';
import 'package:nour/src/features/impact/data/impact_repo.dart';
import 'package:nour/src/features/impact/data/datasources/impact_remote_datasource.dart';
import 'package:nour/src/features/impact/data/models/impact_project_model.dart';
import 'package:nour/src/features/impact/ui/widgets/impact_money.dart';

import '../state_management/zakat_cart_provider.dart';

/// Active projects that accept zakat (Surah 9:60 categories) — the only ones
/// offered in the allocation sheet.
final zakatEligibleProjectsProvider =
    FutureProvider.autoDispose<List<ImpactProjectModel>>((ref) async {
  final res = await ref.read(impactRepoProvider).getProjects();
  return res.when(
    (projects) => [for (final p in projects) if (p.eligibleForZakat) p],
    (_) => <ImpactProjectModel>[],
  );
});

/// "Give zakat to eligible Nour projects" — the user splits the zakat the
/// calculator computed across eligible projects, sees live whether the split
/// covers what is owed (fully / remaining / extra-as-sadaqa) and continues to
/// the zakat checkout. Returns the built [ZakatCart], or null on dismiss.
class ZakatAllocationSheet extends ConsumerStatefulWidget {
  const ZakatAllocationSheet({super.key, required this.zakatOwed});

  /// Amount the calculator computed (in EUR — projects are EUR).
  final double zakatOwed;

  static Future<ZakatCart?> show(BuildContext context, {required double zakatOwed}) {
    return showModalBottomSheet<ZakatCart>(
      context: context,
      backgroundColor: UIColorsToken.bgPrimary,
      isScrollControlled: true,
      isDismissible: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => ZakatAllocationSheet(zakatOwed: zakatOwed),
    );
  }

  @override
  ConsumerState<ZakatAllocationSheet> createState() =>
      _ZakatAllocationSheetState();
}

class _ZakatAllocationSheetState extends ConsumerState<ZakatAllocationSheet> {
  /// One controller per project id, created lazily as projects load.
  final Map<int, TextEditingController> _controllers = {};

  TextEditingController _controllerFor(int projectId) {
    return _controllers.putIfAbsent(projectId, () {
      final c = TextEditingController();
      c.addListener(() {
        if (mounted) setState(() {});
      });
      return c;
    });
  }

  double _amountFor(int projectId) =>
      double.tryParse(_controllers[projectId]?.text ?? '') ?? 0;

  double _allocated(List<ImpactProjectModel> projects) =>
      projects.fold(0, (s, p) => s + _amountFor(p.id));

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _checkout(List<ImpactProjectModel> projects) {
    final items = [
      for (final p in projects)
        if (_amountFor(p.id) > 0)
          ZakatCartItem(project: p, amount: _amountFor(p.id)),
    ];
    if (items.isEmpty) return;
    Navigator.of(context).pop(
      ZakatCart(zakatOwed: widget.zakatOwed, items: items),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = ref.watch(l10nProvider);
    final typo = UITheme.of(context).typo;
    final projectsAsync = ref.watch(zakatEligibleProjectsProvider);
    final langCode = Localizations.localeOf(context).languageCode;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOut,
      // Keeps the focused input above the keyboard (overflow fix).
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.88,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                    color: UIColorsToken.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const UISpace.vert(20),
              Text(
                l10n.zakat_alloc_title,
                style: typo.inter.title.copyWith(
                  color: UIColorsToken.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const UISpace.vert(14),

              // Eligibility info banner.
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: UIColorsToken.bgSurface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline,
                        size: 20, color: UIColorsToken.textParagraph),
                    const UISpace.horz(10),
                    Expanded(
                      child: Text(
                        l10n.zakat_alloc_info,
                        style: typo.inter.bodySmall
                            .copyWith(color: UIColorsToken.textParagraph),
                      ),
                    ),
                  ],
                ),
              ),
              const UISpace.vert(14),

              Flexible(
                child: projectsAsync.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(child: UICircularProgressBar()),
                  ),
                  error: (_, _) => _EmptyState(l10n: l10n),
                  data: (projects) {
                    if (projects.isEmpty) return _EmptyState(l10n: l10n);
                    final allocated = _allocated(projects);
                    return SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (final p in projects) ...[
                            _ProjectAllocationCard(
                              project: p,
                              langCode: langCode,
                              controller: _controllerFor(p.id),
                            ),
                            const UISpace.vert(14),
                          ],
                          ZakatAllocationSummary(
                            zakatOwed: widget.zakatOwed,
                            allocated: allocated,
                            currency: 'EUR',
                            l10n: l10n,
                          ),
                          const UISpace.vert(16),
                          UIButton.primary(
                            label: l10n.donate_checkout,
                            fullWidth: true,
                            onTap: allocated >= 1
                                ? () => _checkout(projects)
                                : null,
                          ),
                          const UISpace.vert(12),
                          Text(
                            l10n.donate_footer_partners,
                            textAlign: TextAlign.center,
                            style: typo.inter.bodySmall
                                .copyWith(color: UIColorsToken.textYellow),
                          ),
                          Text(
                            l10n.donate_footer_transparent,
                            textAlign: TextAlign.center,
                            style: typo.inter.bodySmall
                                .copyWith(color: UIColorsToken.textYellow),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Project card with cover, progress and a digits-only amount input.
class _ProjectAllocationCard extends StatelessWidget {
  const _ProjectAllocationCard({
    required this.project,
    required this.langCode,
    required this.controller,
  });

  final ImpactProjectModel project;
  final String langCode;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final typo = UITheme.of(context).typo;
    final cover = ImpactRemoteDatasource.publicStoryImageUrl(
      project.galleryImages.isNotEmpty
          ? project.galleryImages.first
          : project.coverImageUrl,
    );
    final isUrgent = project.category?.titleEn == 'Urgent';
    final hasAmount = (double.tryParse(controller.text) ?? 0) > 0;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: UIColorsToken.bgSurface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Stack(
        children: [
          // Cover as the card background.
          Positioned.fill(
            child: cover != null
                ? CachedNetworkImage(imageUrl: cover, fit: BoxFit.cover)
                : Container(color: UIColorsToken.bgSurface),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    UIColorsToken.black.withValues(alpha: 0.25),
                    UIColorsToken.black.withValues(alpha: 0.86),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isUrgent)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: UIColorsToken.red,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      project.category?.title(langCode) ?? 'Urgent',
                      style: typo.inter.smallCaption.copyWith(
                        color: UIColorsToken.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                const UISpace.vert(34),
                Text(
                  project.title(langCode),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: typo.inter.title.copyWith(
                    color: UIColorsToken.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const UISpace.vert(6),
                UIProgressLine(
                  current: project.collectedAmount,
                  total: project.requiredAmount,
                  height: 4,
                ),
                const UISpace.vert(6),
                Text(
                  '${ImpactFormat.money(project.collectedAmount, project.currency)}'
                  ' / '
                  '${ImpactFormat.money(project.requiredAmount, project.currency)}',
                  style: typo.inter.bodySmall
                      .copyWith(color: UIColorsToken.white),
                ),
                const UISpace.vert(10),

                // Digits-only amount input (whole euros).
                Container(
                  height: 52,
                  padding: const EdgeInsetsDirectional.only(start: 4, end: 14),
                  decoration: BoxDecoration(
                    color: UIColorsToken.black.withValues(
                        alpha: hasAmount ? 0.55 : 0.35),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: hasAmount
                          ? UIColorsToken.textYellow
                          : UIColorsToken.white.withValues(alpha: 0.25),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: controller,
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          // Digits ONLY — no text, signs, separators or emoji.
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(6),
                          ],
                          cursorColor: UIColorsToken.textYellow,
                          style: typo.inter.title.copyWith(
                            color: UIColorsToken.white,
                            fontWeight: FontWeight.w600,
                          ),
                          decoration: InputDecoration(
                            isCollapsed: true,
                            border: InputBorder.none,
                            hintText: '0',
                            hintStyle: typo.inter.title.copyWith(
                              color: UIColorsToken.textParagraph,
                            ),
                          ),
                          onTapOutside: (_) =>
                              FocusManager.instance.primaryFocus?.unfocus(),
                        ),
                      ),
                      Text(
                        ImpactFormat.symbol(project.currency),
                        style: typo.inter.title
                            .copyWith(color: UIColorsToken.white),
                      ),
                    ],
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

/// The green "Zakat owed / allocated" summary with its three states:
/// fully allocated · remaining (pay the rest later) · extra (counts as sadaqa).
class ZakatAllocationSummary extends StatelessWidget {
  const ZakatAllocationSummary({
    super.key,
    required this.zakatOwed,
    required this.allocated,
    required this.currency,
    required this.l10n,
  });

  final double zakatOwed;
  final double allocated;
  final String currency;
  final AppLocale l10n;

  @override
  Widget build(BuildContext context) {
    final typo = UITheme.of(context).typo;
    final diff = zakatOwed - allocated;
    final fully = zakatOwed > 0 && diff.abs() < 0.01;
    final extra = allocated > zakatOwed;

    Widget row(String label, String value, {Color? valueColor, bool bold = false}) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: typo.inter.bodyMedium.copyWith(
              color: valueColor == null
                  ? UIColorsToken.textParagraph
                  : valueColor.withValues(alpha: 0.9),
            ),
          ),
          Text(
            value,
            style: typo.inter.title.copyWith(
              color: valueColor ?? UIColorsToken.white,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
        ],
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: UIColorsToken.bgSecondaryGreen,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          row(
            l10n.zakat_alloc_owed,
            ImpactFormat.money(zakatOwed, currency),
            bold: true,
          ),
          const UISpace.vert(8),
          row(
            l10n.zakat_alloc_allocated,
            fully
                ? l10n.zakat_alloc_fully
                : ImpactFormat.money(allocated, currency),
            valueColor: UIColorsToken.greenAccent,
          ),
          if (!fully && zakatOwed > 0) ...[
            const UISpace.vert(10),
            Divider(
              color: UIColorsToken.white.withValues(alpha: 0.12),
              height: 1,
            ),
            const UISpace.vert(10),
            if (extra)
              row(
                l10n.zakat_alloc_extra,
                ImpactFormat.money(allocated - zakatOwed, currency),
                valueColor: UIColorsToken.textYellow,
              )
            else
              row(
                l10n.zakat_alloc_remaining,
                ImpactFormat.money(diff, currency),
                valueColor: UIColorsToken.textYellow,
              ),
          ],
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.l10n});

  final AppLocale l10n;

  @override
  Widget build(BuildContext context) {
    final typo = UITheme.of(context).typo;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            Assets.images.illustration1.path,
            width: 120,
            height: 120,
            fit: BoxFit.contain,
          ),
          const UISpace.vert(16),
          Text(
            l10n.zakat_alloc_empty_title,
            textAlign: TextAlign.center,
            style: typo.inter.title.copyWith(color: UIColorsToken.white),
          ),
          const UISpace.vert(8),
          Text(
            l10n.zakat_alloc_empty_message,
            textAlign: TextAlign.center,
            style: typo.inter.bodyMedium
                .copyWith(color: UIColorsToken.textParagraph),
          ),
        ],
      ),
    );
  }
}
