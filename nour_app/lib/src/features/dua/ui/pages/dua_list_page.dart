import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';
import 'package:nour/src/core/providers/routing/navigation_services_provider.dart';

import '../state_management/dua_provider.dart';
import '../widgets/dua_card_widget.dart';

/// The Dua Library: the single flat list of all duas as compact cards (numbered
/// star badge + title + quoted preview). Unlike hadiths there are no
/// collections, so the duas are shown directly here. Tapping a card opens the
/// immersive reader at that dua. Owns its own load lifecycle and renders
/// loading / error / empty states.
@RoutePage()
class DuaListPage extends HookConsumerWidget {
  const DuaListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(l10nProvider);
    final nav = ref.read(navigationServicesProvider);
    final presenter = ref.read(duaProvider.notifier);
    final state = ref.watch(duaProvider);

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) => presenter.init());
      return null;
    }, const []);

    Widget body;
    if (state.isLoading && state.isEmpty) {
      body = const Center(child: UICircularProgressBar());
    } else if (state.hasError && state.isEmpty) {
      body = _DuaError(onRetry: presenter.retry);
    } else if (state.isEmpty) {
      body = _DuaEmpty();
    } else {
      final currentId = state.progress?.currentDuaId;
      body = ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        itemCount: state.library.length,
        separatorBuilder: (_, __) => const UISpace.vert(12),
        itemBuilder: (context, index) {
          final dua = state.library[index];
          return DuaCardWidget(
            dua: dua,
            number: index + 1,
            isLiked: state.isDuaLiked(dua.id),
            isCurrent: currentId == dua.id,
            onTap: () => nav.toDuaReader(initialDuaId: dua.id),
          );
        },
      );
    }

    return Scaffold(
      appBar: UIAppBar(title: l10n.dua_library_title, onBack: context.pop),
      body: SafeArea(top: false, child: body),
    );
  }
}

class _DuaError extends StatelessWidget {
  const _DuaError({required this.onRetry});

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
              l10n.dua_error_title,
              style: typo.inter.title.copyWith(color: UIColorsToken.white),
            ),
            const UISpace.vert(6),
            Text(
              l10n.dua_error_subtitle,
              textAlign: TextAlign.center,
              style: typo.inter.bodyMedium
                  .copyWith(color: UIColorsToken.textParagraph),
            ),
            const UISpace.vert(16),
            UIButton.primary(label: l10n.dua_try_again, onTap: onRetry),
          ],
        ),
      ),
    );
  }
}

class _DuaEmpty extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final typo = UITheme.of(context).typo;
    final l10n = AppLocale.of(context);
    return Center(
      child: Text(
        l10n.dua_empty,
        style:
            typo.inter.bodyMedium.copyWith(color: UIColorsToken.textParagraph),
      ),
    );
  }
}
