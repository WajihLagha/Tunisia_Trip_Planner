import 'package:tunisian_trip_planner/features/bookings/enums/booking_state.dart';
import 'package:tunisian_trip_planner/features/bookings/enums/payment_method.dart';

class BookingDto {
  final String? id;
  final BookingState? state;
  final String? userId;
  final String? accommodationId;
  final String? transportId;
  final num? amount;
  final PaymentMethod? paymentMethod;
  final String? stripePaymentIntentId;
  final String? clientSecret;
  final String? createdDate;
  final String? lastModifiedDate;

  BookingDto({
    this.id,
    this.state,
    this.userId,
    this.accommodationId,
    this.transportId,
    this.amount,
    this.paymentMethod,
    this.stripePaymentIntentId,
    this.clientSecret,
    this.createdDate,
    this.lastModifiedDate,
  });

  factory BookingDto.fromJson(Map<String, dynamic> json) {
    return BookingDto(
      id: json['id'],
      state: json['state'] != null ? BookingStateExtension.fromString(json['state']) : null,
      userId: json['userId'],
      accommodationId: json['accommodationId'],
      transportId: json['transportId'],
      amount: json['amount'],
      paymentMethod: json['paymentMethod'] != null
          ? PaymentMethodExtension.fromString(json['paymentMethod'])
          : null,
      stripePaymentIntentId: json['stripePaymentIntentId'],
      clientSecret: json['clientSecret'],
      createdDate: json['createdDate'],
      lastModifiedDate: json['lastModifiedDate'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (state != null) 'state': state!.value,
      if (userId != null) 'userId': userId,
      if (accommodationId != null) 'accommodationId': accommodationId,
      if (transportId != null) 'transportId': transportId,
      if (amount != null) 'amount': amount,
      if (paymentMethod != null) 'paymentMethod': paymentMethod!.value,
      if (stripePaymentIntentId != null) 'stripePaymentIntentId': stripePaymentIntentId,
      if (clientSecret != null) 'clientSecret': clientSecret,
      if (createdDate != null) 'createdDate': createdDate,
      if (lastModifiedDate != null) 'lastModifiedDate': lastModifiedDate,
    };
  }
}
