import 'package:flutter/material.dart';
import 'package:nour/src/core/design_system/design_system.dart';

/// Three decorative overlapping avatars shown before the donor count.
class DonorsAvatarsWidget extends StatelessWidget {
  const DonorsAvatarsWidget({super.key});

  static const _colors = [
    Color(0xff6C8A5B),
    Color(0xffC59F54),
    Color(0xff8A6C5B),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 46,
      height: 22,
      child: Stack(
        children: [
          for (var i = 0; i < _colors.length; i++)
            Positioned(
              left: i * 10.0,
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: _colors[i],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person,
                  size: 10,
                  color: UIColorsToken.textParagraph,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
