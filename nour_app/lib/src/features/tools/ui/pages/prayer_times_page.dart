import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:nour/gen/assets.gen.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';
import 'package:nour/src/core/utils/islamic_tools/hijri_strings.dart';
import 'package:nour/src/core/utils/islamic_tools/hijri_tool.dart';
import 'package:nour/src/core/utils/islamic_tools/islamic_tools.dart';
import 'package:nour/src/features/notifications/data/models/notifications_settings_model.dart';
import 'package:nour/src/features/notifications/ui/state_management/notifications_provider.dart';

import '../state_management/prayer_times_provider.dart';
import '../state_management/prayer_times_state.dart';
import '../widgets/prayer_calc_method_card_widget.dart';
import '../widgets/prayer_calc_method_sheet.dart';
import '../widgets/prayer_extra_times_widget.dart';
import '../widgets/prayer_time_widget.dart';

@RoutePage()
class PrayerTimesPage extends HookConsumerWidget {
  const PrayerTimesPage({super.key});

  static String _hhmm(DateTime t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  static AssetGenImage _slotImage(PrayerSlot slot) {
    final images = Assets.images;
    switch (slot) {
      case PrayerSlot.fajr:
        return images.prayerTimeFajr;
      case PrayerSlot.dhuhr:
        return images.prayerTimeDuhr;
      case PrayerSlot.asr:
        return images.prayerTimeAsr;
      case PrayerSlot.maghrib:
        return images.prayerTimeMaghrib;
      case PrayerSlot.isha:
        return images.prayerTimeIsha;
    }
  }

  static String _slotTitle(AppLocale l10n, PrayerSlot slot) {
    switch (slot) {
      case PrayerSlot.fajr:
        return l10n.notifications_prayer_fajr;
      case PrayerSlot.dhuhr:
        return l10n.notifications_prayer_dhuhr;
      case PrayerSlot.asr:
        return l10n.notifications_prayer_asr;
      case PrayerSlot.maghrib:
        return l10n.notifications_prayer_maghrib;
      case PrayerSlot.isha:
        return l10n.notifications_prayer_isha;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(l10nProvider);
    final presenter = ref.read(prayerTimesProvider.notifier);
    final state = ref.watch(prayerTimesProvider);
    final notifPresenter = ref.read(notificationsProvider.notifier);
    final notifSettings =
        ref.watch(notificationsProvider.select((s) => s.settings));

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        presenter.init();
        notifPresenter.initSettings();
      });
      return null;
    }, const []);

    Widget body;
    if (state.times == null) {
      body = state.hasLocationError
          ? _LocationError(onRetry: presenter.init)
          : const Center(child: UICircularProgressBar());
    } else {
      body = _Content(
        state: state,
        l10n: l10n,
        notifSettings: notifSettings,
        onChangeMethod: () => PrayerCalcMethodSheet.show(
          context,
          title: l10n.prayer_times_method_sheet_title,
          selected: state.settings.method,
          onSelect: presenter.changeMethod,
        ),
        onToggleNotify: notifPresenter.setPrayer,
        onToggleAll: notifPresenter.setAllPrayers,
      );
    }

    return UIGradientLinedScaffold(
      bgArabicText: 'الصلاة',
      appBar: UIAppBar(
        title: l10n.prayer_times_title,
        onBack: context.pop,
      ),
      body: SafeArea(top: false, bottom: false, child: body),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({
    required this.state,
    required this.l10n,
    required this.notifSettings,
    required this.onChangeMethod,
    required this.onToggleNotify,
    required this.onToggleAll,
  });

  final PrayerTimesState state;
  final AppLocale l10n;
  final NotificationsSettingsModel notifSettings;
  final VoidCallback onChangeMethod;
  final Future<bool> Function(PrayerSlot, bool) onToggleNotify;
  final Future<bool> Function(bool) onToggleAll;

  @override
  Widget build(BuildContext context) {
    final times = state.times!;
    final settings = state.settings;
    final jumua = state.jumua;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          UIAppearAnimation(
            child: PrayerCalcMethodCardWidget(
              label: l10n.prayer_times_calc_method(settings.method.localizedName(l10n)),
              onTap: onChangeMethod,
            ),
          ),
          const SizedBox(height: 16),
          UIAppearAnimation(
            delay: const Duration(milliseconds: 150),
            child: _AllNotificationsCard(
              label: l10n.notifications_prayer_times_label,
              enabled: notifSettings.allPrayers,
              onChanged: (v) => onToggleAll(v),
            ),
          ),
          const SizedBox(height: 16),
          UIAppearAnimation(
            delay: Duration(milliseconds: 200),
            child: const _DateLine()
          ),
          const SizedBox(height: 16),
          for (final slot in IslamicTools.orderedSlots) ...[
            UIAppearAnimation(
              delay: Duration(milliseconds: 400 + (slot.index * 200)),
              child: PrayerTimeWidget(
                title: PrayerTimesPage._slotTitle(l10n, slot),
                time: times.forSlot(slot),
                offsetMinutes: settings.offsetFor(slot),
                notify: notifSettings.prayerFor(slot),
                onToggleNotify: () =>
                    onToggleNotify(slot, !notifSettings.prayerFor(slot)),
                isNext: state.nextSlot == slot,
                backgroundImage: state.nextSlot == slot ? PrayerTimesPage._slotImage(slot) : null,
                countdownTarget: state.nextSlot == slot ? state.nextTime : null,
              ),
            ),
            const SizedBox(height: 20),
          ],
          const SizedBox(height: 4),
          UIAppearAnimation(
            delay: Duration(seconds: 1),
            child: PrayerExtraTimesWidget(
              chouroukLabel: l10n.prayer_times_chourouk,
              chouroukTime: PrayerTimesPage._hhmm(times.sunrise),
              jumuaLabel: l10n.prayer_times_jumua,
              jumuaTime: jumua == null ? '--:--' : PrayerTimesPage._hhmm(jumua),
            ),
          ),
        ],
      ),
    );
  }
}

