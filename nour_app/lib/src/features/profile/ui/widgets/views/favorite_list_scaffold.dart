import 'package:flutter/material.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';

/// Shared chrome for every Favourites tab: handles the loading / error / empty
/// states and wraps the populated list in a [UIRefreshIndicator].
///
/// Each `favorite_*_view` only builds its own typed [itemBuilder]; the
/// lifecycle (first-load spinner, retry, pull-to-refresh) lives here so the four
/// views stay thin and identical in behaviour.
class FavoriteListScaffold extends StatelessWidget {
  const FavoriteListScaffold({
    super.key,
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
    // First load (nothing cached yet).
    if (isLoading && isEmpty) {
      return const Center(child: UICircularProgressBar());
    }
    if (hasError && isEmpty) {
      return _FavoriteError(onRetry: onRetry);
    }

    // Always-scrollable so pull-to-refresh works even on a short / empty list.
    return UIRefreshIndicator(
      onRefresh: onRefresh,
      child: isEmpty
          ? const _FavoriteEmpty()
          : ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
              itemCount: itemCount,
              separatorBuilder: (_, __) => const UISpace.vert(12),
              itemBuilder: itemBuilder,
            ),
    );
  }
}

class _FavoriteEmpty extends StatelessWidget {
  const _FavoriteEmpty();

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
            l10n.favorites_empty,
            textAlign: TextAlign.center,
            style: typo.inter.bodyMedium
                .copyWith(color: UIColorsToken.textParagraph),
          ),
        ),
      ],
    );
  }
}

class _FavoriteError extends StatelessWidget {
  const _FavoriteError({required this.onRetry});

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
            const Icon(Icons.error_outline,
                color: UIColorsToken.textYellow, size: 44),
            const UISpace.vert(12),
            Text(
              l10n.favorites_error_title,
              style: typo.inter.title.copyWith(color: UIColorsToken.white),
            ),
            const UISpace.vert(6),
            Text(
              l10n.favorites_error_subtitle,
              textAlign: TextAlign.center,
              style: typo.inter.bodyMedium
                  .copyWith(color: UIColorsToken.textParagraph),
            ),
            const UISpace.vert(16),
            UIButton.primary(label: l10n.favorites_try_again, onTap: onRetry),
          ],
        ),
      ),
    );
  }
}
