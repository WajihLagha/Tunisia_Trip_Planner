import 'ai_place.dart';

class AiPlanRequest {
  final List<AiPlace> places;
  final String user;
  final int age;
  final List<String> preferences;
  final double budget;
  final int tripLength;
  final int groupNumber;
  final bool accommodation;
  final bool transportMean;

  const AiPlanRequest({
    required this.places,
    required this.user,
    required this.age,
    required this.preferences,
    required this.budget,
    required this.tripLength,
    required this.groupNumber,
    required this.accommodation,
    required this.transportMean,
  });

  Map<String, dynamic> toJson() => {
        'places': places.map((p) => p.toJson()).toList(),
        'user': user,
        'age': age,
        'preferences': preferences,
        'budget': budget,
        'tripLength': tripLength,
        'group_number': groupNumber,
        'accommodation': accommodation,
        'transport_mean': transportMean,
      };
}
