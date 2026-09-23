import 'package:flutter/material.dart';

import '../tokens/colors/ui_colors_token.dart';

/// App-themed wrappers around the Material date / time pickers.
///
/// Use these instead of calling `showDatePicker` / `showTimePicker` directly so
/// every picker in the app shares the Nour palette (dark surfaces, yellow
/// accents) instead of the stock Material blue.
abstract final class UIPickers {
  static const _radius = 24.0;
  static const String _font = 'Saans';

  static final RoundedRectangleBorder _shape =
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(_radius));

  /// Dark Material theme tuned to [UIColorsToken] and applied to the pickers.
  static ThemeData themeOf(BuildContext context) {
    final base = ThemeData.dark(useMaterial3: true);
    final scheme = base.colorScheme.copyWith(
      brightness: Brightness.dark,
      primary: UIColorsToken.textYellow,
      onPrimary: UIColorsToken.bgPrimary,
      primaryContainer: UIColorsToken.bgTertiaryGreen,
      onPrimaryContainer: UIColorsToken.textYellow,
      secondary: UIColorsToken.textYellow,
      onSecondary: UIColorsToken.bgPrimary,
      secondaryContainer: UIColorsToken.bgSecondaryGreen,
      onSecondaryContainer: UIColorsToken.textYellow,
      surface: UIColorsToken.bgSurface,
      onSurface: UIColorsToken.white,
      surfaceContainerHigh: UIColorsToken.bgSurface,
      surfaceContainerHighest: UIColorsToken.bgSecondaryGreen,
      onSurfaceVariant: UIColorsToken.textParagraph,
      outline: UIColorsToken.stroke,
      outlineVariant: UIColorsToken.stroke,
      error: UIColorsToken.red,
      onError: UIColorsToken.white,
    );

    return base.copyWith(
      colorScheme: scheme,
      scaffoldBackgroundColor: UIColorsToken.bgPrimary,
      dialogTheme: DialogThemeData(
        backgroundColor: UIColorsToken.bgSurface,
        surfaceTintColor: Colors.transparent,
        shape: _shape,
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: UIColorsToken.textYellow,
          textStyle: const TextStyle(fontFamily: _font, fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(foregroundColor: UIColorsToken.textYellow),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: UIColorsToken.bgSecondaryGreen,
        hintStyle: TextStyle(color: UIColorsToken.textParagraph, fontFamily: _font),
        labelStyle: TextStyle(color: UIColorsToken.textParagraph, fontFamily: _font),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: UIColorsToken.stroke),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: UIColorsToken.stroke),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: UIColorsToken.textYellow),
        ),
      ),
      datePickerTheme: datePickerTheme,
      timePickerTheme: timePickerTheme,
    );
  }

  /// Standalone picker themes, also installed on the app-wide [ThemeData] so a
  /// raw `showDatePicker` / `showTimePicker` still gets the Nour palette.
  static final DatePickerThemeData datePickerTheme = DatePickerThemeData(
      backgroundColor: UIColorsToken.bgSurface,
      surfaceTintColor: Colors.transparent,
      shadowColor: UIColorsToken.shadow,
      elevation: 0,
      shape: _shape,
      headerBackgroundColor: UIColorsToken.bgSecondaryGreen,
      headerForegroundColor: UIColorsToken.textYellow,
      headerHeadlineStyle: const TextStyle(
        fontFamily: _font,
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: UIColorsToken.textYellow,
      ),
      headerHelpStyle: TextStyle(fontFamily: _font, fontSize: 12, color: UIColorsToken.textParagraph),
      weekdayStyle: TextStyle(fontFamily: _font, fontSize: 12, color: UIColorsToken.textParagraph),
      dayStyle: const TextStyle(fontFamily: _font, fontSize: 14, fontWeight: FontWeight.w500),
      dayForegroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) return UIColorsToken.white.withValues(alpha: .25);
        if (states.contains(WidgetState.selected)) return UIColorsToken.bgPrimary;
        return UIColorsToken.white;
      }),
      dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return UIColorsToken.textYellow;
        return Colors.transparent;
      }),
      dayOverlayColor: WidgetStatePropertyAll(UIColorsToken.textYellow.withValues(alpha: .12)),
      dayShape: const WidgetStatePropertyAll(CircleBorder()),
      todayForegroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return UIColorsToken.bgPrimary;
        return UIColorsToken.textYellow;
      }),
      todayBackgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return UIColorsToken.textYellow;
        return Colors.transparent;
      }),
      todayBorder: const BorderSide(color: UIColorsToken.textYellow),
      yearStyle: const TextStyle(fontFamily: _font, fontSize: 14, fontWeight: FontWeight.w500),
      yearForegroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) return UIColorsToken.white.withValues(alpha: .25);
        if (states.contains(WidgetState.selected)) return UIColorsToken.bgPrimary;
        return UIColorsToken.white;
      }),
      yearBackgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return UIColorsToken.textYellow;
        return Colors.transparent;
      }),
      yearOverlayColor: WidgetStatePropertyAll(UIColorsToken.textYellow.withValues(alpha: .12)),
      rangeSelectionBackgroundColor: UIColorsToken.bgTertiaryGreen,
      rangeSelectionOverlayColor: WidgetStatePropertyAll(UIColorsToken.textYellow.withValues(alpha: .12)),
      dividerColor: UIColorsToken.stroke,
      cancelButtonStyle: TextButton.styleFrom(foregroundColor: UIColorsToken.textParagraph),
      confirmButtonStyle: TextButton.styleFrom(foregroundColor: UIColorsToken.textYellow),
  );

  static final TimePickerThemeData timePickerTheme = TimePickerThemeData(
      backgroundColor: UIColorsToken.bgSurface,
      shape: _shape,
      elevation: 0,
      helpTextStyle: TextStyle(fontFamily: _font, fontSize: 12, color: UIColorsToken.textParagraph),
      hourMinuteShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: UIColorsToken.stroke),
      ),
      hourMinuteColor: WidgetStateColor.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? UIColorsToken.bgTertiaryGreen
            : UIColorsToken.bgSecondaryGreen,
      ),
      hourMinuteTextColor: WidgetStateColor.resolveWith(
        (states) => states.contains(WidgetState.selected) ? UIColorsToken.textYellow : UIColorsToken.white,
      ),
      hourMinuteTextStyle: const TextStyle(fontFamily: _font, fontSize: 40, fontWeight: FontWeight.w600),
      dayPeriodShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: UIColorsToken.stroke),
      ),
      dayPeriodBorderSide: BorderSide(color: UIColorsToken.stroke),
      dayPeriodColor: WidgetStateColor.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? UIColorsToken.bgTertiaryGreen
            : Colors.transparent,
      ),
      dayPeriodTextColor: WidgetStateColor.resolveWith(
        (states) => states.contains(WidgetState.selected) ? UIColorsToken.textYellow : UIColorsToken.textParagraph,
      ),
      dayPeriodTextStyle: const TextStyle(fontFamily: _font, fontSize: 14, fontWeight: FontWeight.w600),
      dialBackgroundColor: UIColorsToken.bgSecondaryGreen,
      dialHandColor: UIColorsToken.textYellow,
      dialTextColor: WidgetStateColor.resolveWith(
        (states) => states.contains(WidgetState.selected) ? UIColorsToken.bgPrimary : UIColorsToken.white,
      ),
      dialTextStyle: const TextStyle(fontFamily: _font, fontSize: 16, fontWeight: FontWeight.w500),
      entryModeIconColor: UIColorsToken.textYellow,
      cancelButtonStyle: TextButton.styleFrom(foregroundColor: UIColorsToken.textParagraph),
      confirmButtonStyle: TextButton.styleFrom(foregroundColor: UIColorsToken.textYellow),
  );

  /// Wraps [child] with the picker theme. Use as the `builder` of any Material
  /// picker that isn't covered by the helpers below.
  static Widget wrap(BuildContext context, Widget? child, {bool use24h = false}) {
    final themed = Theme(data: themeOf(context), child: child ?? const SizedBox.shrink());
    if (!use24h) return themed;
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
      child: themed,
    );
  }

  /// Themed [showDatePicker].
  static Future<DateTime?> date(
    BuildContext context, {
    required DateTime initialDate,
    required DateTime firstDate,
    required DateTime lastDate,
    SelectableDayPredicate? selectableDayPredicate,
    DatePickerEntryMode initialEntryMode = DatePickerEntryMode.calendar,
    DatePickerMode initialDatePickerMode = DatePickerMode.day,
    String? helpText,
  }) {
    return showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      selectableDayPredicate: selectableDayPredicate,
      initialEntryMode: initialEntryMode,
      initialDatePickerMode: initialDatePickerMode,
      helpText: helpText,
      builder: (ctx, child) => wrap(ctx, child),
    );
  }

  /// Themed [showTimePicker]. Defaults to 24-hour input.
  static Future<TimeOfDay?> time(
    BuildContext context, {
    required TimeOfDay initialTime,
    bool use24h = true,
    TimePickerEntryMode initialEntryMode = TimePickerEntryMode.dial,
    String? helpText,
  }) {
    return showTimePicker(
      context: context,
      initialTime: initialTime,
      initialEntryMode: initialEntryMode,
      helpText: helpText,
      builder: (ctx, child) => wrap(ctx, child, use24h: use24h),
    );
  }
}
