import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';
import 'package:nour/src/core/providers/routing/navigation_services_provider.dart';
import 'package:nour/src/core/providers/widgets/snackbar_provider.dart';
import 'package:nour/src/core/routing/route_paths.dart';
import 'package:nour/src/core/utils/islamic_tools/islamic_tools.dart';
import 'package:nour/src/core/utils/share_services.dart';
import 'package:nour/src/core/utils/talker/talker.dart';
import 'package:nour/src/features/settings/ui/state_management/app_config_provider.dart';
import 'package:nour/src/features/tools/ui/state_management/prayer_times_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/models/mosque_enums.dart';
import '../../data/models/mosque_model.dart';
import '../../data/models/mosque_post_model.dart';
import '../state_management/mosque_profile_provider.dart';
import '../state_management/my_mosques_provider.dart';
import '../widgets/ics_export.dart';
import '../widgets/mosque_donation_tab.dart';
import '../widgets/mosque_header.dart';
import '../widgets/mosque_information_tab.dart';
import '../widgets/mosque_post_card.dart';
import '../widgets/mosque_prayers_tab.dart';
import '../widgets/my_mosques_sheet.dart';
import '../widgets/say_dua_sheet.dart';

/// Public mosque profile — worshipper POV (Figma section 1098:5923).
@RoutePage()
class MosqueProfilePage extends HookConsumerWidget {
  const MosqueProfilePage({
    super.key,
    @PathParam('id') required this.mosqueId,
    @QueryParam('tab') this.tab,
    @QueryParam('postId') this.postId,
  });

  final int mosqueId;
  final String? tab;
  final int? postId;

  static MosqueTab _parseTab(String? t) => MosqueTab.values.firstWhere((e) => e.name == t, orElse: () => MosqueTab.prayers);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = UITheme.of(context);
    final l10n = ref.watch(l10nProvider);
    final nav = ref.read(navigationServicesProvider);
    final snackbar = ref.read(snackbarProvider);
    final presenter = ref.read(mosqueProfileProvider(mosqueId).notifier);
    final state = ref.watch(mosqueProfileProvider(mosqueId));
    final myMosques = ref.watch(myMosquesProvider);
    final donationsFlag = ref.watch(appConfigProvider.select((c) => c.mosqueDonationsEnabled));
    final computed = ref.watch(prayerTimesProvider.select((s) => s.times));

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        presenter.init(tab: _parseTab(tab));
        ref.read(myMosquesProvider.notifier).init();
      });
      return null;
    }, const []);

    final mosque = state.mosque;

    Future<void> share(MosqueModel m) async {
      final link = ShareServices.link(RoutePaths.mosqueProfile(id: m.id));
      await Share.share('${m.name}\n$link');
    }

    Future<void> sharePost(MosquePostModel p) async {
      final link = ShareServices.link('${RoutePaths.mosqueProfile(id: mosqueId)}/post/${p.id}');
      await Share.share('${p.title}\n$link');
    }

    Future<void> onSayDua(MosquePostModel p) async {
      final done = await SayDuaSheet.show(context, l10n: l10n);
      if (done) await presenter.sayDua(p);
    }

    Future<void> onAddToMyMosques() async {
      if (mosque == null) return;
      final saved = await MyMosquesSheet.show(context, candidate: mosque);
      if (saved) {
        snackbar.showSuccess(l10n.my_mosques_saved);
        await ref.read(prayerTimesProvider.notifier).refresh();
      }
    }

    if (mosque == null) {
      return UIGradientLinedScaffold(
        appBar: UIAppBar(onBack: () => context.router.maybePop()),
        body: const Center(child: UICircularProgressBar()),
      );
    }

    final isMine = myMosques.isMine(mosque.id);
    final isOpen = _isOpen(state, computed);

    Widget body = switch (state.tab) {
      MosqueTab.prayers => MosquePrayersTab(
          l10n: l10n,
          day: state.today,
          fallback: computed,
          todayDate: state.todayDate ?? DateTime.now(),
        ),
      MosqueTab.information => MosqueInformationTab(mosque: mosque, l10n: l10n),
      MosqueTab.news => _NewsTab(
          l10n: l10n,
          posts: state.posts,
          loaded: state.postsLoaded,
          highlightPostId: postId,
          onAttend: presenter.toggleAttend,
          onApply: presenter.applyVolunteer,
          onSayDua: onSayDua,
          onShare: sharePost,
          onAddToCalendar: (p) => IcsExport.share(p, mosqueName: mosque.name, location: mosque.fullAddress).catchError((e) => talker.error(e)),
          onViewed: presenter.trackPostView,
        ),
      MosqueTab.donation => MosqueDonationTab(mosque: mosque, l10n: l10n),
    };

    return Scaffold(
      backgroundColor: UIColorsToken.bgPrimary,
      body: Stack(
        children: [
          RefreshIndicator(
            color: UIColorsToken.textYellow,
            onRefresh: presenter.refresh,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
              padding: EdgeInsets.only(bottom: state.tab == MosqueTab.prayers && !isMine ? 110 : 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  MosqueHeader(
                    mosque: mosque,
                    l10n: l10n,
                    tab: state.tab,
                    onTab: presenter.setTab,
                    isOpen: isOpen,
                    showDonationTab: donationsFlag && mosque.donationsEnabled,
                    newsBadge: state.posts.any((p) => DateTime.now().difference(p.publishedAt).inDays < 2),
                    onBack: () => context.router.maybePop(),
                    onShare: () => share(mosque),
                    onCopiedAddress: () => snackbar.showInfo(l10n.mosque_address_copied),
                    actions: Row(
                      children: [
                        Expanded(
                          child: state.isFollowing
                              ? UIButton.secondary(
                                  label: l10n.mosque_following,
                                  fullWidth: true,
                                  isBusy: state.followBusy,
                                  onTap: presenter.toggleFollow,
                                )
                              : UIButton.primary(
                                  label: l10n.mosque_follow,
                                  fullWidth: true,
                                  isBusy: state.followBusy,
                                  onTap: presenter.toggleFollow,
                                ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 3,
                          child: state.isMember
                              ? UIButton.secondary(label: l10n.mosque_member_badge, fullWidth: true)
                              : UIButton.secondary(
                                  label: l10n.mosque_become_member,
                                  fullWidth: true,
                                  onTap: () => nav.toMosqueBecomeMember(mosqueId: mosque.id),
                                ),
                        ),
                      ],
                    ),
                  ),
                  if (state.isLoading && !state.postsLoaded)
                    const Padding(padding: EdgeInsets.all(40), child: Center(child: UICircularProgressBar()))
                  else
                    body,
                ],
              ),
            ),
          ),
          if (state.tab == MosqueTab.prayers)
            Positioned(
              left: 16,
              right: 16,
              bottom: 16 + MediaQuery.of(context).padding.bottom,
              child: isMine
                  ? Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(color: UIColorsToken.bgSurface, borderRadius: BorderRadius.circular(12)),
                      child: Center(
                        child: Text(
                          myMosques.principal?.id == mosque.id ? l10n.my_mosques_is_principal : l10n.my_mosques_is_secondary,
                          style: theme.typo.inter.bodyMedium.copyWith(color: UIColorsToken.textYellow),
                        ),
                      ),
                    )
                  : UIButton.primary(label: l10n.mosque_add_to_my_mosques, fullWidth: true, onTap: onAddToMyMosques),
            ),
        ],
      ),
    );
  }

  /// Open from Fajr − 30 min to Isha + 45 min unless the mosque overrides it.
  static bool _isOpen(MosqueProfileState state, DailyPrayerTimes? computed) {
    final manual = state.mosque?.openingStatus;
    if (manual == 'open') return true;
    if (manual == 'closed') return false;
    final times = state.today != null && !state.today!.isEmpty ? state.today!.toDailyPrayerTimes(fallback: computed) : computed;
    if (times == null) return false;
    final now = DateTime.now();
    return now.isAfter(times.fajr.subtract(const Duration(minutes: 30))) && now.isBefore(times.isha.add(const Duration(minutes: 45)));
  }
}

