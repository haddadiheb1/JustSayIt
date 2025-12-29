enum TaskCategory {
  defaultCategory,
  personal,
  shopping,
  wishlist,
  work;

  String get displayName {
    switch (this) {
      case TaskCategory.defaultCategory:
        return 'Default';
      case TaskCategory.personal:
        return 'Personal';
      case TaskCategory.shopping:
        return 'Shopping';
      case TaskCategory.wishlist:
        return 'Wishlist';
      case TaskCategory.work:
        return 'Work';
    }
  }

  String get icon {
    switch (this) {
      case TaskCategory.defaultCategory:
        return '📋';
      case TaskCategory.personal:
        return '👤';
      case TaskCategory.shopping:
        return '🛒';
      case TaskCategory.wishlist:
        return '⭐';
      case TaskCategory.work:
        return '💼';
    }
  }

  int get colorValue {
    switch (this) {
      case TaskCategory.defaultCategory:
        return 0xFF6366F1; // Indigo
      case TaskCategory.personal:
        return 0xFF10B981; // Green
      case TaskCategory.shopping:
        return 0xFFF59E0B; // Amber
      case TaskCategory.wishlist:
        return 0xFFEC4899; // Pink
      case TaskCategory.work:
        return 0xFF3B82F6; // Blue
    }
  }
}
