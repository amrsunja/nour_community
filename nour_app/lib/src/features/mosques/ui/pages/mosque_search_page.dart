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

/// Mosque search — full-screen map (OpenStreetMap via flutter_map) with a fixed
/// floating app bar and a draggable "Mosques near you" sheet
/// (Figma section 1333:17229).
@RoutePage()
class MosqueSearchPage extends HookConsumerWidget {
  const MosqueSearchPage({super.key});

  /// Fallback center (Paris) while the position is unknown.
  static const LatLng _fallbackCenter = LatLng(48.8566, 2.3522);
  static const double _zoomCity = 12;
  static const double _zoomFocus = 14;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(l10nProvider);
    final nav = ref.read(navigationServicesProvider);
    final snackbar = ref.read(snackbarProvider);
    final presenter = ref.read(mosqueSearchProvider.notifier);
    final state = ref.watch(mosqueSearchProvider);
    final myMosques = ref.watch(myMosquesProvider);
    final mapController = useMemoized(MapController.new);
    final sheetController = useMemoized(DraggableScrollableController.new);
    final searchController = useTextEditingController();
    final didAutoCenter = useRef(false);
    final isLocating = useState(false);

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        presenter.init();
        ref.read(myMosquesProvider.notifier).init();
      });
      return null;
    }, const []);

    // Recenter once, when the first fix arrives.
    useEffect(() {
      if (!didAutoCenter.value && state.lat != null && state.lng != null) {
        didAutoCenter.value = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          try {
            mapController.move(LatLng(state.lat!, state.lng!), _zoomCity);
          } catch (_) {}
        });
      }
      return null;
    }, [state.lat, state.lng]);

    // Geo button: resolve the position and fly the map to it.
    Future<void> onLocate() async {
      if (isLocating.value) return;
      isLocating.value = true;
      try {
        await presenter.locate();
      } finally {
        if (context.mounted) isLocating.value = false;
      }
      if (!context.mounted) return;
      final fresh = ref.read(mosqueSearchProvider);
      if (!fresh.hasLocation) {
        snackbar.showError(l10n.prayer_times_location_error);
        return;
      }
      didAutoCenter.value = true;
      try {
        mapController.move(LatLng(fresh.lat!, fresh.lng!), _zoomFocus);
      } catch (_) {}
    }

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
      final saved = await MyMosquesSheet.show(context, candidate: candidate, fromSearch: true);
      if (saved) {
        snackbar.showSuccess(l10n.my_mosques_saved);
        await ref.read(prayerTimesProvider.notifier).refresh();
      }
    }

    void onPinTap(MosqueSearchItemModel m) {
      presenter.highlight(m.id);
      try {
        mapController.move(LatLng(m.lat!, m.lng!), _zoomFocus);
      } catch (_) {}
      sheetController.animateTo(
        _MosquesSheet.defaultSize,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }

    final center = state.hasLocation ? LatLng(state.lat!, state.lng!) : _fallbackCenter;
    final located = state.results.where((m) => m.hasLocation).toList();

    return Scaffold(
      backgroundColor: UIColorsToken.bgPrimary,
      // The map must not jump when the keyboard opens on the search field.
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialCenter: center,
              initialZoom: _zoomCity,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
              ),
              onTap: (_, __) {
                presenter.highlight(null);
                FocusScope.of(context).unfocus();
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.nourcommunity.nour',
              ),
              if (state.hasLocation)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: center,
                      width: 22,
                      height: 22,
                      child: const _UserDot(),
                    ),
                  ],
                ),
              MarkerLayer(
                markers: [
                  for (final m in located)
                    Marker(
                      point: LatLng(m.lat!, m.lng!),
                      width: _MosquePin.width,
                      height: _MosquePin.height,
                      // Point sits at the widget center → the circle is anchored
                      // on the coordinate and the label floats above it.
                      alignment: Alignment.center,
                      child: _MosquePin(
                        name: m.name,
                        selected: state.highlightedId == m.id,
                        onTap: () => onPinTap(m),
                      ),
                    ),
                ],
              ),
              const RichAttributionWidget(
                attributions: [TextSourceAttribution('OpenStreetMap contributors')],
              ),
            ],
          ),

          _MosquesSheet(
            controller: sheetController,
            title: state.query.trim().isEmpty ? l10n.mosque_search_near_you : l10n.mosque_search_results,
            child: _results(
              context: context,
              state: state,
              l10n: l10n,
              myMosques: myMosques,
              onOpen: (m) => nav.toMosqueProfile(mosqueId: m.id),
              onAdd: onAdd,
            ),
          ),

          // Fixed floating app bar: back · search · locate.
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _SearchAppBar(
              controller: searchController,
              hint: l10n.mosque_search_hint,
              onBack: () => context.router.maybePop(),
              onChanged: presenter.setQuery,
              onLocate: onLocate,
              isLocating: isLocating.value,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _results({
    required BuildContext context,
    required MosqueSearchState state,
    required AppLocale l10n,
    required MyMosquesState myMosques,
    required void Function(MosqueSearchItemModel) onOpen,
    required void Function(MosqueSearchItemModel) onAdd,
  }) {
    final theme = UITheme.of(context);

    if (state.isLoading && state.results.isEmpty) {
      return const SliverToBoxAdapter(
        child: Padding(padding: EdgeInsets.all(32), child: Center(child: UICircularProgressBar())),
      );
    }

    if (state.results.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            l10n.mosque_search_empty,
            textAlign: TextAlign.center,
            style: theme.typo.inter.body.copyWith(color: UIColorsToken.textParagraph),
          ),
        ),
      );
    }

    final ordered = _ordered(state.results, state.highlightedId);

    return SliverList.separated(
      itemCount: ordered.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final m = ordered[i];
        return MosqueSearchCard(
          item: m,
          l10n: l10n,
          isMine: myMosques.isMine(m.id),
          highlighted: state.highlightedId == m.id,
          onTap: () => onOpen(m),
          onAdd: () => onAdd(m),
        );
      },
    );
  }

  static List<MosqueSearchItemModel> _ordered(List<MosqueSearchItemModel> list, int? highlighted) {
    if (highlighted == null) return list;
    return [...list.where((m) => m.id == highlighted), ...list.where((m) => m.id != highlighted)];
  }
}

