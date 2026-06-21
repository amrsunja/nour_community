import 'package:flutter/material.dart';
import 'package:nour/src/core/design_system/design_system.dart';

/// Transparent design-system app bar.
///
/// Drop it into any [Scaffold.appBar] (e.g. [UIGradientLinedScaffold]) — it
/// keeps a transparent background so the page gradient shows through.
///
/// - [onBack]: when non-null, renders a leading back chevron.
/// - [title]: centered title text.
/// - [leadingIcons]: extra widgets placed on the leading edge, after the back
///   button (e.g. custom action icons).
class UIAppBar extends StatelessWidget implements PreferredSizeWidget {
  const UIAppBar({
    super.key,
    this.onBack,
    this.title,
    this.leadingIcons = const [],
    this.height = 56,
  });

  final VoidCallback? onBack;
  final String? title;
  final List<Widget> leadingIcons;
  final double height;

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    final typo = UITheme.of(context).typo;

    return SafeArea(
      bottom: false,
      child: SizedBox(
        height: height,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (title != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 56),
                child: Text(
                  title!,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: typo.inter.title.copyWith(color: UIColorsToken.white),
                ),
              ),
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  mainAxisAlignment: .spaceBetween,
                  children: [
                    if (onBack != null)
                      UIIcon(
                        UIIconsToken.icons.chevronLeft,
                        color: UIColorsToken.yellow,
                        onTap: onBack,
                      ),
                    Row(
                      spacing: 8,
                      children: [
                        ...leadingIcons,
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
