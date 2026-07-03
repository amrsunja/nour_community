import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/design_system/design_system.dart';

import '../state_management/proof_url_provider.dart';

/// Renders a disbursement-proof image from the private payout-proofs bucket via
/// a signed URL. Tapping opens a full-screen viewer. Shared by the admin ledger
/// and the public project transparency section.
class PayoutProofImage extends ConsumerWidget {
  const PayoutProofImage({
    super.key,
    required this.proofPath,
    this.height = 64,
    this.width = 64,
    this.radius = 10,
  });

  final String proofPath;
  final double height;
  final double width;
  final double radius;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final urlAsync = ref.watch(proofSignedUrlProvider(proofPath));

    return urlAsync.when(
      loading: () => _box(const UICircularProgressBar()),
      error: (_, __) => _box(Icon(
        Icons.broken_image_outlined,
        color: UIColorsToken.textParagraph,
        size: 20,
      )),
      data: (url) {
        if (url == null) {
          return _box(Icon(
            Icons.receipt_long_outlined,
            color: UIColorsToken.textParagraph,
            size: 20,
          ));
        }
        return UITap(
          onTap: () => _openViewer(context, url),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(radius),
            child: CachedNetworkImage(
              imageUrl: url,
              height: height,
              width: width,
              fit: BoxFit.cover,
              placeholder: (_, __) => _box(null),
              errorWidget: (_, __, ___) => _box(Icon(
                Icons.broken_image_outlined,
                color: UIColorsToken.textParagraph,
                size: 20,
              )),
            ),
          ),
        );
      },
    );
  }

  Widget _box(Widget? child) => Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: UIColorsToken.bgSurface,
          borderRadius: BorderRadius.circular(radius),
        ),
        child: Center(child: child),
      );

  void _openViewer(BuildContext context, String url) {
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: Center(
            child: InteractiveViewer(
              child: CachedNetworkImage(imageUrl: url, fit: BoxFit.contain),
            ),
          ),
        ),
      ),
    );
  }
}
