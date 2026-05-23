import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';
import 'package:nour/src/core/providers/routing/navigation_services_provider.dart';

import '../../data/models/adhkar_category_model.dart';
import '../../data/models/adhkar_subcategory_model.dart';
import '../state_management/adhkar_provider.dart';
import '../state_management/adhkar_state.dart';
import '../widgets/adhkar_subcategory_card_widget.dart';
import '../widgets/recommended_adhkar_card_widget.dart';
import '../widgets/search_field_widget.dart';

@RoutePage()
class AdhkarsListPage extends HookConsumerWidget {
  const AdhkarsListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(l10nProvider);
    final nav = ref.read(navigationServicesProvider);
    final presenter = ref.read(adhkarProvider.notifier);
    final state = ref.watch(adhkarProvider);
    final langCode = Localizations.localeOf(context).languageCode;

    final searchController = useTextEditingController();

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) => presenter.init());
      return null;
    }, const []);

    // Local wall-clock minutes-of-day → drives the "Recommended now" card.
    final now = DateTime.now();
    final nowMinute = now.hour * 60 + now.minute;
    final recommended = state.recommendedAt(nowMinute);

    void openSubcategory(AdhkarSubcategoryModel s) =>
        nav.toAdhkarDetail(subcategoryId: s.id);

    return Scaffold(
      appBar: UIAppBar(
        title: l10n.adhkar_all_title,
        onBack: context.pop,
      ),
      body: SafeArea(
        top: false,
        child: state.isLoading && state.subcategories.isEmpty
            ? const Center(child: UICircularProgressBar())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SearchFieldWidget(
                      hintText: l10n.adhkar_search_hint,
                      controller: searchController,
                      onChanged: presenter.search,
                    ),
                    const UISpace.vert(16),
                    if (state.isSearching)
                      ..._buildSearchResults(state, langCode, openSubcategory)
                    else ...[
                      if (recommended != null) ...[
                        RecommendedAdhkarCardWidget(
                          subcategory: recommended,
                          label: l10n.adhkar_recommended_now,
                          langCode: langCode,
                          onTap: () => openSubcategory(recommended),
                        ),
                        const UISpace.vert(20),
                      ],
                      ..._buildGroupedSections(
                        state.categories,
                        state,
                        langCode,
                        openSubcategory,
                      ),
                    ],
                    const UISpace.vert(8),
                  ],
                ),
              ),
      ),
    );
  }

  List<Widget> _buildSearchResults(
    AdhkarState state,
    String langCode,
    void Function(AdhkarSubcategoryModel) onTap,
  ) {
    final results = state.searchResults;
    if (results.isEmpty) return const [_EmptyResults()];

    return [
      for (var i = 0; i < results.length; i++)
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: AdhkarSubcategoryCardWidget(
            subcategory: results[i],
            langCode: langCode,
            delay: Duration(milliseconds: 40 * i),
            onTap: () => onTap(results[i]),
          ),
        ),
    ];
  }

  List<Widget> _buildGroupedSections(
    List<AdhkarCategoryModel> categories,
    AdhkarState state,
    String langCode,
    void Function(AdhkarSubcategoryModel) onTap,
  ) {
    final widgets = <Widget>[];

    for (final category in categories) {
      final subs = state.subcategoriesOf(category.id);
      if (subs.isEmpty) continue;

      widgets
        ..add(_SectionTitle(category.title(langCode)))
        ..add(const UISpace.vert(12));

      for (var i = 0; i < subs.length; i++) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: AdhkarSubcategoryCardWidget(
              subcategory: subs[i],
              langCode: langCode,
              delay: Duration(milliseconds: 40 * i),
              onTap: () => onTap(subs[i]),
            ),
          ),
        );
      }

      widgets.add(const UISpace.vert(8));
    }

    return widgets;
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

class _EmptyResults extends StatelessWidget {
  const _EmptyResults();

  @override
  Widget build(BuildContext context) {
    final typo = UITheme.of(context).typo;
    final l10n = AppLocale.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Text(
          l10n.adhkar_no_results,
          style: typo.inter.bodyMedium.copyWith(
            color: UIColorsToken.textParagraph,
          ),
        ),
      ),
    );
  }
}
