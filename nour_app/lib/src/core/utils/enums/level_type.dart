enum LevelType {
  begining,
  growing,
  established,
  returning;

  static LevelType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'begining':
        return begining;
      case 'growing':
        return growing;
      case 'established':
        return established;
      default:
        return returning;
    }
  }

  String get dbValue => name;
}
