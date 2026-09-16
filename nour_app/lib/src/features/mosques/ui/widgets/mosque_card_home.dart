import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';
import 'package:nour/src/core/providers/routing/navigation_services_provider.dart';
import 'package:nour/src/core/routing/route_paths.dart';
import 'package:nour/src/core/utils/share_services.dart';
import 'package:nour/src/core/utils/talker/talker.dart';
import 'package:nour/src/features/settings/ui/state_management/app_config_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/models/mosque_enums.dart';
import '../../data/models/mosque_model.dart';
import '../../data/models/mosque_post_model.dart';
import '../state_management/my_mosques_feed_provider.dart';
import '../state_management/my_mosques_provider.dart';
import 'ics_export.dart';
import 'mosque_header.dart';
import 'mosque_post_card.dart';
import 'say_dua_sheet.dart';

/// Dashboard "My mosque" section (Figma "Home - mosque news"): empty state with
/// "Find a mosque", or one horizontal list per mosque — the principal's news
/// first, then the secondary's, each holding that mosque's last
/// [MyMosquesFeedPresenter.limit] posts, urgent first then newest.
class MosqueCardHome extends HookConsumerWidget {
  const MosqueCardHome({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = UITheme.of(context);
    final l10n = ref.watch(l10nProvider);
    final nav = ref.read(navigationServicesProvider);
    final enabled = ref.watch(appConfigProvider.select((c) => c.mosquesEnabled));
    final my = ref.watch(myMosquesProvider);
    final feed = ref.watch(myMosquesFeedProvider);
    final feedPresenter = ref.read(myMosquesFeedProvider.notifier);

    final mine = <MosqueModel>[
      if (my.principal != null) my.principal!,
      if (my.secondary != null) my.secondary!,
    ];
    // Re-keyed on the saved mosques so swapping/removing one reloads the feed.
    final key = mine.map((m) => m.id).join(',');

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) => feedPresenter.load(mine));
      return null;
    }, [key]);

    // Mosque news goes stale while the app sits in the background.
    final lifecycle = useAppLifecycleState();
    final wasSuspended = useRef(false);
    useEffect(() {
      switch (lifecycle) {
        case AppLifecycleState.paused:
        case AppLifecycleState.hidden:
        case AppLifecycleState.detached:
          wasSuspended.value = true;
        case AppLifecycleState.resumed:
          if (wasSuspended.value) {
            wasSuspended.value = false;
            WidgetsBinding.instance.addPostFrameCallback((_) => feedPresenter.refresh(mine));
          }
        case AppLifecycleState.inactive:
        case null:
          break;
      }
      return null;
    }, [lifecycle]);

    if (!enabled) return const SizedBox.shrink();

    final principal = my.principal;

    Future<void> sharePost(MosquePostModel p) async {
      final link = ShareServices.link('${RoutePaths.mosqueProfile(id: p.mosqueId)}/post/${p.id}');
      await Share.share('${p.title}\n$link');
    }

    Future<void> onSayDua(MosquePostModel p) async {
      final done = await SayDuaSheet.show(context, l10n: l10n);
      if (done) await feedPresenter.sayDua(p);
    }

    void onAddToCalendar(MosquePostModel p, MosqueModel mosque) {
      IcsExport.share(p, mosqueName: mosque.name, location: mosque.fullAddress)
          .catchError((Object e) => talker.error(e));
    }

    Widget feedBlock(MosqueFeedBlock block) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _MosqueIdentity(
              mosque: block.mosque,
              isPrincipal: block.mosque.id == principal?.id,
              l10n: l10n,
              onTap: () => nav.toMosqueProfile(mosqueId: block.mosque.id),
            ),
            const SizedBox(height: 12),
            if (block.posts.isEmpty)
              _EmptyNewsCard(l10n: l10n)
            else
              _PostsCarousel(
                key: ValueKey('mosque-feed-${block.mosque.id}'),
                posts: block.posts,
                card: (post) => MosquePostCard(
                  post: post,
                  l10n: l10n,
                  onAttend: () => feedPresenter.toggleAttend(post),
                  onApply: () => feedPresenter.applyVolunteer(post),
                  onSayDua: () => onSayDua(post),
                  onShare: () => sharePost(post),
                  onAddToCalendar: post.isEvent ? () => onAddToCalendar(post, block.mosque) : null,
                ),
              ),
          ],
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(l10n.home_my_mosque, style: theme.typo.inter.headline.copyWith(color: UIColorsToken.white)),
            ),
            if (principal != null)
              UITap(
                onTap: () => nav.toMosqueProfile(mosqueId: principal.id, tab: MosqueTab.news.name),
                child: Text(l10n.dashboard_see_all, style: theme.typo.inter.caption.copyWith(color: UIColorsToken.textYellow)),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (principal == null)
          _NoMosqueCard(l10n: l10n, onFind: nav.toMosqueSearch)
        else if (!feed.loaded)
          const UICard(
            width: double.infinity,
            padding: EdgeInsets.all(28),
            child: Center(child: UICircularProgressBar()),
          )
        else if (feed.blocks.isEmpty) ...[
          // Every mosque's news failed to load — keep the section identifiable.
          _MosqueIdentity(mosque: principal, isPrincipal: true, l10n: l10n, onTap: () => nav.toMosqueProfile(mosqueId: principal.id)),
          const SizedBox(height: 12),
          _EmptyNewsCard(l10n: l10n),
        ] else
          for (final (i, b) in feed.blocks.indexed) ...[
            if (i > 0) const SizedBox(height: 24),
            feedBlock(b),
          ],
      ],
    );
  }
}

