class DateTimeParser {
  static const _months = {
    'jan': 1,
    'january': 1,
    'feb': 2,
    'february': 2,
    'mar': 3,
    'march': 3,
    'apr': 4,
    'april': 4,
    'may': 5,
    'jun': 6,
    'june': 6,
    'jul': 7,
    'july': 7,
    'aug': 8,
    'august': 8,
    'sep': 9,
    'september': 9,
    'sept': 9,
    'oct': 10,
    'october': 10,
    'nov': 11,
    'november': 11,
    'dec': 12,
    'december': 12,
  };

  /// Parses natural language string to extract date and time.
  /// Returns a tuple of [Title, ScheduledDate].
  /// If no date/time found, defaults to Task Default (e.g., now or null).
  static ({String title, DateTime? dateTime}) parse(String text) {
    String cleanText = text.trim();
    DateTime? scheduledDate;

    // 1. Check for specific keywords
    final lower = cleanText.toLowerCase();

    // Context-aware time phrases (Natural Language Boost)
    final contextualPhrases = {
      // Time of day
      'tonight': (daysToAdd: 0, hour: 20, minute: 0),
      'this evening': (daysToAdd: 0, hour: 18, minute: 0),
      'this afternoon': (daysToAdd: 0, hour: 14, minute: 0),
      'this morning': (daysToAdd: 0, hour: 9, minute: 0),
      // Tomorrow variants
      'tomorrow morning': (daysToAdd: 1, hour: 9, minute: 0),
      'tomorrow afternoon': (daysToAdd: 1, hour: 14, minute: 0),
      'tomorrow evening': (daysToAdd: 1, hour: 18, minute: 0),
      'tomorrow night': (daysToAdd: 1, hour: 20, minute: 0),
    };

    // Check for contextual phrases first
    bool contextualDateFound = false;
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
        contextualDateFound = true;
        break;
      }
    }

    // 2. Explicit Date Parsing (e.g., "15 March", "Oct 3rd")
    // Only look for explicit dates if we haven't found a contextual one (like "tomorrow")
    // OR if we want to support "Tomorrow" overriding. But usually "15 March" is specific.
    if (!contextualDateFound) {
      // RegExp for "15 March" or "15th March"
      // Group 1: Day, Group 3: Month
      final dayMonthRegex = RegExp(
        r'\b(\d{1,2})(?:st|nd|rd|th)?\s+(of\s+)?([a-z]+)\b',
        caseSensitive: false,
      );

      // RegExp for "March 15" or "March 15th"
      // Group 1: Month, Group 2: Day
      final monthDayRegex = RegExp(
        r'\b([a-z]+)\s+(\d{1,2})(?:st|nd|rd|th)?\b',
        caseSensitive: false,
      );

      Match? dateMatch = dayMonthRegex.firstMatch(cleanText);
      String? monthStr;
      String? dayStr;
      String fullMatch = '';

      if (dateMatch != null) {
        dayStr = dateMatch.group(1);
        monthStr = dateMatch.group(3);
        fullMatch = dateMatch.group(0)!;
      } else {
        dateMatch = monthDayRegex.firstMatch(cleanText);
        if (dateMatch != null) {
          monthStr = dateMatch.group(1);
          dayStr = dateMatch.group(2);
          fullMatch = dateMatch.group(0)!;
        }
      }

      if (dayStr != null && monthStr != null) {
        final monthIndex = _months[monthStr.toLowerCase()];
        if (monthIndex != null) {
          final now = DateTime.now();
          final day = int.parse(dayStr);

          // Smart Year Inference
          // Attempt current year
          var parsedDate = DateTime(now.year, monthIndex, day);

          // If date is in the past (e.g. said "15 March" on Dec 15), assume next year
          // We assume "past" means strictly before today (ignoring time for now)
          if (parsedDate.isBefore(DateTime(now.year, now.month, now.day))) {
            parsedDate = DateTime(now.year + 1, monthIndex, day);
          }

          scheduledDate = parsedDate;
          cleanText = cleanText.replaceAll(fullMatch, '').trim();
        }
      }
    }

    // 3. Fallback Contextual Keywords
    if (scheduledDate == null && lower.contains('tomorrow')) {
      scheduledDate = _getDate(daysToAdd: 1);
      cleanText = _removeKeyword(cleanText, 'tomorrow');
    } else if (scheduledDate == null && lower.contains('today')) {
      scheduledDate = _getDate(daysToAdd: 0);
      cleanText = _removeKeyword(cleanText, 'today');
    } else if (scheduledDate == null && lower.contains('next week')) {
      scheduledDate = _getDate(daysToAdd: 7);
      cleanText = _removeKeyword(cleanText, 'next week');
    }

    // 4. Extract Time (e.g., "at 5 pm", "18:00", "8 p.m", "5:30am")
    final timeRegex = RegExp(
      r'(?:at\s+)?(\d{1,2})(?::(\d{2}))?\s*([ap]\.?m\.?)',
      caseSensitive: false,
    );
    final match = timeRegex.firstMatch(cleanText);

    if (match != null) {
      final hourStr = match.group(1);
      final minuteStr = match.group(2) ?? '00';
      final meridiem = match.group(3)?.replaceAll('.', '').toLowerCase();

      int hour = int.parse(hourStr!);
      int minute = int.parse(minuteStr);

      if (meridiem == 'pm' && hour < 12) hour += 12;
      if (meridiem == 'am' && hour == 12) hour = 0;

      // Clean up text
      cleanText = cleanText.replaceAll(match.group(0)!, '').trim();

      if (scheduledDate != null) {
        // combine date + time
        scheduledDate = DateTime(
          scheduledDate.year,
          scheduledDate.month,
          scheduledDate.day,
          hour,
          minute,
        );
      } else {
        // Only time provided, assume today/tomorrow smart logic
        final now = DateTime.now();
        var potentialDate =
            DateTime(now.year, now.month, now.day, hour, minute);

        // If time passed today (e.g. it's 3pm, user says "at 2pm"), assume tomorrow
        if (potentialDate.isBefore(now)) {
          potentialDate = potentialDate.add(const Duration(days: 1));
        }
        scheduledDate = potentialDate;
      }
    }

    // Cleanup extra "in" or "on"
    // e.g. "Meeting in Malaysia in 15 March" -> "Meeting in Malaysia" (handled by regex remove)
    // checking for dangling prepositions
    if (cleanText.endsWith(' in')) {
      cleanText = cleanText.substring(0, cleanText.length - 3).trim();
    }
    if (cleanText.endsWith(' on')) {
      cleanText = cleanText.substring(0, cleanText.length - 3).trim();
    }
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
