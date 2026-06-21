import 'package:flutter/material.dart';
import 'package:nour/src/core/design_system/design_system.dart';

/// Branded pull-to-refresh wrapper around [RefreshIndicator].
///
/// Keeps the gold spinner on the dark surface so it matches the rest of the
/// app. Drop it around any scrollable ([ListView], [CustomScrollView], …) and
/// wire [onRefresh] to a presenter `refresh()` call.
///
/// ```dart
/// UIRefreshIndicator(
///   onRefresh: presenter.refresh,
///   child: ListView(...),
/// )
/// ```
class UIRefreshIndicator extends StatelessWidget {
  const UIRefreshIndicator({
    super.key,
    required this.onRefresh,
    required this.child,
    this.edgeOffset = 0,
  });

  /// Triggered when the user pulls past the threshold. The spinner stays until
  /// the returned future completes.
  final Future<void> Function() onRefresh;

  /// The scrollable to wrap. Must be scrollable (or always-scrollable) for the
  /// gesture to fire even when the content is short.
  final Widget child;

  /// Distance from the top edge at which the indicator settles (e.g. under an
  /// app bar).
  final double edgeOffset;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      edgeOffset: edgeOffset,
      color: UIColorsToken.yellow,
      backgroundColor: UIColorsToken.bgSurface,
      strokeWidth: 2.4,
      displacement: 28,
      child: child,
    );
  }
}
