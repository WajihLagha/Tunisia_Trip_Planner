class AiDayPlan {
  final int day;
  final List<String> places;

  const AiDayPlan({required this.day, required this.places});

  factory AiDayPlan.fromJson(Map<String, dynamic> json) => AiDayPlan(
        day: (json['day'] as num?)?.toInt() ?? 0,
        places:
            (json['places'] as List<dynamic>?)
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
    final rawDays = json['days'];
    List<AiDayPlan> parsedDays = [];

    if (rawDays is List) {
      parsedDays = rawDays
          .whereType<Map>()
          .map((d) => AiDayPlan.fromJson(Map<String, dynamic>.from(d)))
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

  factory AiItinerary.fromPlainText(String text, int tripLength) {
    final lines = text.split('\n').where((l) => l.trim().isNotEmpty).toList();
    final days = <AiDayPlan>[];

    int dayNum = 0;
    List<String> currentPlaces = [];

    for (final line in lines) {
      final dayMatch =
          RegExp(r'Day\s*(\d+)', caseSensitive: false).firstMatch(line);

      if (dayMatch != null) {
        if (dayNum > 0 && currentPlaces.isNotEmpty) {
          days.add(AiDayPlan(day: dayNum, places: List.from(currentPlaces)));
        }

        dayNum = int.parse(dayMatch.group(1)!);
        currentPlaces = [];

        final afterDay = line.substring(dayMatch.end).replaceAll(':', '').trim();
        if (afterDay.isNotEmpty) {
          currentPlaces.addAll(_splitPlacePath(afterDay));
        }
      } else if (dayNum > 0) {
        currentPlaces.addAll(_splitPlacePath(line));
      }
    }

    if (dayNum > 0 && currentPlaces.isNotEmpty) {
      days.add(AiDayPlan(day: dayNum, places: currentPlaces));
    }

    return AiItinerary(
      title: 'Your Tunisia Itinerary',
      summary: text.length > 200 ? '${text.substring(0, 200)}...' : text,
      totalDays: tripLength,
      days: days,
    );
  }

  factory AiItinerary.fromRawMap(Map<String, dynamic> raw) {
    final dayKeys = raw.keys
        .where((key) => RegExp(r'day\s*\d+', caseSensitive: false).hasMatch(key))
        .toList()
      ..sort((a, b) {
        final numA = int.tryParse(a.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
        final numB = int.tryParse(b.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
        return numA.compareTo(numB);
      });

    final keys = dayKeys.isNotEmpty ? dayKeys : raw.keys.toList();
    final days = keys.asMap().entries.map((entry) {
      final dayNum =
          int.tryParse(entry.value.replaceAll(RegExp(r'[^0-9]'), '')) ??
          entry.key + 1;
      final rawPath = raw[entry.value].toString();
      return AiDayPlan(day: dayNum, places: _splitPlacePath(rawPath));
    }).toList();

    return AiItinerary(
      title: 'Your AI Tunisia Trip',
      summary: 'A personalized itinerary crafted just for you.',
      totalDays: days.length,
      days: days,
    );
  }

  static List<String> _splitPlacePath(String text) {
    return text
        .replaceFirst(RegExp(r'^[-*\s]+'), '')
        .split(RegExp(r'\s*(?:->|,|;|\|)\s*'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }
}
