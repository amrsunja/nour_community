import 'styles/inter_style.dart';

class UITypographyToken {
  final InterStyle inter;

  // 2. Main constructor
  UITypographyToken({
    required this.inter,
    });

  // 3. Light Factory: Pass the light color token
  factory UITypographyToken.light() {
    return UITypographyToken(
      inter: InterStyle.light(),
    );
  }

  // 4. Dark Factory: Pass the dark color token
  factory UITypographyToken.dark() {
    return UITypographyToken(
      inter: InterStyle.dark(),
    );
  }
}
