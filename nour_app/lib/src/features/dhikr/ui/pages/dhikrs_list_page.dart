import 'package:auto_route/auto_route.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/gen/assets.gen.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';
import 'package:nour/src/core/providers/routing/navigation_services_provider.dart';

import '../../data/models/dhikr_model.dart';
import '../state_management/dhikr_provider.dart';
import '../widgets/dhikr_card_widget.dart';

@RoutePage()
class DhikrsListPage extends HookConsumerWidget {
  const DhikrsListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = UITheme.of(context);
    final l10n = ref.watch(l10nProvider);
    final nav = ref.read(navigationServicesProvider);
    final presenter = ref.read(dhikrProvider.notifier);
    final state = ref.watch(dhikrProvider);

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) => presenter.init());
      return null;
    }, const []);

    final inProgress = state.inProgress;
    final notInProgress = state.notInProgress;

    void openDhikr(int id) => nav.toDhikr(selectedId: id);

    return Scaffold(
      appBar: UIAppBar(
        title: l10n.dhikr_choose_title,
        onBack: context.pop,
      ),
      body: SafeArea(
        top: false,
        child: state.isLoading && state.dhikrs.isEmpty
          ? const Center(child: UICircularProgressBar())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (inProgress.isNotEmpty) ...[
                    _SectionTitle(l10n.dhikr_continue_section),
                    const UISpace.vert(12),
                    ...inProgress.map(
                      (d) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: DhikrCardWidget(
                          dhikr: d,
                          currentCount: state.currentCountOf(d.id),
                          totalCount: d.minCount,
                          showActions: true,
                          onContinue: () => openDhikr(d.id),
                          onReset: () => presenter.saveProgress(dhikrId: d.id, count: 0),
                        ),
                      ),
                    ),
                    const UISpace.vert(12),
                  ],
                  _SectionTitle(l10n.dhikr_essential_section),
                  const UISpace.vert(12),
                  ...notInProgress.map(
                    (d) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: DhikrCardWidget(
                        dhikr: d,
                        totalCount: d.minCount,
                        currentCount: state.currentCountOf(d.id),
                        isCompleted: state.isCompleted(d.id),
                        onTap: () => openDhikr(d.id),
                      ),
                    ),
                  ),
                  UICard(
                    colors: [UIColorsToken.bgSurface, UIColorsToken.bgSurface],
                    padding: .symmetric(horizontal: 16, vertical: 20),
                    onTap: () {
                      nav.toAdhkarsList();
                    },
                    child: Row(
                      crossAxisAlignment: .start,
                      spacing: 12,
                      children: [
                        Image.asset(
                          Assets.images.illustration36.path,
                          height: 50,
                        ),
                        Flexible(
                          child: Column(
                            crossAxisAlignment: .start,
                            children: [
                              Text(
                                'Browse all adhkar',
                                style: theme.typo.inter.title,
                              ),
                              Text(
                                'Morning, evening, situational du’as',
                                style: theme.typo.inter.caption.copyWith(
                                  color: UIColorsToken.textParagraph
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    )
                  ),
                  const UISpace.vert(20),
                  _Quote(
                    text: l10n.dhikr_quote,
                    source: l10n.dhikr_quote_source,
                  ),
                  const UISpace.vert(8),
                ].animate(effects: [FadeEffect()]),
              ),
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
      style: typo.inter.headline.copyWith(
        color: UIColorsToken.white,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _Quote extends StatelessWidget {
  const _Quote({required this.text, required this.source});

  final String text;
  final String source;

  @override
  Widget build(BuildContext context) {
    final typo = UITheme.of(context).typo;
    return Center(
      child: Column(
        children: [
          Text(
            '"$text"',
            textAlign: TextAlign.center,
            style: typo.inter.body.copyWith(
              color: UIColorsToken.textParagraph,
              fontStyle: FontStyle.italic,
            ),
          ),
          const UISpace.vert(4),
          Text(
            '— $source',
            textAlign: TextAlign.center,
            style: typo.inter.bodySmall.copyWith(
              color: UIColorsToken.textParagraph,
            ),
          ),
        ],
      ),
    );
  }
}