/// Floating, non-scrolling app bar over the map.
class _SearchAppBar extends StatelessWidget {
  const _SearchAppBar({
    required this.controller,
    required this.hint,
    required this.onBack,
    required this.onChanged,
    required this.onLocate,
    required this.isLocating,
  });

  static const double height = 46;

  final TextEditingController controller;
  final String hint;
  final VoidCallback onBack;
  final ValueChanged<String> onChanged;
  final Future<void> Function() onLocate;
  final bool isLocating;

  @override
  Widget build(BuildContext context) {
    final theme = UITheme.of(context);

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
        child: Row(
          spacing: 8,
          children: [
            _SquareButton(assetIcon: UIIconsToken.icons.chevronLeft, onTap: onBack),
            Expanded(
              child: Container(
                height: height,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: UIColorsToken.bgPrimary,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: UIColorsToken.white.withValues(alpha: 0.06)),
                  boxShadow: _shadows,
                ),
                child: Row(
                  spacing: 10,
                  children: [
                    Icon(Icons.search_rounded, color: UIColorsToken.textParagraph, size: 22),
                    Expanded(
                      child: TextField(
                        controller: controller,
                        onChanged: onChanged,
                        style: theme.typo.inter.body.copyWith(color: UIColorsToken.white),
                        cursorColor: UIColorsToken.textYellow,
                        textInputAction: TextInputAction.search,
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          hintText: hint,
                          hintStyle: theme.typo.inter.body.copyWith(color: UIColorsToken.textParagraph),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _SquareButton(
              assetIcon: UIIconsToken.icons.geo,
              onTap: () => onLocate(),
              isBusy: isLocating,
            ),
          ],
        ),
      ),
    );
  }

  static List<BoxShadow> get _shadows => [
        BoxShadow(
          color: UIColorsToken.black.withValues(alpha: 0.35),
          blurRadius: 18,
          spreadRadius: -2,
          offset: const Offset(0, 8),
        ),
      ];
}

class _SquareButton extends StatelessWidget {
  const _SquareButton({required this.assetIcon, required this.onTap, this.isBusy = false});

  final String assetIcon;
  final VoidCallback onTap;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    return UITap(
      onTap: onTap,
      child: Container(
        width: _SearchAppBar.height,
        height: _SearchAppBar.height,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: UIColorsToken.bgPrimary,
          borderRadius: .circular(10),
          border: Border.all(color: UIColorsToken.white.withValues(alpha: 0.06)),
          boxShadow: _SearchAppBar._shadows,
        ),
        child: isBusy
            ? SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: UIColorsToken.textYellow),
              )
            : UIIconsToken.toIcon(assetIcon, color: UIColorsToken.textYellow, size: 22),
      ),
    );
  }
}