class _NewsTab extends StatelessWidget {
  const _NewsTab({
    required this.l10n,
    required this.posts,
    required this.loaded,
    this.highlightPostId,
    required this.onAttend,
    required this.onApply,
    required this.onSayDua,
    required this.onShare,
    required this.onAddToCalendar,
    required this.onViewed,
  });

  final AppLocale l10n;
  final List<MosquePostModel> posts;
  final bool loaded;
  final int? highlightPostId;
  final ValueChanged<MosquePostModel> onAttend;
  final ValueChanged<MosquePostModel> onApply;
  final ValueChanged<MosquePostModel> onSayDua;
  final ValueChanged<MosquePostModel> onShare;
  final ValueChanged<MosquePostModel> onAddToCalendar;
  final ValueChanged<int> onViewed;

  @override
  Widget build(BuildContext context) {
    final theme = UITheme.of(context);
    if (!loaded) return const Padding(padding: EdgeInsets.all(40), child: Center(child: UICircularProgressBar()));
    if (posts.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(40),
        child: Center(
          child: Text(l10n.mosque_news_empty, textAlign: TextAlign.center, style: theme.typo.inter.body.copyWith(color: UIColorsToken.textParagraph)),
        ),
      );
    }
    // Deep-linked post first.
    final ordered = highlightPostId == null
        ? posts
        : [...posts.where((p) => p.id == highlightPostId), ...posts.where((p) => p.id != highlightPostId)];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        children: [
          for (final p in ordered)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _Viewed(
                onViewed: () => onViewed(p.id),
                child: MosquePostCard(
                  post: p,
                  l10n: l10n,
                  onAttend: () => onAttend(p),
                  onApply: () => onApply(p),
                  onSayDua: () => onSayDua(p),
                  onShare: () => onShare(p),
                  onAddToCalendar: p.isEvent ? () => onAddToCalendar(p) : null,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Fires [onViewed] once when the child is first built (cheap view tracking;
/// the server dedupes per user/post).
class _Viewed extends StatefulWidget {
  const _Viewed({required this.child, required this.onViewed});
  final Widget child;
  final VoidCallback onViewed;

  @override
  State<_Viewed> createState() => _ViewedState();
}

class _ViewedState extends State<_Viewed> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => widget.onViewed());
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
