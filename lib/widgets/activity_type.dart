enum ActivityType {indoors, outdoors, camping, quality, family, social}

extension ActivityTypeExtension on ActivityType {
  String get name{
    switch(this) {
      case ActivityType.indoors:
      return "Indoors";
      case ActivityType.outdoors:
      return "Outdoors";
      case ActivityType.camping:
      return "Camping";
      case ActivityType.quality:
      return "Quality";
      case ActivityType.family:
      return "Family";
      case ActivityType.social:
      return "Social";
      default:
      return "Unknown";
    }
  }
}