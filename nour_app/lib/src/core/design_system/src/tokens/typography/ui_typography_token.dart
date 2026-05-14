class UITypographyToken {
  // 2. Main constructor
  UITypographyToken();

  // 3. Light Factory: Pass the light color token
  factory UITypographyToken.light() {
    return UITypographyToken(
    );
  }

  // 4. Dark Factory: Pass the dark color token
  factory UITypographyToken.dark() {
    return UITypographyToken(
    );
  }
}
