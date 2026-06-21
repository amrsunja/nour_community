import 'package:nour/src/core/locale/l10n.dart';

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

  String title(AppLocale l) {
    switch (this) {
      case LevelType.begining:
        return l.level_begining_title;
      case LevelType.growing:
        return l.level_growing_title;
      case LevelType.established:
        return l.level_established_title;
      case LevelType.returning:
        return l.level_returning_title;
    }
  }

  String description(AppLocale l) {
    switch (this) {
      case LevelType.begining:
        return l.level_begining_description;
      case LevelType.growing:
        return l.level_growing_description;
      case LevelType.established:
        return l.level_established_description;
      case LevelType.returning:
        return l.level_returning_description;
    }
  }
}