/// One mosque's posts, swiped one card at a time, with the slider underneath.
///
/// Every card in the block ends up as tall as the block's tallest one, while
/// the block itself still sizes to its content. [IntrinsicHeight] cannot do
/// that here: it measures children speculatively and [UIButton] contains a
/// [LayoutBuilder], which refuses intrinsic queries. So each card reports its
/// laid-out height ([_MeasureHeight]) and is then given the running maximum as
/// a `minHeight` — grow-only, so it converges after one extra frame.
class _PostsCarousel extends HookWidget {
  const _PostsCarousel({super.key, required this.posts, required this.card});

  final List<MosquePostModel> posts;
  final Widget Function(MosquePostModel post) card;

  @override
  Widget build(BuildContext context) {
    final controller = useScrollController();
    final index = useState(0);
    final tallest = useState(0.0);

    useEffect(() {
      void listener() {
        if (!controller.hasClients) return;
        final page = controller.position.viewportDimension;
        if (page <= 0) return;
        var next = (controller.offset / page).round();
        if (next < 0) next = 0;
        if (next > posts.length - 1) next = posts.length - 1;
        if (next != index.value) index.value = next;
      }

      controller.addListener(listener);
      return () => controller.removeListener(listener);
    }, [controller, posts.length]);

    // A different set of cards has to be measured from scratch, otherwise the
    // block keeps the height of a card that is no longer in it.
    useEffect(() {
      tallest.value = 0;
      return null;
    }, [posts.length]);

    void report(double height) {
      // Half-pixel guard: fractional layout jitter must not retrigger a frame.
      if (height > tallest.value + 0.5) tallest.value = height;
    }

    return LayoutBuilder(
      builder: (context, constraints) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SingleChildScrollView(
            controller: controller,
            scrollDirection: Axis.horizontal,
            // Every card is exactly one viewport wide, so page snapping lands
            // on card boundaries.
            physics: const PageScrollPhysics(),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                for (final post in posts)
                  SizedBox(
                    width: constraints.maxWidth,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: _MeasureHeight(onHeight: report, child: card(post)),
                    ),
                  ),
              ],
            ),
          ),
          if (posts.length > 1) ...[
            const SizedBox(height: 12),
            Center(
              child: UISliderProgressBar(
                totalCount: posts.length,
                currentIndex: index.value,
                color: UIColorsToken.white,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Reports its child's laid-out height once per change, after the frame — the
/// only safe moment to turn a layout result into widget state.
class _MeasureHeight extends SingleChildRenderObjectWidget {
  const _MeasureHeight({required this.onHeight, required Widget super.child});

  final ValueChanged<double> onHeight;

  @override
  RenderObject createRenderObject(BuildContext context) => _RenderMeasureHeight(onHeight);

  @override
  void updateRenderObject(BuildContext context, covariant _RenderMeasureHeight renderObject) {
    renderObject.onHeight = onHeight;
  }
}

class _RenderMeasureHeight extends RenderProxyBox {
  _RenderMeasureHeight(this.onHeight);

  ValueChanged<double> onHeight;
  double? _reported;

  @override
  void performLayout() {
    super.performLayout();
    final height = size.height;
    if (_reported == height) return;
    _reported = height;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!attached) return;
      onHeight(height);
    });
  }
}

class _EmptyNewsCard extends StatelessWidget {
  const _EmptyNewsCard({required this.l10n});

  final AppLocale l10n;

  @override
  Widget build(BuildContext context) {
    final theme = UITheme.of(context);
    return UICard(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      child: Text(
        l10n.mosque_news_empty,
        textAlign: TextAlign.center,
        style: theme.typo.inter.caption.copyWith(color: UIColorsToken.textParagraph),
      ),
    );
  }
}

/// Logo · name · "Principal / Secondary mosque" — the row above each mosque's
/// posts.
class _MosqueIdentity extends StatelessWidget {
  const _MosqueIdentity({required this.mosque, required this.isPrincipal, required this.l10n, required this.onTap});

  final MosqueModel mosque;
  final bool isPrincipal;
  final AppLocale l10n;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = UITheme.of(context);

    return UITap(
      onTap: onTap,
      child: Row(
        spacing: 12,
        children: [
          MosqueLogo(mosque: mosque, size: 48),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mosque.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.typo.inter.titleMedium.copyWith(color: UIColorsToken.white),
                ),
                Text(
                  isPrincipal ? l10n.my_mosques_principal : l10n.my_mosques_secondary,
                  style: theme.typo.inter.caption.copyWith(color: UIColorsToken.textParagraph),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: UIColorsToken.textYellow),
        ],
      ),
    );
  }
}

class _NoMosqueCard extends StatelessWidget {
  const _NoMosqueCard({required this.l10n, required this.onFind});

  final AppLocale l10n;
  final VoidCallback onFind;

  @override
  Widget build(BuildContext context) {
    final theme = UITheme.of(context);
    return UICard(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(l10n.home_no_mosque_title, textAlign: TextAlign.center, style: theme.typo.inter.title.copyWith(color: UIColorsToken.white)),
          const SizedBox(height: 6),
          Text(l10n.home_no_mosque_subtitle, textAlign: TextAlign.center, style: theme.typo.inter.caption.copyWith(color: UIColorsToken.textParagraph)),
          const SizedBox(height: 16),
          UIButton.primary(label: l10n.home_find_mosque, fullWidth: true, onTap: onFind),
        ],
      ),
    );
  }
}
