import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:tunisian_trip_planner/features/bookings/cubit/booking_states.dart';
import 'package:tunisian_trip_planner/features/bookings/enums/booking_state.dart'
    as model_state;
import 'package:tunisian_trip_planner/features/bookings/models/booking_dto.dart';
import 'package:tunisian_trip_planner/features/bookings/models/booking_request.dart';
import 'package:tunisian_trip_planner/features/bookings/repositories/booking_repository.dart';

class BookingCubit extends Cubit<BookingState> {
  static const String _stripeMerchantName = 'TuniWays';

  final BookingRepository _repository;
  List<BookingDto> _bookings = [];

  BookingCubit(this._repository) : super(BookingInitial());

  static BookingCubit get(context) => BlocProvider.of(context);
  List<BookingDto> get bookings => List.unmodifiable(_bookings);

  Future<void> getUserBookings(String userId) async {
    emit(BookingLoading());
    try {
      final bookings = await _repository.getBookings(userId);
      _bookings = bookings;
      debugPrint(
        '[BookingCubit] Loaded ${bookings.length} bookings for user $userId',
      );
      emit(BookingLoaded(_bookings));
    } catch (e) {
      debugPrint('[BookingCubit] Failed to load bookings for user $userId: $e');
      emit(BookingError(e.toString()));
    }
  }

  Future<void> createBooking(String userId, BookingRequest request) async {
    emit(BookingActionLoading());
    try {
      final booking = await _repository.createBooking(userId, request);
      emit(BookingActionSuccess(booking, 'Booking created successfully'));
      getUserBookings(userId);
    } catch (e) {
      emit(BookingActionError(e.toString()));
    }
  }

  Future<void> cancelBooking(String userId, String bookingId) async {
    emit(BookingActionLoading());
    try {
      final booking = await _repository.cancelBooking(userId, bookingId);
      emit(BookingActionSuccess(booking, 'Booking cancelled successfully'));
      getUserBookings(userId);
    } catch (e) {
      emit(BookingActionError(e.toString()));
    }
  }

  Future<void> updateBookingState(
    String userId,
    String bookingId,
    model_state.BookingState newState,
  ) async {
    emit(BookingActionLoading());
    try {
      final booking = await _repository.updateBookingState(
        userId,
        bookingId,
        newState,
      );
      emit(BookingActionSuccess(booking, 'Booking updated successfully'));
      getUserBookings(userId);
    } catch (e) {
      emit(BookingActionError(e.toString()));
    }
  }

  Future<void> createBookingAndPay(
    String userId,
    BookingRequest request,
  ) async {
    emit(BookingActionLoading());

    BookingDto? createdBooking;

    try {
      final booking = await _repository.createBooking(userId, request);
      createdBooking = booking;

      final clientSecret = booking.clientSecret;
      if (clientSecret == null || clientSecret.isEmpty) {
        throw Exception(
          'The booking service did not return a Stripe client secret.',
        );
      }

      debugPrint(
        '[BookingCubit] Opening Stripe PaymentSheet for booking '
        '${booking.id ?? 'unknown'} and intent '
        '${booking.stripePaymentIntentId ?? 'unknown'}',
      );

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: _stripeMerchantName,
          style: ThemeMode.system,
        ),
      );

      await Stripe.instance.presentPaymentSheet();

      debugPrint(
        '[BookingCubit] Stripe PaymentSheet completed for booking '
        '${booking.id ?? 'unknown'}',
      );
      emit(BookingActionSuccess(booking, 'Payment and Booking Confirmed!'));
      getUserBookings(userId);
    } on StripeException catch (e) {
      await _rollbackCreatedBooking(userId, createdBooking?.id);
      final message = _stripeErrorMessage(e);
      debugPrint(
        '[BookingCubit] Stripe PaymentSheet error (${e.error.code}): $message',
      );
      emit(BookingActionError(message));
    } catch (e) {
      await _rollbackCreatedBooking(userId, createdBooking?.id);
      debugPrint('[BookingCubit] Booking payment flow failed: $e');
      emit(BookingActionError(e.toString()));
    }
  }

  Future<void> _rollbackCreatedBooking(String userId, String? bookingId) async {
    if (bookingId == null || bookingId.isEmpty) return;

    try {
      await _repository.cancelBooking(userId, bookingId);
      debugPrint('[BookingCubit] Rolled back unpaid booking $bookingId');
    } catch (e) {
      debugPrint('[BookingCubit] Failed to roll back booking $bookingId: $e');
    }
  }

  String _stripeErrorMessage(StripeException exception) {
    if (exception.error.code == FailureCode.Canceled) {
      return 'Payment was cancelled.';
    }

    final details = exception.error.localizedMessage ?? exception.error.message;
    if (details == null || details.isEmpty) {
      return 'Stripe could not complete the payment. Please try again.';
    }

    return 'Stripe payment failed: $details';
  }
}
