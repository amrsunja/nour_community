import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/audio/app_sound.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';
import 'package:nour/src/core/providers/audio/sound_effect_provider.dart';
import 'package:nour/src/features/analytics/data/analytics_repo.dart';

import '../../data/models/dhikr_model.dart';
import '../state_management/dhikr_provider.dart';

@RoutePage()
class DhikrPage extends HookConsumerWidget {
  const DhikrPage({
    super.key,
    @QueryParam('id') this.selectedId = 0,
  });

  final int selectedId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(l10nProvider);
    final presenter = ref.read(dhikrProvider.notifier);
    final analytics = ref.read(analyticsRepoProvider);
    final sfx = ref.read(soundEffectServiceProvider);
    final state = ref.read(dhikrProvider);
    final langCode = Localizations.localeOf(context).languageCode;


    final dhikrs = state.dhikrs;
    final dhikrId = useState(selectedId);
    final dhikr = dhikrs.firstWhere((d) => d.id == dhikrId.value);

    final dhikrCount = useState(state.currentCountOf(dhikr.id));
    final counterCount = useState(dhikrCount.value);
    final counterController = useMemoized(() => UIDhikrCounterController());
    final sessionsCount = dhikr.minCount > 0 ? dhikrCount.value ~/ dhikr.minCount : 0;

    // Total ajr earned for this dhikr today (from ajr_log — one row per cycle).
    // Survives a reset; while actively counting, the live value can run ahead
    // of the last-saved total, so show whichever is greater.
    final liveAjr = dhikr.ajr * sessionsCount;
    final earnedAjr = liveAjr > state.earnedAjrTodayOf(dhikr.id)
        ? liveAjr
        : state.earnedAjrTodayOf(dhikr.id);

    Future<void> save() => presenter.saveProgress(dhikrId: dhikr.id, count: dhikrCount.value);

