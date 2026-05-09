import 'package:tunisian_trip_planner/features/reviews/models/review_target_type.dart';

class ReviewResponseDto {
  final String? id;
  final String? userId;
  final ReviewTargetType? targetType;
  final String? targetId;
  final String? bookingId;
  final int? rating;
  final String? comment;
  final double? currentAverageRating;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ReviewResponseDto({
    this.id,
    this.userId,
    this.targetType,
    this.targetId,
    this.bookingId,
    this.rating,
    this.comment,
    this.currentAverageRating,
    this.createdAt,
    this.updatedAt,
  });

  factory ReviewResponseDto.fromJson(Map<String, dynamic> json) {
    ReviewTargetType? parseTargetType(String? type) {
      if (type == null) return null;
      switch (type.toLowerCase()) {
        case 'accommodation':
          return ReviewTargetType.accommodation;
        case 'transport':
          return ReviewTargetType.transport;
        case 'place':
          return ReviewTargetType.place;
        default:
          return null;
      }
    }

    return ReviewResponseDto(
      id: json['id'] as String?,
      userId: json['userId'] as String?,
      targetType: parseTargetType(json['targetType'] as String?),
      targetId: json['targetId'] as String?,
      bookingId: json['bookingId'] as String?,
      rating: json['rating'] as int?,
      comment: json['comment'] as String?,
      currentAverageRating: (json['currentAverageRating'] as num?)?.toDouble(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }
}
