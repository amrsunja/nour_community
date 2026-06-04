import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/errors/exceptions/server/server_exception.dart';
import 'package:nour/src/core/network/supabase_client.dart';
import 'package:nour/src/core/utils/talker/talker.dart';

import '../models/impact_project_model.dart';
import '../models/project_category_model.dart';

final impactRemoteDataProvider = Provider((ref) => ImpactRemoteDatasource());

/// Read/write access for the Impact feature.
///
/// Catalog reads (categories / projects / stories) are open to any
/// authenticated user via RLS; the `favorite_impact_projects` table is scoped
/// to the owner, so we pass `user_id` explicitly on write.
class ImpactRemoteDatasource {
  static const _categoriesTable = 'project_categories';
  static const _projectsTable = 'impact_projects';
  static const _favoritesTable = 'favorite_impact_projects';
  static const _storiesBucket = 'project-stories';

  /// Embedded select used by both list and detail (detail also pulls stories).
  static const _projectColumns =
      '*, partner_organizations(*), project_categories(*)';
  static const _projectDetailColumns =
      '*, partner_organizations(*), project_categories(*), project_stories(*)';

  String _requireUserId() {
    final authUser = supabaseClient.auth.currentUser;
    if (authUser == null) {
      throw ServerException(
        type: .unauthorized,
        message: 'The user is not authenticated',
      );
    }
    return authUser.id;
  }

  /// Resolves a stored story/cover image reference to a usable URL. Accepts a
  /// full URL (returned as-is) or a `project-stories` storage object path.
  static String? publicStoryImageUrl(String? ref) {
    if (ref == null || ref.isEmpty) return null;
    if (ref.startsWith('http')) return ref;
    return supabaseClient.storage.from(_storiesBucket).getPublicUrl(ref);
  }

  // ── Categories ──────────────────────────────────────────────────────────────

  Future<List<ProjectCategoryModel>> getCategories() async {
    try {
      final response = await supabaseClient
          .from(_categoriesTable)
          .select()
          .order('position', ascending: true);

      return (response as List)
          .map((e) => ProjectCategoryModel.fromJson(e))
          .toList();
    } catch (e) {
      talker.error(e);
      throw ServerException(
        type: .badRequest,
        message: 'Failed to load project categories',
      );
    }
  }

  // ── Projects ──────────────────────────────────────────────────────────────────

  /// Active projects, optionally filtered by [categoryId]. Ordered by
  /// `position` then newest.
  Future<List<ImpactProjectModel>> getProjects({int? categoryId}) async {
    try {
      var query = supabaseClient
          .from(_projectsTable)
          .select(_projectColumns)
          .eq('is_active', true);

      if (categoryId != null) {
        query = query.eq('project_category_id', categoryId);
      }

      final response = await query
          .order('position', ascending: true)
          .order('created_at', ascending: false);

      return (response as List)
          .map((e) => ImpactProjectModel.fromJson(e))
          .toList();
    } catch (e) {
      talker.error(e);
      throw ServerException(
        type: .badRequest,
        message: 'Failed to load impact projects',
      );
    }
  }

  /// Full project with embedded organization, category and field stories.
  Future<ImpactProjectModel> getProjectDetail(int projectId) async {
    try {
      final response = await supabaseClient
          .from(_projectsTable)
          .select(_projectDetailColumns)
          .eq('id', projectId)
          .single();

      return ImpactProjectModel.fromJson(response);
    } catch (e) {
      talker.error(e);
      throw ServerException(
        type: .badRequest,
        message: 'Failed to load the project',
      );
    }
  }

  // ── Favorites ──────────────────────────────────────────────────────────────────

  /// Ids of the projects the current user has favourited.
  Future<Set<int>> getFavoriteProjectIds() async {
    final userId = _requireUserId();
    try {
      final response = await supabaseClient
          .from(_favoritesTable)
          .select('impact_project_id')
          .eq('user_id', userId);

      return {
        for (final row in response as List) row['impact_project_id'] as int,
      };
    } catch (e) {
      talker.error(e);
      throw ServerException(
        type: .badRequest,
        message: 'Failed to load favourite projects',
      );
    }
  }

  Future<void> addFavorite(int projectId) async {
    final userId = _requireUserId();
    try {
      await supabaseClient.from(_favoritesTable).upsert({
        'user_id': userId,
        'impact_project_id': projectId,
      }, onConflict: 'user_id,impact_project_id');
    } catch (e) {
      talker.error(e);
      throw ServerException(
        type: .badRequest,
        message: 'Failed to add favourite',
      );
    }
  }

  Future<void> removeFavorite(int projectId) async {
    final userId = _requireUserId();
    try {
      await supabaseClient
          .from(_favoritesTable)
          .delete()
          .eq('user_id', userId)
          .eq('impact_project_id', projectId);
    } catch (e) {
      talker.error(e);
      throw ServerException(
        type: .badRequest,
        message: 'Failed to remove favourite',
      );
    }
  }

  /// The user's favourite projects, newest-favourited first, joined with the
  /// project rows needed to render the card.
  Future<List<ImpactProjectModel>> getFavoriteProjects() async {
    final userId = _requireUserId();
    try {
      final response = await supabaseClient
          .from(_favoritesTable)
          .select('created_at, $_projectsTable($_projectColumns)')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return [
        for (final row in response as List)
          if (row[_projectsTable] != null)
            ImpactProjectModel.fromJson(
              row[_projectsTable] as Map<String, dynamic>,
            ),
      ];
    } catch (e) {
      talker.error(e);
      throw ServerException(
        type: .badRequest,
        message: 'Failed to load favourite projects',
      );
    }
  }
}
