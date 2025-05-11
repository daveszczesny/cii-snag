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

  // implement get icon
}