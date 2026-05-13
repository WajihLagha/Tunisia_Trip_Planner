import 'package:flutter/foundation.dart';
import 'package:tunisian_trip_planner/features/bookings/enums/booking_state.dart';
import 'package:tunisian_trip_planner/features/bookings/models/booking_dto.dart';
import 'package:tunisian_trip_planner/features/bookings/models/booking_request.dart';
import 'package:tunisian_trip_planner/shared/network/remote/dio_helper.dart';
import 'package:tunisian_trip_planner/shared/network/remote/end_points.dart';

class BookingRepository {
  Future<List<BookingDto>> getBookings(String userId) async {
    final response = await DioHelper.getData(
      url: EndPoints.bookings,
      headers: {'X-User-Id': userId},
    );

    if (response.statusCode == 200) {
      final data = response.data;
      if (data is! List) {
        debugPrint(
          '[BookingRepository] Unexpected bookings response: ${data.runtimeType}',
        );
        throw Exception('Unexpected bookings response format');
      }

      debugPrint('[BookingRepository] /bookings returned ${data.length} items');
      return data
          .map((json) => BookingDto.fromJson(Map<String, dynamic>.from(json)))
          .toList();
    } else {
      throw Exception('Failed to load bookings');
    }
  }

  Future<BookingDto> createBooking(
    String userId,
    BookingRequest request,
  ) async {
    final response = await DioHelper.postData(
      url: EndPoints.bookings,
      data: request.toJson(),
      headers: {'X-User-Id': userId},
    );

    final statusCode = response.statusCode ?? 0;
    if (statusCode >= 200 && statusCode < 300) {
      return BookingDto.fromJson(Map<String, dynamic>.from(response.data));
    } else {
      throw Exception('Failed to create booking');
    }
  }

  Future<BookingDto> updateBookingState(
    String userId,
    String bookingId,
    BookingState newState,
  ) async {
    final response = await DioHelper.putData(
      url: '${EndPoints.bookings}/$bookingId',
      data: '"${newState.value}"',
      headers: {'X-User-Id': userId},
    );

    if (response.statusCode == 200) {
      return BookingDto.fromJson(response.data);
    } else {
      throw Exception('Failed to update booking');
    }
  }

  Future<BookingDto> cancelBooking(String userId, String bookingId) async {
    final response = await DioHelper.deleteData(
      url: '${EndPoints.bookings}/$bookingId',
      headers: {'X-User-Id': userId},
    );

    if (response.statusCode == 200) {
      return BookingDto.fromJson(response.data);
    } else {
      throw Exception('Failed to cancel booking');
    }
  }
}
