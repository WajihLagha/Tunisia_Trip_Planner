class AiDayPlan {
  final int day;
  final List<String> places;

  const AiDayPlan({required this.day, required this.places});

  factory AiDayPlan.fromJson(Map<String, dynamic> json) => AiDayPlan(
        day: (json['day'] as num?)?.toInt() ?? 0,
        places: (json['places'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
      );

  Map<String, dynamic> toJson() => {
        'day': day,
        'places': places,
      };
}

class AiItinerary {
  final String? title;
  final String? summary;
  final int? totalDays;
  final double? estimatedBudget;
  final List<AiDayPlan> days;
  final List<String>? tips;

  const AiItinerary({
    this.title,
    this.summary,
    this.totalDays,
    this.estimatedBudget,
    required this.days,
    this.tips,
  });

  factory AiItinerary.fromJson(Map<String, dynamic> json) {
    // Handle both structured JSON and plain string fallback
    final rawDays = json['days'];
    List<AiDayPlan> parsedDays = [];
    if (rawDays is List) {
      parsedDays = rawDays
          .whereType<Map<String, dynamic>>()
          .map((d) => AiDayPlan.fromJson(d))
          .toList();
    }
    return AiItinerary(
      title: json['title'] as String?,
      summary: json['summary'] as String?,
      totalDays: (json['totalDays'] as num?)?.toInt(),
      estimatedBudget: (json['estimatedBudget'] as num?)?.toDouble(),
      days: parsedDays,
      tips: (json['tips'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
    );
  }

  /// Builds an AiItinerary from a raw plain-text AI response when the
  /// backend returns a simple string instead of structured JSON.
  factory AiItinerary.fromPlainText(String text, int tripLength) {
    final lines = text.split('\n').where((l) => l.trim().isNotEmpty).toList();
    final days = <AiDayPlan>[];

    int dayNum = 0;
    List<String> currentPlaces = [];

    for (final line in lines) {
      final dayMatch = RegExp(r'Day\s*(\d+)', caseSensitive: false).firstMatch(line);
      if (dayMatch != null) {
        if (dayNum > 0 && currentPlaces.isNotEmpty) {
          days.add(AiDayPlan(day: dayNum, places: List.from(currentPlaces)));
        }
        dayNum = int.parse(dayMatch.group(1)!);
        currentPlaces = [];
        // parse places from same line after "Day N"
        final afterDay = line.substring(dayMatch.end).replaceAll(':', '').trim();
        if (afterDay.isNotEmpty) {
          currentPlaces.addAll(afterDay.split(RegExp(r'[,→➜]')).map((s) => s.trim()).where((s) => s.isNotEmpty));
        }
      } else if (dayNum > 0) {
        currentPlaces.addAll(line.split(RegExp(r'[,→➜•\-]')).map((s) => s.trim()).where((s) => s.isNotEmpty));
      }
    }
    if (dayNum > 0 && currentPlaces.isNotEmpty) {
      days.add(AiDayPlan(day: dayNum, places: currentPlaces));
    }

    return AiItinerary(
      title: 'Your Tunisia Itinerary',
      summary: text.length > 200 ? '${text.substring(0, 200)}…' : text,
      totalDays: tripLength,
      days: days,
    );
  }

  /// Parses the backend's raw map response: {"day1": "Place A -> Place B", "day2": "..."}
  factory AiItinerary.fromRawMap(Map<String, dynamic> raw) {
    // Sort keys so day1, day2... appear in order
    final keys = raw.keys.toList()
      ..sort((a, b) {
        final numA = int.tryParse(a.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
        final numB = int.tryParse(b.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
        return numA.compareTo(numB);
      });

    final days = keys.asMap().entries.map((entry) {
      final dayNum = entry.key + 1;
      final rawPath = raw[entry.value].toString();
      final places = rawPath
          .split(' -> ')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
      return AiDayPlan(day: dayNum, places: places);
    }).toList();

    return AiItinerary(
      title: 'Your AI Tunisia Trip',
      summary: 'A personalized itinerary crafted just for you.',
      totalDays: days.length,
      days: days,
    );
  }
}
