import 'package:tunisian_trip_planner/features/bookings/models/booking_dto.dart';

abstract class BookingState {}

class BookingInitial extends BookingState {}

class BookingLoading extends BookingState {}

class BookingLoaded extends BookingState {
  final List<BookingDto> bookings;
  BookingLoaded(this.bookings);
}

class BookingError extends BookingState {
  final String error;
  BookingError(this.error);
}

class BookingActionLoading extends BookingState {}

class BookingActionSuccess extends BookingState {
  final BookingDto booking;
  final String message;
  BookingActionSuccess(this.booking, this.message);
}

class BookingActionError extends BookingState {
  final String error;
  BookingActionError(this.error);
}
