import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/providers/routing/navigation_services_provider.dart';
import 'package:nour/src/core/utils/talker/talker.dart';
import 'package:nour/src/features/auth/ui/state_management/auth_provider.dart';
import 'package:nour/src/features/profile/ui/state_management/profile_provider.dart';

final deepLinksServicesProvider = Provider((ref) => DeepLinksServices(ref));

/// `nour://` deep links (push payload `link`, share links) → routes (§6.4).
///
/// | link                                   | route                         |
/// | nour://mosque/{id}[?tab=..]            | MosqueProfileRoute            |
/// | nour://mosque/{id}/post/{postId}       | MosqueProfileRoute(tab: news) |
/// | nour://mosque/{id}/campaign/{cid}      | MosqueCampaignRoute           |
/// | nour://mosque-admin                    | MosqueAdminShell / Review     |
/// | nour://mosque-admin/stripe/return      | Stripe status (P3)            |
class DeepLinksServices {
  DeepLinksServices(this.ref);

  final Ref ref;

  /// Links received before the router/auth were ready are replayed by
  /// [flushPending] once authorization completes.
  String? _pending;

  static String cleanedLink(String link) {
    return link.replaceAll(RegExp(r'#/'), '');
  }

  static FutureOr<DeepLink> navigateDeepLink(PlatformDeepLink deepLink) async {
    return deepLink;
  }

  Future<void> open(String link) async {
    final auth = ref.read(authProvider);
    if (!auth.isAuthenticated) {
      _pending = link;
      return;
    }
    await _navigate(link);
  }

  Future<void> flushPending() async {
    final link = _pending;
    _pending = null;
    if (link != null) await _navigate(link);
  }

  Future<void> _navigate(String link) async {
    final nav = ref.read(navigationServicesProvider);
    final profile = ref.read(profileProvider).profile;
    Uri uri;
    try {
      uri = Uri.parse(link);
    } catch (e) {
      talker.warning('bad deep link: $link');
      return;
    }
    // nour://mosque/12 → host = 'mosque'; https://nour-community.com/mosque/12 → path only.
    final isWeb = uri.scheme == 'http' || uri.scheme == 'https';
    final segments = [
      if (!isWeb && uri.host.isNotEmpty) uri.host,
      ...uri.pathSegments.where((s) => s.isNotEmpty),
    ];
    if (segments.isEmpty) return;

    switch (segments.first) {
      case 'mosque-admin':
        if (profile?.isMosqueAccount ?? false) nav.toMosqueAdminOrReview();
        return;
      case 'mosque':
        if (segments.length < 2) return;
        final mosqueId = int.tryParse(segments[1]);
        if (mosqueId == null) return;
        if (profile?.isMosqueAccount ?? false) {
          // Mosque accounts have no worshipper navigation stack.
          nav.toMosqueAdminOrReview();
          return;
        }
        if (segments.length >= 4 && segments[2] == 'campaign') {
          final cid = int.tryParse(segments[3]);
          if (cid != null) {
            nav.toMosqueCampaign(mosqueId: mosqueId, campaignId: cid);
            return;
          }
        }
        if (segments.length >= 4 && segments[2] == 'post') {
          nav.toMosqueProfile(mosqueId: mosqueId, tab: 'news', postId: int.tryParse(segments[3]));
          return;
        }
        nav.toMosqueProfile(
          mosqueId: mosqueId,
          tab: segments.length >= 3 ? segments[2] : uri.queryParameters['tab'],
        );
        return;
      default:
        talker.info('unhandled deep link: $link');
    }
  }
}
