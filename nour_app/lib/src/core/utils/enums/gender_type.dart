enum GenderType {
  male,
  female,
  undefined;

  static GenderType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'male':
        return male;
      case 'female':
        return female;
      default:
        return undefined;
    }
  }

  String get dbValue => name;
}
