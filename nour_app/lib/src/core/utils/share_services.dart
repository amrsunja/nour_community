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

  /// Deep link to the hadith reader (`hadith/:collectionId/:hadithId`).
  static String hadithLink({
    required int collectionId,
    required int hadithId,
  }) =>
      link(RoutePaths.hadithReader(
        collectionId: collectionId,
        hadithId: hadithId,
      ));

  /// Deep link to the exact ayah in the reader (`surah/:surahId/ayah/:ayahId`).
  static String ayahLink({
    required int surahNumber,
    required int ayahNumber,
  }) =>
      link(RoutePaths.ayahReader(
        surahId: surahNumber,
        ayahId: ayahNumber,
      ));

  /// Deep link to the dua reader (`dua/:id`).
  static String duaLink({required int duaId}) =>
      link(RoutePaths.duaReader(id: duaId));

  /// Deep link to the adhkar detail pager (`adhkar/:id?adhkarId=`).
  static String adhkarLink({
    required int subcategoryId,
    int? adhkarId,
  }) =>
      link(RoutePaths.adhkarDetail(id: subcategoryId), {
        if (adhkarId != null) 'adhkarId': '$adhkarId',
      });

  /// Deep link to the impact project detail (`project/:id`).
  static String projectLink({required int projectId}) =>
      link(RoutePaths.impactProjectDetail(id: projectId));

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
