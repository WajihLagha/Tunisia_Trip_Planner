class ReviewRequestDto {
  final String userId;
  final String targetId;
  final String bookingId;
  final int rating;
  final String? comment;

  ReviewRequestDto({
    required this.userId,
    required this.targetId,
    required this.bookingId,
    required this.rating,
    this.comment,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'targetId': targetId,
      'bookingId': bookingId,
      'rating': rating,
      'comment': comment,
    };
  }
}