/// Master switch that enables/disables notifications for all five prayers.
class _AllNotificationsCard extends StatelessWidget {
  const _AllNotificationsCard({
    required this.label,
    required this.enabled,
    required this.onChanged,
  });

  final String label;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = UITheme.of(context);

    return UIGradientCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: [
          UIIcon(
            enabled ? UIIconsToken.icons.notif : UIIconsToken.icons.notNotif,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: theme.typo.inter.title.copyWith(
                color: UIColorsToken.white,
              ),
            ),
          ),
          UIToggle(
            checked: enabled,
            onCheck: onChanged,
          ),
        ],
      ),
    );
  }
}

/// "14 Dhul Qa'ada 1447  |  Sat 2 May 2026".
class _DateLine extends StatelessWidget {
  const _DateLine();

  @override
  Widget build(BuildContext context) {
    final theme = UITheme.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final hijri = HijriTool.today();
    final hijriText =
        '${hijri.day} ${HijriStrings.monthName(hijri.month, lang)} ${hijri.year}';
    final gregorian =
        DateFormat('EEE d MMM yyyy', lang).format(DateTime.now());

    final style = theme.typo.inter.bodyMedium;

    return Row(
      children: [
        Flexible(
          child: Text(hijriText, maxLines: 1, overflow: TextOverflow.ellipsis, style: style),
        ),
        const SizedBox(width: 12),
        Container(width: 1, height: 18, color: UIColorsToken.stroke),
        const SizedBox(width: 12),
        Flexible(
          child: Text(gregorian, maxLines: 1, overflow: TextOverflow.ellipsis, style: style),
        ),
      ],
    );
  }
}

class _LocationError extends StatelessWidget {
  const _LocationError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = UITheme.of(context);
    final l10n = AppLocale.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.location_off_outlined,
              color: UIColorsToken.textYellow,
              size: 44,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.prayer_times_location_error,
              textAlign: TextAlign.center,
              style: theme.typo.inter.title.copyWith(
                color: UIColorsToken.white,
              ),
            ),
            const SizedBox(height: 16),
            UIButton.primary(label: l10n.prayer_times_retry, onTap: onRetry),
          ],
        ),
      ),
    );
  }
}
