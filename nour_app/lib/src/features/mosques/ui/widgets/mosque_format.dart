import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nour/src/core/locale/l10n.dart';

/// Small formatting helpers shared by the mosque screens.
class MosqueFormat {
  static String hhmm(TimeOfDay? t) =>
      t == null ? '--:--' : '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  static String hhmmDate(DateTime t) => '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  static String km(double? d) => d == null ? '' : '${d.toStringAsFixed(2)}km';

  static String compact(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 10000) return '${(n / 1000).toStringAsFixed(0)}k';
    return NumberFormat.decimalPattern().format(n);
  }

  static String money(double v, {String symbol = '€'}) {
    final f = NumberFormat.decimalPattern();
    return '${f.format(v.round())}$symbol';
  }

  /// "14 min ago", "Yesterday", "3 weeks ago" …
  static String timeAgo(DateTime t, AppLocale l10n) {
    final diff = DateTime.now().difference(t);
    if (diff.inMinutes < 1) return l10n.mosque_time_just_now;
    if (diff.inMinutes < 60) return l10n.mosque_time_min_ago(diff.inMinutes);
    if (diff.inHours < 24) return l10n.mosque_time_hours_ago(diff.inHours);
    if (diff.inDays == 1) return l10n.mosque_time_yesterday;
    if (diff.inDays < 7) return l10n.mosque_time_days_ago(diff.inDays);
    if (diff.inDays < 30) return l10n.mosque_time_weeks_ago((diff.inDays / 7).floor());
    return DateFormat.yMMMd().format(t);
  }

  static String dayMonth(DateTime d, String lang) => DateFormat('d MMMM', lang).format(d);
  static String monthShort(DateTime d, String lang) => DateFormat('MMM', lang).format(d).toUpperCase();
  static String longDate(DateTime d, String lang) => DateFormat('MMM d, yyyy', lang).format(d);
}
