import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/errors/exceptions/server/server_exception.dart';
import 'package:nour/src/core/network/supabase_client.dart';
import 'package:nour/src/core/utils/talker/talker.dart';

import '../models/adhkar_category_model.dart';
import '../models/adhkar_model.dart';
import '../models/adhkar_subcategory_model.dart';

final adhkarRemoteDataProvider = Provider(
  (ref) => AdhkarRemoteDatasource(),
);

class AdhkarRemoteDatasource {
  static const _categoriesTable = 'adhkar_categories';
  static const _subcategoriesTable = 'adhkar_subcategories';
  static const _adhkarsTable = 'adhkars';

  /// Public bucket holding subcategory illustrations.
  static const _imagesBucket = 'app_images';

  /// Resolves a stored [imgUrl] to a usable URL. Accepts either a full URL
  /// (returned as-is) or a storage object path inside `app_images`.
  static String? publicImageUrl(String? imgUrl) {
    if (imgUrl == null || imgUrl.isEmpty) return null;
    if (imgUrl.startsWith('http')) return imgUrl;
    return supabaseClient.storage.from(_imagesBucket).getPublicUrl(imgUrl);
  }

  Future<List<AdhkarCategoryModel>> getCategories() async {
    try {
      final response = await supabaseClient
          .from(_categoriesTable)
          .select()
          .order('position', ascending: true);

      return (response as List)
          .map((e) => AdhkarCategoryModel.fromJson(e))
          .toList();
    } catch (e) {
      talker.error(e);
      throw ServerException(
        type: .badRequest,
        message: 'Failed to load adhkar categories',
      );
    }
  }

  /// Subcategories with their adhkar count (`adhkars(count)` aggregate).
  Future<List<AdhkarSubcategoryModel>> getSubcategories() async {
    try {
      final response = await supabaseClient
          .from(_subcategoriesTable)
          .select('*, adhkars(count)')
          .order('position', ascending: true);

      return (response as List)
          .map((e) => AdhkarSubcategoryModel.fromJson(e))
          .toList();
    } catch (e) {
      talker.error(e);
      throw ServerException(
        type: .badRequest,
        message: 'Failed to load adhkar subcategories',
      );
    }
  }

  Future<List<AdhkarModel>> getAdhkarsBySubcategory(int subcategoryId) async {
    try {
      final response = await supabaseClient
          .from(_adhkarsTable)
          .select()
          .eq('adhkar_subcategory_id', subcategoryId)
          .eq('is_active', true)
          .order('id', ascending: true);

      return (response as List)
          .map((e) => AdhkarModel.fromJson(e))
          .toList();
    } catch (e) {
      talker.error(e);
      throw ServerException(
        type: .badRequest,
        message: 'Failed to load adhkars',
      );
    }
  }
}
