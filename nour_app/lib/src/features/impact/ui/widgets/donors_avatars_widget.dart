import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/features/payments/data/datasources/payment_remote_datasource.dart';
import 'package:nour/src/features/payments/data/payment_repo.dart';

/// Latest non-anonymous donors of a project (best effort; empty on error so
/// the widget falls back to the decorative circles).
final recentDonorsProvider = FutureProvider.autoDispose
    .family<List<RecentDonor>, int>((ref, projectId) {
  return ref.read(paymentRepoProvider).getRecentDonors(projectId, limit: 3);
});

/// Three overlapping avatars shown before the donor count. Real avatars of the
/// most recent donors who did not opt for anonymity; decorative placeholders
/// otherwise.
class DonorsAvatarsWidget extends ConsumerWidget {
  const DonorsAvatarsWidget({super.key, this.projectId});

  /// When null the widget stays purely decorative.
  final int? projectId;

  static const _colors = [
    Color(0xff6C8A5B),
    Color(0xffC59F54),
    Color(0xff8A6C5B),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final donors = projectId == null
        ? const <RecentDonor>[]
        : ref.watch(recentDonorsProvider(projectId!)).valueOrNull ?? const <RecentDonor>[];

    return SizedBox(
      width: 46,
      height: 22,
      child: Stack(
        children: [
          for (var i = 0; i < _colors.length; i++)
            Positioned(
              left: i * 10.0,
              child: _Avatar(
                color: _colors[i],
                url: i < donors.length ? donors[i].avatarUrl : null,
                initial: i < donors.length ? _initial(donors[i].name) : null,
              ),
            ),
        ],
      ),
    );
  }

  static String? _initial(String? name) {
    final n = name?.trim();
    if (n == null || n.isEmpty) return null;
    return n.substring(0, 1).toUpperCase();
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.color, this.url, this.initial});

  final Color color;
  final String? url;
  final String? initial;

  @override
  Widget build(BuildContext context) {
    final typo = UITheme.of(context).typo;
    return Container(
      width: 22,
      height: 22,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: UIColorsToken.bgSecondaryGreen, width: 1),
        image: url != null && url!.isNotEmpty
            ? DecorationImage(image: CachedNetworkImageProvider(url!), fit: BoxFit.cover)
            : null,
      ),
      child: url != null && url!.isNotEmpty
          ? null
          : initial != null
              ? Text(
                  initial!,
                  style: typo.inter.smallCaption.copyWith(
                    color: UIColorsToken.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                  ),
                )
              : Icon(Icons.person, size: 10, color: UIColorsToken.textParagraph),
    );
  }
}
