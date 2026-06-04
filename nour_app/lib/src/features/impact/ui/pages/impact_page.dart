import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';
import 'package:nour/src/core/providers/routing/navigation_services_provider.dart';

import '../state_management/impact_provider.dart';
import '../widgets/impact_category_tabs.dart';
import '../widgets/impact_project_card_widget.dart';

@RoutePage()
class ImpactPage extends HookConsumerWidget {
  const ImpactPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(l10nProvider);
    final langCode = Localizations.localeOf(context).languageCode;
    final nav = ref.read(navigationServicesProvider);
    final presenter = ref.read(impactProvider.notifier);
    final state = ref.watch(impactProvider);

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) => presenter.init());
      return null;
    }, const []);

    return Scaffold(
      appBar: UIAppBar(title: l10n.impact_title),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            const UISpace.vert(8),
            if (state.categories.isNotEmpty)
              ImpactCategoryTabs(
                categories: state.categories,
                selectedId: state.selectedCategoryId,
                langCode: langCode,
                onSelected: presenter.selectCategory,
              ),
            const UISpace.vert(12),
            Expanded(
              child: _ProjectsList(
                isLoading: state.isLoading,
                hasError: state.hasError,
                isEmpty: state.isEmpty,
                itemCount: state.projects.length,
                onRefresh: presenter.refresh,
                onRetry: presenter.refresh,
                itemBuilder: (context, index) {
                  final project = state.projects[index];
                  return ImpactProjectCardWidget(
                    project: project,
                    onTap: () => nav.toImpactProjectDetail(projectId: project.id),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Loading / error / empty / list states for the projects feed.
class _ProjectsList extends StatelessWidget {
  const _ProjectsList({
    required this.isLoading,
    required this.hasError,
    required this.isEmpty,
    required this.itemCount,
    required this.itemBuilder,
    required this.onRefresh,
    required this.onRetry,
  });

  final bool isLoading;
  final bool hasError;
  final bool isEmpty;
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final Future<void> Function() onRefresh;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (isLoading && isEmpty) {
      return const Center(child: UICircularProgressBar());
    }
    if (hasError && isEmpty) {
      return _ImpactError(onRetry: onRetry);
    }

    return UIRefreshIndicator(
      onRefresh: onRefresh,
      child: isEmpty
          ? const _ImpactEmpty()
          : ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
              itemCount: itemCount,
              separatorBuilder: (_, __) => const UISpace.vert(20),
              itemBuilder: itemBuilder,
            ),
    );
  }
}

class _ImpactEmpty extends StatelessWidget {
  const _ImpactEmpty();

  @override
  Widget build(BuildContext context) {
    final typo = UITheme.of(context).typo;
    final l10n = AppLocale.of(context);
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.sizeOf(context).height * 0.3),
        Center(
          child: Text(
            l10n.impact_empty,
            textAlign: TextAlign.center,
            style: typo.inter.bodyMedium.copyWith(
              color: UIColorsToken.textParagraph,
            ),
          ),
        ),
      ],
    );
  }
}

class _ImpactError extends StatelessWidget {
  const _ImpactError({required this.onRetry});

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
