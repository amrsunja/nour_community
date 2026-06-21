import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';

import '../state_management/qibla_provider.dart';
import '../state_management/qibla_state.dart';
import '../widgets/qibla_compass_widget.dart';

@RoutePage()
class QiblaFinderPage extends HookConsumerWidget {
  const QiblaFinderPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(l10nProvider);
    final presenter = ref.read(qiblaProvider.notifier);
    final state = ref.watch(qiblaProvider);

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) => presenter.init());
      return null;
    }, const []);

    Widget body;
    if (!state.isReady) {
      body = state.hasLocationError
          ? _LocationError(onRetry: presenter.init)
          : const Center(child: UICircularProgressBar());
    } else {
      body = _Content(state: state, l10n: l10n);
    }

    return UIGradientLinedScaffold(
      bgArabicText: 'القبلة',
      appBar: UIAppBar(
        title: l10n.tools_qibla_finder,
        onBack: context.pop,
      ),
      body: SafeArea(top: false, bottom: false, child: body),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.state, required this.l10n});

  final QiblaState state;
  final AppLocale l10n;

  @override
  Widget build(BuildContext context) {
    final theme = UITheme.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final distance =
        NumberFormat.decimalPattern(lang).format(state.distanceKm!.round());

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
        children: [
          UIAppearAnimation(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    UIIcon(
                      UIIconsToken.icons.location,
                      color: UIColorsToken.textYellow,
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        state.placeName ?? l10n.qibla_locating,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.typo.inter.titleMedium.copyWith(
                          color: UIColorsToken.textYellow,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.qibla_distance_to_mecca(distance),
                  textAlign: TextAlign.center,
                  style: theme.typo.inter.bodyLarge.copyWith(
                    color: UIColorsToken.textParagraph,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: UIAppearAnimation(
                delay: const Duration(milliseconds: 200),
                child: QiblaCompassWidget(qiblaBearing: state.bearing!),
              ),
            ),
          ),
        ],
      ),
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
