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

    // MOCK DATA FOR TESTING: Transport and Accommodation
    if (targetType == ReviewTargetType.transport || targetType == ReviewTargetType.accommodation) {
      Future.delayed(const Duration(milliseconds: 500), () {
        _currentReviews = [
          ReviewResponseDto(
            id: 'mock1',
            userId: 'Ali M.',
            targetId: targetId,
            targetType: targetType,
            bookingId: 'BKG-001',
            rating: 5,
            comment: 'Absolutely amazing experience! Highly recommended.',
            createdAt: DateTime.now().subtract(const Duration(days: 2)),
          ),
          ReviewResponseDto(
            id: 'mock2',
            userId: 'Sarra B.',
            targetId: targetId,
            targetType: targetType,
            bookingId: 'BKG-002',
            rating: 4,
            comment: 'Very good service, clean and well organized. Will book again.',
            createdAt: DateTime.now().subtract(const Duration(days: 12)),
          ),
        ];
        _isLastPage = true;
        emit(ReviewsLoadedState(
          reviews: _currentReviews,
          currentPage: _currentPage,
          isLastPage: _isLastPage,
        ));
      });
      return;
    }

    final String path = '${EndPoints.reviews}/${targetType.name}/$targetId';

    DioHelper.getData(
      url: path,
      query: {
        'page': _currentPage,
        'size': 10,
      },
    ).then((value) {
      if (value.data != null && value.data['content'] != null) {
        final List<dynamic> content = value.data['content'];
        final newReviews = content.map((e) => ReviewResponseDto.fromJson(e)).toList();
        
        _currentReviews.addAll(newReviews);
        _isLastPage = value.data['last'] ?? true;
        
        emit(ReviewsLoadedState(
          reviews: _currentReviews,
          currentPage: _currentPage,
          isLastPage: _isLastPage,
        ));
      } else {
        emit(ReviewsErrorState("Failed to parse reviews data."));
      }
    }).catchError((error) {
      emit(ReviewsErrorState(error.toString()));
    });
  }

  void submitReview({
    required String targetId,
    required ReviewTargetType targetType,
    required String userId,
    required int rating,
    required String comment,
  }) {
    emit(ReviewSubmissionLoadingState());

    // Fallback Mock Booking ID as specified in plan
    final String bookingId = "MOCK-BKG-001";

    final requestDto = ReviewRequestDto(
      userId: userId,
      targetId: targetId,
      bookingId: bookingId,
      rating: rating,
      comment: comment,
    );

    final String path = '${EndPoints.reviews}/${targetType.name}';

    DioHelper.postData(
      url: path,
      data: requestDto.toJson(),
    ).then((value) {
      emit(ReviewSubmissionSuccessState("Review submitted successfully!"));
      // Refresh the list after successful submission
      fetchReviews(targetId: targetId, targetType: targetType);
    }).catchError((error) {
      emit(ReviewSubmissionErrorState(error.toString()));
      // Restore previous loaded state so list remains visible
      emit(ReviewsLoadedState(
        reviews: _currentReviews,
        currentPage: _currentPage,
        isLastPage: _isLastPage,
      ));
    });
  }
}
