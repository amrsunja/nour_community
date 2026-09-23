import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/models/mosque_post_model.dart';

/// "Add to my calendar" (specs A2): exports an .ics file and hands it to the
/// OS share sheet — no Google/Apple calendar permissions required.
class IcsExport {
  static String _fmt(DateTime d) {
    final u = d.toUtc();
    String two(int v) => v.toString().padLeft(2, '0');
    return '${u.year}${two(u.month)}${two(u.day)}T${two(u.hour)}${two(u.minute)}${two(u.second)}Z';
  }

  static String _escape(String s) => s.replaceAll('\\', '\\\\').replaceAll(';', '\\;').replaceAll(',', '\\,').replaceAll('\n', '\\n');

  static String build(MosquePostModel post, {required String mosqueName, String? location}) {
    final start = post.startsAt ?? DateTime.now();
    final end = post.eventEndTime != null && post.eventDate != null
        ? DateTime(post.eventDate!.year, post.eventDate!.month, post.eventDate!.day, post.eventEndTime!.hour, post.eventEndTime!.minute)
        : start.add(const Duration(hours: 2));
    return [
      'BEGIN:VCALENDAR',
      'VERSION:2.0',
      'PRODID:-//Nour Community//Mosques//EN',
      'CALSCALE:GREGORIAN',
      'METHOD:PUBLISH',
      'BEGIN:VEVENT',
      'UID:nour-mosque-post-${post.id}@nour-community.com',
      'DTSTAMP:${_fmt(DateTime.now())}',
      'DTSTART:${_fmt(start)}',
      'DTEND:${_fmt(end)}',
      'SUMMARY:${_escape(post.title)}',
      if ((post.body ?? '').isNotEmpty) 'DESCRIPTION:${_escape(post.body!)}',
      'LOCATION:${_escape(location ?? post.location ?? mosqueName)}',
      'URL:${post.deepLink}',
      'END:VEVENT',
      'END:VCALENDAR',
    ].join('\r\n');
  }

  static Future<void> share(MosquePostModel post, {required String mosqueName, String? location}) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/nour_event_${post.id}.ics');
    await file.writeAsString(build(post, mosqueName: mosqueName, location: location));
    await Share.shareXFiles([XFile(file.path, mimeType: 'text/calendar')], subject: post.title);
  }
}