    return PopScope(
      // Persist progress whenever the page is dismissed (back / swipe).
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) save();
      },
      child: UIGradientLinedScaffold(
        appBar: UIAppBar(onBack: context.pop),
        bgArabicText: dhikr.arabicText,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                _DhikrSelector(
                  label: dhikr.transcription(langCode),
                  onTap: () async {
                    final others = state.dhikrs.where((d) => d.id != dhikr.id).toList();
                    //_openSelector(context, ref, count.value);
                    await showModalBottomSheet<DhikrModel>(
                      context: context,
                      backgroundColor: UIColorsToken.bgSurface,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      builder: (ctx) => SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: Container(
                                  width: 44,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: UIColorsToken.white.withValues(alpha: 0.3),
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                ),
                              ),
                              const UISpace.vert(16),
                              Text(
                                l10n.dhikr_choose_another,
                                style: UITheme.of(ctx).typo.inter.title.copyWith(
                                  color: UIColorsToken.white,
                                ),
                              ),
                              const UISpace.vert(12),
                              ...others.map(
                                (d) => Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: _SelectorTile(
                                    dhikr: d,
                                    langCode: langCode,
                                    onTap: () async {
                                      await presenter.saveProgress(dhikrId: dhikr.id, count: dhikrCount.value);

                                      // Which glorification formula the user picked.
                                      analytics.trackDhikrPhraseSelected(
                                        dhikrId: d.id,
                                        phrase: d.transcription(langCode),
                                      );

                                      dhikrId.value = d.id;
                                      dhikrCount.value = state.currentCountOf(dhikrId.value);
                                      counterCount.value = dhikrCount.value;

                                      if (!context.mounted) return;

                                      context.pop();
                                      //Navigator.of(ctx).pop(d);
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const UISpace.vert(24),
                Text(
                  dhikr.arabicText,
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.center,
                  style: UITheme.of(context).typo.inter.hero,
                ),
                const UISpace.vert(8),
                Text(
                  dhikr.translation(langCode),
                  textAlign: TextAlign.center,
                  style: UITheme.of(context).typo.inter.bodyMedium.copyWith(
                        color: UIColorsToken.textYellow,
                      ),
                ),
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: counterController.tap,
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          UIGlowingBlock(
                            shadow: UIShadowToken.dhikrCounter,
                            child: UIDhikrCounter(
                              totalCount: dhikr.minCount,
                              currentCount: counterCount.value,
                              controller: counterController,
                              onChange: (value) {
                                counterCount.value = value;
                                dhikrCount.value++;
                          
                                // Every tap on the Tasbih counter.
                                final phrase = dhikr.transcription(langCode);
                                analytics.trackDhikrIncrement(
                                  dhikrId: dhikr.id,
                                  phrase: phrase,
                                  count: dhikrCount.value,
                                );
                                // A full ring completed (33 / 66 / 99 …) → celebratory pop.
                                if (dhikr.minCount > 0 && value > 0 &&
                                    value % dhikr.minCount == 0) {
                                  sfx.play(AppSound.longPop);
                                }
                                // A full cycle (multiple of the phrase's target count).
                                if (dhikr.minCount > 0 &&
                                    dhikrCount.value % dhikr.minCount == 0) {
                                  analytics.trackDhikrCycleComplete(
                                    dhikrId: dhikr.id,
                                    phrase: phrase,
                                    cycles: dhikrCount.value ~/ dhikr.minCount,
                                  );
                                }
                              },
                            ),
                          ),
                          const UISpace.vert(50),
                          Text(
                            l10n.dhikr_tap_to_count,
                            style: UITheme.of(context).typo.inter.bodyMedium.copyWith(
                              color: UIColorsToken.textYellow.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                _StatsBar(
                  session: sessionsCount,
                  today: dhikrCount.value,
                  ajr: earnedAjr,
                ),
                const UISpace.vert(16),
                Row(
                  children: [
                    Expanded(
                      child: UIButton.primary(
                        label: l10n.dhikr_done,
                        fullWidth: true,
                        onTap: () async {
                          await save();

                          if (!context.mounted) return ;

                          context.pop();
                        },
                      ),
                    ),
                    const UISpace.horz(10),
                    UIButton.primary(
                      assetIcon: UIIconsToken.icons.refresh,
                      onTap: () {
                        counterCount.value = 0;
                      }
                    ),
                  ],
                ),
                const UISpace.vert(12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DhikrSelector extends StatelessWidget {
  const _DhikrSelector({required this.label, this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final typo = UITheme.of(context).typo;
    return UITap(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: UIColorsToken.yellow.withValues(alpha: .1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: typo.inter.title,
            ),
            const UISpace.horz(6),
            const Icon(
              Icons.keyboard_arrow_down,
              color: UIColorsToken.textYellow,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsBar extends StatelessWidget {
  const _StatsBar({
    required this.session,
    required this.today,
    required this.ajr,
  });

  final int session;
  final int today;
  final int ajr;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocale.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: UIColorsToken.black80,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: _Stat(
              value: '$session',
              label: l10n.dhikr_session
            )
          ),
          Expanded(
            child: _Stat(
              value: '$today',
              label: l10n.dhikr_today
            )
          ),
          Expanded(
            child: _Stat(
              value: '+$ajr',
              label: l10n.dhikr_ajr_earned,
              color: UIColorsToken.textYellow,
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.value,
    required this.label,
    this.color
  });

  final String value;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final typo = UITheme.of(context).typo;
    return Column(
      children: [
        UIGlowingBlock(
          shadow: UIShadowToken.smallTexts,
          child: Text(
            value,
            style: typo.inter.title.copyWith(
              color: color ?? UIColorsToken.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const UISpace.vert(2),
        Text(
          label,
          style: typo.inter.bodySmall.copyWith(
            color: color ?? UIColorsToken.textParagraph,
          ),
        ),
      ],
    );
  }
}

class _SelectorTile extends StatelessWidget {
  const _SelectorTile({
    required this.dhikr,
    required this.langCode,
    this.onTap,
  });

  final DhikrModel dhikr;
  final String langCode;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final typo = UITheme.of(context).typo;
    return UITap(
      onTap: onTap,
      child: UIBgArabicTextCard(
        height: 54,
        arabicBgText: dhikr.arabicText,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  dhikr.transcription(langCode),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: typo.inter.title.copyWith(
                    color: UIColorsToken.white,
                  ),
                ),
              ),
              const UISpace.horz(12),
              Text(
                dhikr.arabicText,
                textDirection: TextDirection.rtl,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: typo.inter.title.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