/// Blue "you are here" dot.
class _UserDot extends StatelessWidget {
  const _UserDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xff1F6FEB),
        border: Border.all(color: UIColorsToken.white, width: 3),
        boxShadow: [
          BoxShadow(color: const Color(0xff1F6FEB).withValues(alpha: 0.45), blurRadius: 12, spreadRadius: 2),
        ],
      ),
    );
  }
}

/// Map marker: the mosque name sits on top of the rounded circle holding the
/// `assets/icons/masjid` glyph.
class _MosquePin extends StatelessWidget {
  const _MosquePin({required this.name, required this.selected, required this.onTap});

  /// Marker box — tall/wide enough for the label to overflow above the circle
  /// while keeping the coordinate at the box center.
  static const double width = 230;
  static const double height = 130;
  static const double circle = 45;
  static const double labelGap = 8;

  final String name;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = UITheme.of(context);

    return UITap(
      onTap: onTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Label: bottom edge sits `labelGap` above the circle's top edge.
          Positioned(
            bottom: height / 2 + circle / 2 + labelGap,
            left: 0,
            right: 0,
            child: Align(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: selected ? UIColorsToken.bgTertiaryGreen : UIColorsToken.bgSecondaryGreen,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: selected ? UIColorsToken.textYellow : UIColorsToken.white.withValues(alpha: 0.06),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: UIColorsToken.black.withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.typo.inter.bodyMedium.copyWith(color: UIColorsToken.textYellow),
                ),
              ),
            ),
          ),
          Container(
            width: circle,
            height: circle,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: selected ? UIColorsToken.textYellow : UIColorsToken.bgSecondaryGreen,
              border: Border.all(color: UIColorsToken.yellow, width: 1),
              boxShadow: [
                BoxShadow(
                  color: UIColorsToken.black.withValues(alpha: 0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: UIIconsToken.toIcon(
              UIIconsToken.icons.masjid,
              color: selected ? UIColorsToken.black : UIColorsToken.textYellow,
            ),
          ),
        ],
      ),
    );
  }
}

/// "Mosques near you" sheet: rounded top, gold top glow, pinned handle + title,
/// scrolling result cards.
class _MosquesSheet extends StatelessWidget {
  const _MosquesSheet({required this.controller, required this.title, required this.child});

  static const double collapsedSize = 0.16;
  static const double defaultSize = 0.46;
  static const double expandedSize = 0.82;
  static const double radius = 24;

  final DraggableScrollableController controller;
  final String title;

  /// Sliver holding the result cards.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      controller: controller,
      initialChildSize: defaultSize,
      minChildSize: collapsedSize,
      maxChildSize: expandedSize,
      snap: true,
      snapSizes: const [collapsedSize, defaultSize, expandedSize],
      builder: (context, scroll) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(radius)),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: UIColorsToken.bgPrimary,
            border: Border(top: BorderSide(color: UIColorsToken.white.withValues(alpha: 0.08))),
          ),
          child: CustomScrollView(
            controller: scroll,
            slivers: [
              SliverPersistentHeader(pinned: true, delegate: _SheetHeader(title: title)),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(16, 0, 16, 24 + MediaQuery.of(context).padding.bottom),
                sliver: child,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SheetHeader extends SliverPersistentHeaderDelegate {
  const _SheetHeader({required this.title});

  static const double _extent = 90;

  final String title;

  @override
  double get minExtent => _extent;

  @override
  double get maxExtent => _extent;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final theme = UITheme.of(context);

    return SizedBox(
      height: _extent,
      child: Stack(
      alignment: .center,
        children: [
          const Positioned.fill(child: ColoredBox(color: UIColorsToken.bgPrimary)),
          const Positioned(
            top: UITopGlow.offset,
            left: 0,
            right: 0,
            child: UITopGlow(),
          ),
          Column(
            children: [
              const UIBottomSheetHandle(),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.typo.inter.titleMedium.copyWith(color: UIColorsToken.white),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(_SheetHeader oldDelegate) => oldDelegate.title != title;
}
