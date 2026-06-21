/// Fallback helpers for the per-language content columns (`*_de`, `*_nl`,
/// `*_tr`, `*_id`, `*_ur`, `*_bn`, `*_ms`) which are nullable in the backend.
///
/// Content for the newer languages may not be seeded yet, so model resolvers
/// use these helpers to fall back to the (always present) English value when a
/// translation is missing or empty. `en` stays the default language.
extension LocalizedStringX on String? {
  /// Non-null resolution: this value when non-null & non-empty, else [fallback].
  String orLoc(String fallback) {
    final v = this;
    return (v == null || v.isEmpty) ? fallback : v;
  }

  /// Nullable resolution: this value when non-null & non-empty, else [fallback].
  String? orLocNullable(String? fallback) {
    final v = this;
    return (v == null || v.isEmpty) ? fallback : v;
  }
}
