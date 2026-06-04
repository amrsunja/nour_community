import 'package:url_launcher/url_launcher.dart';

import 'talker/talker.dart';

/// Thin wrapper around `url_launcher` for the few external launches the app
/// needs (email, generic URLs). Returns `false` on failure instead of throwing
/// so callers can decide whether to surface an error.
abstract class UrlLauncherService {
  /// Opens the user's default mail client (e.g. Gmail) composing to [email].
  /// Optional [subject] / [body] are URL-encoded into the `mailto:` query.
  static Future<bool> sendEmail(
    String email, {
    String? subject,
    String? body,
  }) {
    final query = <String, String>{
      if (subject != null) 'subject': subject,
      if (body != null) 'body': body,
    };

    final uri = Uri(
      scheme: 'mailto',
      path: email,
      query: query.isEmpty ? null : _encodeQuery(query),
    );

    return _launch(uri, mode: LaunchMode.externalApplication);
  }

  /// Opens [rawUrl] in an external application (browser / store).
  static Future<bool> openExternal(String rawUrl) =>
      _launch(Uri.parse(rawUrl), mode: LaunchMode.externalApplication);

  static Future<bool> _launch(
    Uri uri, {
    LaunchMode mode = LaunchMode.platformDefault,
  }) async {
    try {
      if (!await canLaunchUrl(uri)) {
        talker.warning('url_launcher: cannot launch $uri');
        return false;
      }
      return launchUrl(uri, mode: mode);
    } catch (e, st) {
      talker.handle(e, st, 'url_launcher: failed to launch $uri');
      return false;
    }
  }

  /// `Uri`'s default encoding turns spaces into `+`; mail clients expect `%20`,
  /// so encode each component explicitly.
  static String _encodeQuery(Map<String, String> params) => params.entries
      .map((e) =>
          '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
      .join('&');
}
