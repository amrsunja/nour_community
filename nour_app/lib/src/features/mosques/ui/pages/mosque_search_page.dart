import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';
import 'package:nour/src/core/providers/routing/navigation_services_provider.dart';
import 'package:nour/src/core/providers/widgets/snackbar_provider.dart';
import 'package:nour/src/features/tools/ui/state_management/prayer_times_provider.dart';

import '../../data/models/mosque_model.dart';
import '../../data/models/mosque_search_item_model.dart';
import '../state_management/mosque_search_provider.dart';
import '../state_management/my_mosques_provider.dart';
import '../widgets/mosque_search_card.dart';
import '../widgets/my_mosques_sheet.dart';

/// Mosque search — full-screen map (OpenStreetMap via flutter_map) + a
/// draggable "Mosques near you" sheet (Figma section 1333:17229).
@RoutePage()
class MosqueSearchPage extends HookConsumerWidget {
  const MosqueSearchPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = UITheme.of(context);
    final l10n = ref.watch(l10nProvider);
    final nav = ref.read(navigationServicesProvider);
    final snackbar = ref.read(snackbarProvider);
    final presenter = ref.read(mosqueSearchProvider.notifier);
    final state = ref.watch(mosqueSearchProvider);
    final myMosques = ref.watch(myMosquesProvider);
    final mapController = useMemoized(MapController.new);
    final sheetController = useMemoized(DraggableScrollableController.new);
    final searchController = useTextEditingController();

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        presenter.init();
        ref.read(myMosquesProvider.notifier).init();
      });
      return null;
    }, const []);

    // Recenter when the location arrives.
    useEffect(() {
      if (state.lat != null && state.lng != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          try {
            mapController.move(LatLng(state.lat!, state.lng!), 13);
          } catch (_) {}
        });
      }
      return null;
    }, [state.lat, state.lng]);

    Future<void> onAdd(MosqueSearchItemModel item) async {
      final candidate = MosqueModel(
        id: item.id,
        name: item.name,
        logoUrl: item.logoUrl,
        city: item.city,
        addressLine: item.addressLine,
        postalCode: item.postalCode,
        timezone: item.timezone,
      );
      final saved = await MyMosquesSheet.show(context, candidate: candidate);
      if (saved) {
        snackbar.showSuccess(l10n.my_mosques_saved);
        await ref.read(prayerTimesProvider.notifier).refresh();
      }
    }

    final center = state.hasLocation ? LatLng(state.lat!, state.lng!) : const LatLng(48.8566, 2.3522);
    final located = state.results.where((m) => m.hasLocation).toList();

    return Scaffold(
      backgroundColor: UIColorsToken.bgPrimary,
      body: Stack(
        children: [
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialCenter: center,
              initialZoom: 12,
              interactionOptions: const InteractionOptions(flags: InteractiveFlag.all & ~InteractiveFlag.rotate),
              onTap: (_, __) => presenter.highlight(null),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.nourcommunity.nour',
              ),
              if (state.hasLocation)
                MarkerLayer(markers: [
                  Marker(
                    point: center,
                    width: 20,
                    height: 20,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xff1F6FEB),
                        border: Border.all(color: UIColorsToken.white, width: 3),
                      ),
                    ),
                  ),
                ]),
              MarkerLayer(
                markers: [
                  for (final m in located)
                    Marker(
                      point: LatLng(m.lat!, m.lng!),
                      width: 160,
                      height: 70,
                      alignment: Alignment.topCenter,
                      child: _Pin(
                        name: m.name,
                        selected: state.highlightedId == m.id,
                        onTap: () {
                          presenter.highlight(m.id);
                          mapController.move(LatLng(m.lat!, m.lng!), 14);
                          sheetController.animateTo(0.55, duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
                        },
                      ),
                    ),
                ],
              ),
              const RichAttributionWidget(attributions: [TextSourceAttribution('OpenStreetMap contributors')]),
            ],
          ),
          // Search bar
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 12,
            right: 12,
            child: Row(
              children: [
                _RoundButton(icon: Icons.chevron_left, onTap: () => context.router.maybePop()),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    height: 46,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(color: UIColorsToken.bgPrimary, borderRadius: BorderRadius.circular(23)),
                    child: Row(
                      children: [
                        const Icon(Icons.search, color: UIColorsToken.textParagraph, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: searchController,
                            onChanged: presenter.setQuery,
                            style: theme.typo.inter.body.copyWith(color: UIColorsToken.white),
                            textInputAction: TextInputAction.search,
                            decoration: InputDecoration(
                              isDense: true,
                              border: InputBorder.none,
                              hintText: l10n.mosque_search_hint,
                              hintStyle: theme.typo.inter.body.copyWith(color: UIColorsToken.textParagraph),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _RoundButton(icon: Icons.my_location, onTap: presenter.locate),
              ],
            ),
          ),
          DraggableScrollableSheet(
            controller: sheetController,
            initialChildSize: 0.42,
            minChildSize: 0.12,
            maxChildSize: 0.92,
            builder: (context, scroll) => Container(
              decoration: const BoxDecoration(
                color: UIColorsToken.bgPrimary,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: ListView(
                controller: scroll,
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
                children: [
                  Center(
                    child: Container(width: 72, height: 5, decoration: BoxDecoration(color: UIColorsToken.white, borderRadius: BorderRadius.circular(3))),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.query.trim().isEmpty ? l10n.mosque_search_near_you : l10n.mosque_search_results,
                    textAlign: TextAlign.center,
                    style: theme.typo.inter.title.copyWith(color: UIColorsToken.white),
                  ),
                  const SizedBox(height: 16),
                  if (state.isLoading && state.results.isEmpty)
                    const Padding(padding: EdgeInsets.all(24), child: Center(child: UICircularProgressBar()))
                  else if (state.results.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(l10n.mosque_search_empty, textAlign: TextAlign.center,
                          style: theme.typo.inter.body.copyWith(color: UIColorsToken.textParagraph)),
                    )
                  else
                    for (final m in _ordered(state.results, state.highlightedId))
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: MosqueSearchCard(
                          item: m,
                          l10n: l10n,
                          isMine: myMosques.isMine(m.id),
                          highlighted: state.highlightedId == m.id,
                          onTap: () => nav.toMosqueProfile(mosqueId: m.id),
                          onAdd: () => onAdd(m),
                        ),
                      ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static List<MosqueSearchItemModel> _ordered(List<MosqueSearchItemModel> list, int? highlighted) {
    if (highlighted == null) return list;
    return [...list.where((m) => m.id == highlighted), ...list.where((m) => m.id != highlighted)];
  }
}

class _Pin extends StatelessWidget {
  const _Pin({required this.name, required this.selected, required this.onTap});
  final String name;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = UITheme.of(context);
    return UITap(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: selected ? UIColorsToken.textYellow : UIColorsToken.bgSecondaryGreen,
              border: Border.all(color: UIColorsToken.textYellow, width: 2),
            ),
            child: Icon(Icons.mosque, size: 18, color: selected ? UIColorsToken.black : UIColorsToken.textYellow),
          ),
          const SizedBox(height: 2),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: UIColorsToken.bgSecondaryGreen, borderRadius: BorderRadius.circular(6)),
            child: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis,
                style: theme.typo.inter.smallCaption.copyWith(color: UIColorsToken.textYellow)),
          ),
        ],
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return UITap(
      onTap: onTap,
      child: Container(
        width: 46,
        height: 46,
        decoration: const BoxDecoration(color: UIColorsToken.bgPrimary, shape: BoxShape.circle),
        child: Icon(icon, color: UIColorsToken.textYellow, size: 22),
      ),
    );
  }
}
