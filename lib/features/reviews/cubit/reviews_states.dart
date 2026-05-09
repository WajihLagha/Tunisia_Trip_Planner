import 'package:tunisian_trip_planner/features/reviews/models/review_response_dto.dart';

abstract class ReviewsStates {}

class ReviewsInitialState extends ReviewsStates {}

class ReviewsLoadingState extends ReviewsStates {}

class ReviewsLoadedState extends ReviewsStates {
  final List<ReviewResponseDto> reviews;
  final int currentPage;
  final bool isLastPage;

  ReviewsLoadedState({
    required this.reviews,
    required this.currentPage,
    required this.isLastPage,
  });
}

class ReviewsErrorState extends ReviewsStates {
  final String message;
  ReviewsErrorState(this.message);
}

class ReviewSubmissionLoadingState extends ReviewsStates {}

class ReviewSubmissionSuccessState extends ReviewsStates {
  final String message;
  ReviewSubmissionSuccessState(this.message);
}

class ReviewSubmissionErrorState extends ReviewsStates {
  final String message;
  ReviewSubmissionErrorState(this.message);
}
