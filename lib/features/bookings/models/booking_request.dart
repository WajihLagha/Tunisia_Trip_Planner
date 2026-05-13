import 'package:tunisian_trip_planner/features/bookings/enums/payment_method.dart';

class BookingRequest {
  final String? accommodationId;
  final String? transportId;
  final num amount;
  final PaymentMethod paymentMethod;

  BookingRequest({
    this.accommodationId,
    this.transportId,
    required this.amount,
    required this.paymentMethod,
  });

  Map<String, dynamic> toJson() {
    return {
      if (accommodationId != null) 'accommodationId': accommodationId,
      if (transportId != null) 'transportId': transportId,
      'amount': amount,
      'paymentMethod': paymentMethod.value,
    };
  }
}
