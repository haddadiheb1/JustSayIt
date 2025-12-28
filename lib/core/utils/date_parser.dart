class DateTimeParser {
  /// Parses natural language string to extract date and time.
  /// Returns a tuple of [Title, ScheduledDate].
  /// If no date/time found, defaults to Task Default (e.g., now or null).
  static ({String title, DateTime? dateTime}) parse(String text) {
    String cleanText = text.trim();
    DateTime? scheduledDate;

    // 1. Check for specific keywords
    final lower = cleanText.toLowerCase();

    // Simple rule-based parsing

    // Context-aware time phrases (Natural Language Boost)
    final contextualPhrases = {
      // Time of day
      'tonight': (daysToAdd: 0, hour: 20, minute: 0),
      'this evening': (daysToAdd: 0, hour: 18, minute: 0),
      'this afternoon': (daysToAdd: 0, hour: 14, minute: 0),
      'this morning': (daysToAdd: 0, hour: 9, minute: 0),
      'after lunch': (daysToAdd: 0, hour: 13, minute: 30),
      'after dinner': (daysToAdd: 0, hour: 20, minute: 0),
      'before lunch': (daysToAdd: 0, hour: 11, minute: 30),

      // Tomorrow variants
      'tomorrow morning': (daysToAdd: 1, hour: 9, minute: 0),
      'tomorrow afternoon': (daysToAdd: 1, hour: 14, minute: 0),
      'tomorrow evening': (daysToAdd: 1, hour: 18, minute: 0),
      'tomorrow night': (daysToAdd: 1, hour: 20, minute: 0),
    };

    // Check for contextual phrases first
    for (final entry in contextualPhrases.entries) {
      if (lower.contains(entry.key)) {
        final now = DateTime.now();
        var dateTime = DateTime(
          now.year,
          now.month,
          now.day,
          entry.value.hour,
          entry.value.minute,
        ).add(Duration(days: entry.value.daysToAdd));

        // If time has passed today, move to tomorrow (for same-day phrases)
        if (entry.value.daysToAdd == 0 && dateTime.isBefore(now)) {
          dateTime = dateTime.add(const Duration(days: 1));
        }

        scheduledDate = dateTime;
        cleanText = _removeKeyword(cleanText, entry.key);
        break;
      }
    }

    // "Tomorrow" (only if not already matched by contextual phrases)
    if (scheduledDate == null && lower.contains('tomorrow')) {
      scheduledDate = _getDate(daysToAdd: 1);
      cleanText = _removeKeyword(cleanText, 'tomorrow');
    }
    // "Today"
    else if (scheduledDate == null && lower.contains('today')) {
      scheduledDate = _getDate(daysToAdd: 0);
      cleanText = _removeKeyword(cleanText, 'today');
    }
    // "Next week"
    else if (lower.contains('next week')) {
      scheduledDate = _getDate(daysToAdd: 7);
      cleanText = _removeKeyword(cleanText, 'next week');
    }

    // 2. Extract Time (e.g., "at 5 pm", "18:00")
    // Regex for "at 5 pm", "at 5:30 am", "5pm"
    final timeRegex = RegExp(
      r'(?:at\s+)?(\d{1,2})(?::(\d{2}))?\s*(am|pm)?',
      caseSensitive: false,
    );
    final match = timeRegex.firstMatch(cleanText);

    if (match != null && scheduledDate != null) {
      // If we found a date, let's try to add the time
      // If no date found yet, we might assume "Today" if time is in future, else "Tomorrow"?
      // For MVP, let's require a date keyword OR default to Today if only time is given.

      final hourStr = match.group(1);
      final minuteStr = match.group(2) ?? '00';
      final meridiem = match.group(3)?.toLowerCase();

      int hour = int.parse(hourStr!);
      int minute = int.parse(minuteStr);

      if (meridiem == 'pm' && hour < 12) hour += 12;
      if (meridiem == 'am' && hour == 12) hour = 0;

      scheduledDate = DateTime(
        scheduledDate.year,
        scheduledDate.month,
        scheduledDate.day,
        hour,
        minute,
      );

      // Remove the time string from title
      cleanText = cleanText.replaceAll(match.group(0)!, '').trim();
    } else if (match != null && scheduledDate == null) {
      // Only time provided, assume today
      final hourStr = match.group(1);
      final minuteStr = match.group(2) ?? '00';
      final meridiem = match.group(3)?.toLowerCase();

      int hour = int.parse(hourStr!);
      int minute = int.parse(minuteStr);

      if (meridiem == 'pm' && hour < 12) hour += 12;
      if (meridiem == 'am' && hour == 12) hour = 0;

      final now = DateTime.now();
      var potentialDate = DateTime(now.year, now.month, now.day, hour, minute);

      // If time passed, assume tomorrow
      if (potentialDate.isBefore(now)) {
        potentialDate = potentialDate.add(const Duration(days: 1));
      }

      scheduledDate = potentialDate;
      cleanText = cleanText.replaceAll(match.group(0)!, '').trim();
    }

    // Cleanup extra "at" or spaces
    cleanText = cleanText.replaceAll(RegExp(r'\s+'), ' ').trim();

    // Remove "at" at the end if exists
    if (cleanText.endsWith(' at')) {
      cleanText = cleanText.substring(0, cleanText.length - 3).trim();
    }

    return (title: cleanText, dateTime: scheduledDate);
  }

  static DateTime _getDate({required int daysToAdd}) {
    final now = DateTime.now();
    return DateTime(
      now.year,
      now.month,
      now.day,
    ).add(Duration(days: daysToAdd));
  }

  static String _removeKeyword(String text, String keyword) {
    final pattern = RegExp('\\b$keyword\\b', caseSensitive: false);
    return text.replaceAll(pattern, '').trim();
  }
}
