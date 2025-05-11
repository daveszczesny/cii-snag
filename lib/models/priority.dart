enum Priority {
  low,
  medium,
  high;

  static Priority getPriorityByString(String priority) {
    switch(priority.toLowerCase()) {
      case 'low':
        return Priority.low;
      case 'medium':
        return Priority.medium;
      case 'high':
        return Priority.high;
      default:
        return Priority.low; // Default to low if no match
    }
  }

  String get icon {
    switch(this) {
      case Priority.low:
        return 'lib/assets/icons/png/priority_low_icon.png';
      case Priority.medium:
        return 'lib/assets/icons/png/priority_medium_icon.png';
      case Priority.high:
        return 'lib/assets/icons/png/priority_high_icon.png';
      default:
        return 'lib/assets/icons/png/priority_low_icon.png';
    }
  }

  // implement get icon
}