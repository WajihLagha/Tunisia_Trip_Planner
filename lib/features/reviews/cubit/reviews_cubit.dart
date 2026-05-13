import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunisian_trip_planner/features/reviews/cubit/reviews_states.dart';
import 'package:tunisian_trip_planner/features/reviews/models/review_request_dto.dart';
import 'package:tunisian_trip_planner/features/reviews/models/review_response_dto.dart';
import 'package:tunisian_trip_planner/features/reviews/models/review_target_type.dart';
import 'package:tunisian_trip_planner/shared/network/remote/dio_helper.dart';
import 'package:tunisian_trip_planner/shared/network/remote/end_points.dart';

class ReviewsCubit extends Cubit<ReviewsStates> {
  ReviewsCubit() : super(ReviewsInitialState());

  static ReviewsCubit get(context) => BlocProvider.of(context);
  static const String _ratingPredictionUrl =
      'https://tuniways-rating-prediction-frembwabgudffjaw.francecentral-01.azurewebsites.net/predict';

  static final Map<String, List<ReviewResponseDto>> _mockReviewsByTarget = {};

  List<ReviewResponseDto> _currentReviews = [];
  int _currentPage = 0;
  bool _isLastPage = false;

  void fetchReviews({
    required String targetId,
    required ReviewTargetType targetType,
    bool loadMore = false,
  }) {
    if (!loadMore) {
      _currentPage = 0;
      _currentReviews = [];
      _isLastPage = false;
      emit(ReviewsLoadingState());
    } else {
      if (_isLastPage) return;
      _currentPage++;
    }

    // Local mock reviews are used while the review service is unstable.
    // Submissions still call the prediction service and attempt the review POST.
    if (targetType == ReviewTargetType.transport ||
        targetType == ReviewTargetType.accommodation ||
        targetType == ReviewTargetType.place) {
      Future.delayed(const Duration(milliseconds: 500), () {
        _currentReviews = _mockReviewsFor(targetId, targetType);
        _isLastPage = true;
        emit(
          ReviewsLoadedState(
            reviews: _currentReviews,
            currentPage: _currentPage,
            isLastPage: _isLastPage,
          ),
        );
      });
      return;
    }

    final String path = '${EndPoints.reviews}/${targetType.name}/$targetId';

    DioHelper.getData(url: path, query: {'page': _currentPage, 'size': 10})
        .then((value) {
          if (value.data != null && value.data['content'] != null) {
            final List<dynamic> content = value.data['content'];
            final newReviews =
                content.map((e) => ReviewResponseDto.fromJson(e)).toList();

            _currentReviews.addAll(newReviews);
            _isLastPage = value.data['last'] ?? true;

            emit(
              ReviewsLoadedState(
                reviews: _currentReviews,
                currentPage: _currentPage,
                isLastPage: _isLastPage,
              ),
            );
          } else {
            emit(ReviewsErrorState("Failed to parse reviews data."));
          }
        })
        .catchError((error) {
          emit(ReviewsErrorState(error.toString()));
        });
  }

  Future<void> submitReview({
    required String targetId,
    required ReviewTargetType targetType,
    required String userId,
    required String userName,
    required String comment,
  }) async {
    emit(ReviewSubmissionLoadingState());

    try {
      final predictedRating = await _predictRating(comment);

      // Fallback Mock Booking ID as specified in plan
      const String bookingId = "MOCK-BKG-001";

      final requestDto = ReviewRequestDto(
        userId: userId,
        targetId: targetId,
        bookingId: bookingId,
        rating: predictedRating,
        comment: comment,
      );

      final String path = '${EndPoints.reviews}/${targetType.name}';

      final localReview = ReviewResponseDto(
        id: 'local-${DateTime.now().millisecondsSinceEpoch}',
        userId: userName,
        targetId: targetId,
        targetType: targetType,
        bookingId: bookingId,
        rating: predictedRating,
        comment: comment,
        createdAt: DateTime.now(),
      );

      _addLocalReview(localReview);

      emit(
        ReviewsLoadedState(
          reviews: _currentReviews,
          currentPage: _currentPage,
          isLastPage: true,
        ),
      );

      try {
        await DioHelper.postData(url: path, data: requestDto.toJson());
      } catch (error) {
        debugPrint('[ReviewsCubit] Review service POST failed: $error');
      }

      emit(
        ReviewSubmissionSuccessState(
          'Review added. Rating from message: $predictedRating',
        ),
      );
    } catch (error) {
      emit(ReviewSubmissionErrorState(error.toString()));
      emit(
        ReviewsLoadedState(
          reviews: _currentReviews,
          currentPage: _currentPage,
          isLastPage: _isLastPage,
        ),
      );
    }
  }

  Future<int> _predictRating(String comment) async {
    final response = await Dio().post(
      _ratingPredictionUrl,
      data: {'review': comment},
      options: Options(contentType: 'application/json'),
    );

    final rating = response.data?['rating'];
    if (rating is num) {
      return rating.toInt().clamp(1, 5);
    }

    throw Exception('Could not predict rating from review comment.');
  }

  String _targetKey(String targetId, ReviewTargetType targetType) {
    return '${targetType.name}:$targetId';
  }

  List<ReviewResponseDto> _mockReviewsFor(
    String targetId,
    ReviewTargetType targetType,
  ) {
    final key = _targetKey(targetId, targetType);
    return _mockReviewsByTarget.putIfAbsent(
      key,
      () => [
        ReviewResponseDto(
          id: 'mock1-$key',
          userId: 'Ali M.',
          targetId: targetId,
          targetType: targetType,
          bookingId: 'BKG-001',
          rating: 5,
          comment: 'Absolutely amazing experience! Highly recommended.',
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
        ReviewResponseDto(
          id: 'mock2-$key',
          userId: 'Sarra B.',
          targetId: targetId,
          targetType: targetType,
          bookingId: 'BKG-002',
          rating: 4,
          comment:
              'Very good service, clean and well organized. Will book again.',
          createdAt: DateTime.now().subtract(const Duration(days: 12)),
        ),
      ],
    );
  }

  void _addLocalReview(ReviewResponseDto review) {
    final targetId = review.targetId;
    final targetType = review.targetType;
    if (targetId == null || targetType == null) return;

    final reviews = _mockReviewsFor(targetId, targetType);
    reviews.removeWhere((item) => item.id == review.id);
    reviews.insert(0, review);
    _currentReviews = List<ReviewResponseDto>.from(reviews);
    _isLastPage = true;
  }
}
