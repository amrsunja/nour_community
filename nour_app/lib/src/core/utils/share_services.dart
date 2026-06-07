import 'package:share_plus/share_plus.dart';

import '../routing/route_paths.dart';
import 'constants/constants.dart';

/// Central place for all sharing functionality.
///
/// Responsibilities:
/// 1. Builds shareable deep links from the route configuration
///    ([RoutePaths], used by `app_router.dart`) — no URL is ever hardcoded
///    at a call site. If a route path changes, only this file (via
///    [RoutePaths]) is affected.
/// 2. Formats the share message per content type.
/// 3. Triggers the platform share sheet (`share_plus`).
///
/// Query parameter names intentionally match the route pages' constructor
/// arguments (e.g. `collectionId` / `initialHadithId` for
/// `HadithDetailPage`), so inbound deep-link resolution can map them 1:1.
abstract class ShareServices {
  // ---------------------------------------------------------------------------
  // Link builders (public so other features — e.g. dynamic links, QR codes —
  // can reuse them without going through the share sheet).
  // ---------------------------------------------------------------------------

  /// `<website>/<routePath>?<params>` from the route configuration.
  static String link(String routePath, [Map<String, String>? params]) =>
      Uri.parse(website)
          .replace(
            path: '/$routePath',
            queryParameters:
                (params == null || params.isEmpty) ? null : params,
          )
          .toString();

  /// Deep link to the hadith reader (`RoutePaths.hadithReader`).
  static String hadithLink({
    required int collectionId,
    required int hadithId,
  }) =>
      link(RoutePaths.hadithReader, {
        'collectionId': '$collectionId',
        'initialHadithId': '$hadithId',
      });

  /// Deep link to the exact ayah in the reader (`RoutePaths.ayahReader`).
  static String ayahLink({
    required int surahNumber,
    required int ayahNumber,
  }) =>
      link(RoutePaths.ayahReader, {
        'surahNumber': '$surahNumber',
        'initialAyah': '$ayahNumber',
      });

  /// Deep link to the dua reader (`RoutePaths.duaReader`).
  static String duaLink({required int duaId}) =>
      link(RoutePaths.duaReader, {'initialDuaId': '$duaId'});

  /// Deep link to the adhkar detail pager (`RoutePaths.adhkarDetail`).
  static String adhkarLink({
    required int subcategoryId,
    int? adhkarId,
  }) =>
      link(RoutePaths.adhkarDetail, {
        'subcategoryId': '$subcategoryId',
        if (adhkarId != null) 'initialAdhkarId': '$adhkarId',
      });

  /// Deep link to the impact project detail
  /// (`RoutePaths.impactProjectDetail`).
  static String projectLink({required int projectId}) =>
      link(RoutePaths.impactProjectDetail, {'projectId': '$projectId'});

  // ---------------------------------------------------------------------------
  // Share actions
  // ---------------------------------------------------------------------------

  /// Hadith: title (fallback when no reference), Arabic text, translation,
  /// reference/source and a deep link to the hadith detail page.
  static Future<void> shareHadith({
    required String arabicText,
    required int collectionId,
    required int hadithId,
    String title = '',
    String translation = '',
    String reference = '',
  }) =>
      _share([
        arabicText,
        translation,
        _signature(reference.isNotEmpty ? reference : title),
        hadithLink(collectionId: collectionId, hadithId: hadithId),
      ]);

  /// Ayah: Arabic text, translation, "Surah (n:m)" reference and a deep link
  /// to the exact ayah in the reader.
  static Future<void> shareAyah({
    required String surahName,
    required int surahNumber,
    required int ayahNumber,
    required String arabicText,
    String translation = '',
  }) =>
      _share([
        arabicText,
        translation,
        _signature('$surahName ($surahNumber:$ayahNumber)'),
        ayahLink(surahNumber: surahNumber, ayahNumber: ayahNumber),
      ]);

  /// Dua: title (fallback when no reference), Arabic text, translation,
  /// reference and a deep link to the dua detail page.
  static Future<void> shareDua({
    required String arabicText,
    required int duaId,
    String title = '',
    String translation = '',
    String reference = '',
  }) =>
      _share([
        arabicText,
        translation,
        _signature(reference.isNotEmpty ? reference : title),
        duaLink(duaId: duaId),
      ]);

  /// Adhkar: title, Arabic text, translation, reference and a deep link to
  /// the adhkar detail page.
  static Future<void> shareAdhkar({
    required String arabicText,
    required int subcategoryId,
    int? adhkarId,
    String? title,
    String? translation,
    String? reference,
  }) =>
      _share([
        title ?? '',
        arabicText,
        translation ?? '',
        _signature(reference ?? ''),
        adhkarLink(subcategoryId: subcategoryId, adhkarId: adhkarId),
      ]);

  /// Impact project: title, short description and a deep link to the project
  /// detail page.
  static Future<void> shareProject({
    required String title,
    required int projectId,
    String description = '',
  }) =>
      _share([
        title,
        description,
        projectLink(projectId: projectId),
      ]);

  // ---------------------------------------------------------------------------
  // Internals
  // ---------------------------------------------------------------------------

  static String _signature(String source) => source.isEmpty ? '' : '— $source';

  /// Joins the non-empty [parts] and opens the platform share sheet.
  static Future<void> _share(List<String> parts) => SharePlus.instance.share(
        ShareParams(text: parts.where((p) => p.isNotEmpty).join('\n\n')),
      );
}
