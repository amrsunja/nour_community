/// Mirrors `public.account_type`. Missing / unknown values resolve to [user]
/// so profiles cached before the mosques module keep working.
enum AccountType {
  user,
  mosque;

  static AccountType fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'mosque':
        return mosque;
      default:
        return user;
    }
  }

  String get dbValue => name;

  bool get isMosque => this == mosque;
}
