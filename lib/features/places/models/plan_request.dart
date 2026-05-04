import 'places_response.dart';

class UserDto {
  final String? id;
  final String? name;
  final String? email;

  UserDto({this.id, this.name, this.email});

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    if (name != null) 'name': name,
    if (email != null) 'email': email,
  };
  
  factory UserDto.fromJson(Map<String, dynamic> json) => UserDto(
    id: json['id'] as String?,
    name: json['name'] as String?,
    email: json['email'] as String?,
  );
}

class AiUserReview {
  final String? id;
  final String? reviewText;
  final double? rating;

  AiUserReview({this.id, this.reviewText, this.rating});

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    if (reviewText != null) 'reviewText': reviewText,
    if (rating != null) 'rating': rating,
  };
  
  factory AiUserReview.fromJson(Map<String, dynamic> json) => AiUserReview(
    id: json['id'] as String?,
    reviewText: json['reviewText'] as String?,
    rating: (json['rating'] as num?)?.toDouble(),
  );
}

class PlanRequest {
  final String? destination;
  final UserDto? user;
  final List<String>? preferences;
  final List<PlacesResponse>? places;
  final int? groupNumber;
  final int? tripLength;
  final bool? accommodation;
  final bool? transport;
  final int? age;
  final double? budget;
  final List<AiUserReview>? reviews;

  PlanRequest({
    this.destination,
    this.user,
    this.preferences,
    this.places,
    this.groupNumber,
    this.tripLength,
    this.accommodation,
    this.transport,
    this.age,
    this.budget,
    this.reviews,
  });

  Map<String, dynamic> toJson() {
    return {
      if (destination != null) 'destination': destination,
      if (user != null) 'user': user?.toJson(),
      if (preferences != null) 'preferences': preferences,
      if (places != null) 'places': places?.map((e) => e.toJson()).toList(),
      if (groupNumber != null) 'groupNumber': groupNumber,
      if (tripLength != null) 'tripLength': tripLength,
      if (accommodation != null) 'accommodation': accommodation,
      if (transport != null) 'transport': transport,
      if (age != null) 'age': age,
      if (budget != null) 'budget': budget,
      if (reviews != null) 'reviews': reviews?.map((e) => e.toJson()).toList(),
    };
  }
}
